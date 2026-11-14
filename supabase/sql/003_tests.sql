-- Dashboard SQL Editor checks for THRIFTY schema and policy setup.
-- No Docker, Supabase CLI, test extension, or persistent fixture data is needed.
-- Run after 001_schema.sql and 002_rls.sql. This file is read-only and rolls back.

begin;

do $verify$
declare
  v_count integer;
begin
  select count(*)
    into v_count
    from pg_class as c
    join pg_namespace as n on n.oid = c.relnamespace
   where n.nspname = 'public'
     and c.relname in ('profiles', 'products')
     and c.relkind = 'r'
     and c.relrowsecurity;
  if v_count <> 2 then
    raise exception 'Expected RLS enabled on profiles and products; found %', v_count;
  end if;

  if not has_table_privilege('anon', 'public.products', 'SELECT')
     or has_table_privilege('anon', 'public.products', 'INSERT')
     or has_table_privilege('anon', 'public.products', 'UPDATE')
     or has_table_privilege('anon', 'public.products', 'DELETE') then
    raise exception 'Unexpected anon table grants on public.products';
  end if;

  if has_table_privilege('anon', 'public.profiles', 'SELECT')
     or has_table_privilege('anon', 'public.profiles', 'UPDATE')
     or has_table_privilege('authenticated', 'public.profiles', 'INSERT')
     or has_table_privilege('authenticated', 'public.profiles', 'DELETE') then
    raise exception 'Unexpected grants on public.profiles';
  end if;

  if not has_table_privilege('authenticated', 'public.profiles', 'SELECT')
     or not has_table_privilege('authenticated', 'public.profiles', 'UPDATE')
     or not has_table_privilege('authenticated', 'public.products', 'SELECT')
     or not has_table_privilege('authenticated', 'public.products', 'INSERT')
     or not has_table_privilege('authenticated', 'public.products', 'UPDATE')
     or not has_table_privilege('authenticated', 'public.products', 'DELETE') then
    raise exception 'A required authenticated table grant is missing';
  end if;

  if not has_schema_privilege('authenticated', 'private', 'USAGE')
     or not has_function_privilege(
       'authenticated', 'private.current_user_role()', 'EXECUTE'
     ) then
    raise exception 'authenticated is missing private helper schema/function access';
  end if;

  if has_schema_privilege('anon', 'private', 'USAGE')
     or has_function_privilege('anon', 'private.current_user_role()', 'EXECUTE') then
    raise exception 'anon unexpectedly has private helper access';
  end if;

  select count(*)
    into v_count
    from pg_policies
   where schemaname = 'public'
     and (tablename, policyname) in (
       ('profiles', 'profiles_read_self'),
       ('profiles', 'profiles_update_self'),
       ('products', 'products_read_active_or_owner'),
       ('products', 'products_insert_seller_self'),
       ('products', 'products_update_seller_owner'),
       ('products', 'products_delete_seller_owner')
     );
  if v_count <> 6 then
    raise exception 'Expected six THRIFTY RLS policies; found %', v_count;
  end if;

  if not exists (
    select 1 from pg_trigger
     where tgrelid = 'auth.users'::regclass
       and tgname = 'on_auth_user_created'
       and not tgisinternal
  ) then
    raise exception 'Auth profile creation trigger is missing';
  end if;

  if not exists (
    select 1 from pg_trigger
     where tgrelid = 'public.profiles'::regclass
       and tgname = 'profiles_prevent_role_change'
       and not tgisinternal
  ) or not exists (
    select 1 from pg_trigger
     where tgrelid = 'public.products'::regclass
       and tgname = 'products_sync_seller_name'
       and not tgisinternal
  ) then
    raise exception 'A role-lock or seller-id/name trigger is missing';
  end if;

  raise notice 'PASS: both public tables have RLS enabled';
  raise notice 'PASS: table grants match the anon/authenticated access plan';
  raise notice 'PASS: authenticated can use the private role helper; anon cannot';
  raise notice 'PASS: six policies and required triggers are present';
end;
$verify$;

-- Dashboard SQL Editor impersonation smoke checks, following the official
-- Supabase pattern: SET LOCAL ROLE plus request.jwt.claim.sub in one transaction.
set local role anon;
set local request.jwt.claim.sub = '';
select auth.uid() is null as anon_has_no_user_id;
select count(*) as visible_active_products
  from public.products
 where status = 'active';

-- This fixed UUID has no profile. It verifies authenticated has EXECUTE/USAGE and
-- the helper safely returns NULL when no profile row exists; it is not a seller test.
set local role authenticated;
set local request.jwt.claim.sub = '00000000-0000-0000-0000-000000000001';
select private.current_user_role() is null as missing_profile_role_is_null;

rollback;

-- Full buyer/seller ownership tests use real Auth users and products. After Step 3
-- creates a buyer and seller account, use their Auth UUIDs in the SQL Editor:
-- 1. BEGIN; SET LOCAL ROLE authenticated; SET LOCAL request.jwt.claim.sub = '<SELLER_UUID>';
--    SELECT private.current_user_role(); -- expected: seller
-- 2. As that seller, INSERT an active product with seller_id = their UUID RETURNING id;
--    expected: one row. Change role to anon and SELECT that active product: one row.
-- 3. As the buyer UUID, SELECT that active product: one row; SELECT the seller's sold
--    product: no row; INSERT/UPDATE/DELETE a product: rejected by RLS.
-- 4. As the seller UUID, SELECT their sold product: one row; UPDATE/DELETE their own
--    product: allowed. Attempt to change seller_id or profiles.role: rejected.
-- 5. As anon, attempt INSERT/UPDATE/DELETE: rejected by missing grants. Profiles are
--    not readable by anon or by another authenticated user; profiles have no DELETE grant.
-- Run each expected-denial statement in its own BEGIN/ROLLBACK block because a SQL
-- error aborts that transaction. Do not use placeholder UUIDs for these behavior tests.

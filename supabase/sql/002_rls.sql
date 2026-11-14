-- THRIFTY grants and row-level security policies. Run after 001_schema.sql.

begin;

-- The public schema is intentionally exposed through the Data API. Access still
-- requires both SQL grants and an RLS policy. The private helper schema is not exposed.
grant usage on schema public to anon, authenticated;
revoke all on schema private from public, anon, authenticated;

-- Remove broad defaults for these tables, then grant only the required operations.
revoke all on table public.profiles from public, anon, authenticated;
revoke all on table public.products from public, anon, authenticated;

grant select, update on table public.profiles to authenticated;
grant select on table public.products to anon, authenticated;
grant insert, update, delete on table public.products to authenticated;

-- The policy helper is called only by authenticated seller policies. anon policies
-- do not call it, so anon receives no USAGE or EXECUTE privilege on private.
revoke all on function private.current_user_role() from public, anon, authenticated;
grant usage on schema private to authenticated;
grant execute on function private.current_user_role() to authenticated;

alter table public.profiles enable row level security;
alter table public.products enable row level security;

drop policy if exists profiles_read_self on public.profiles;
create policy profiles_read_self
  on public.profiles
  for select
  to authenticated
  using ((select auth.uid()) is not null and id = (select auth.uid()));

drop policy if exists profiles_update_self on public.profiles;
create policy profiles_update_self
  on public.profiles
  for update
  to authenticated
  using ((select auth.uid()) is not null and id = (select auth.uid()))
  with check ((select auth.uid()) is not null and id = (select auth.uid()));

-- Guests can read active listings. A signed-in owner can also read their own sold
-- listings. The public row intentionally includes seller_name, not profile email.
drop policy if exists products_read_active_or_owner on public.products;
create policy products_read_active_or_owner
  on public.products
  for select
  to anon, authenticated
  using (
    status = 'active'
    or (
      (select auth.uid()) is not null
      and seller_id = (select auth.uid())
    )
  );

drop policy if exists products_insert_seller_self on public.products;
create policy products_insert_seller_self
  on public.products
  for insert
  to authenticated
  with check (
    seller_id = (select auth.uid())
    and (select private.current_user_role()) = 'seller'
  );

drop policy if exists products_update_seller_owner on public.products;
create policy products_update_seller_owner
  on public.products
  for update
  to authenticated
  using (
    seller_id = (select auth.uid())
    and (select private.current_user_role()) = 'seller'
  )
  with check (
    seller_id = (select auth.uid())
    and (select private.current_user_role()) = 'seller'
  );

drop policy if exists products_delete_seller_owner on public.products;
create policy products_delete_seller_owner
  on public.products
  for delete
  to authenticated
  using (
    seller_id = (select auth.uid())
    and (select private.current_user_role()) = 'seller'
  );

commit;

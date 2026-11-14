-- THRIFTY schema: run once in a new Supabase project using the Dashboard SQL Editor.
-- This file creates the application tables and their data-integrity triggers.

begin;

create schema if not exists private;

create table public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  display_name text not null,
  role text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint profiles_display_name_nonempty
    check (char_length(btrim(display_name)) between 1 and 80),
  constraint profiles_role_allowed
    check (role in ('buyer', 'seller'))
);

create table public.products (
  id uuid primary key default gen_random_uuid(),
  seller_id uuid not null references auth.users (id) on delete cascade,
  seller_name text not null,
  name text not null,
  brand text not null default '',
  size text not null,
  category text not null,
  price integer not null,
  description text not null default '',
  pickup_location text not null,
  latitude double precision,
  longitude double precision,
  image_urls text[] not null default array[]::text[],
  ai_grade text,
  ai_confidence numeric(5, 4),
  final_grade text not null,
  grade_overridden boolean not null default false,
  status text not null default 'active',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint products_name_nonempty
    check (char_length(btrim(name)) between 1 and 160),
  constraint products_brand_length
    check (char_length(brand) <= 120),
  constraint products_size_length
    check (char_length(btrim(size)) between 1 and 40),
  constraint products_category_allowed
    check (category in ('Shirt', 'T-Shirt', 'Pants', 'Jacket')),
  constraint products_price_positive
    check (price > 0),
  constraint products_pickup_location_nonempty
    check (char_length(btrim(pickup_location)) between 1 and 240),
  constraint products_latitude_range
    check (latitude is null or latitude between -90 and 90),
  constraint products_longitude_range
    check (longitude is null or longitude between -180 and 180),
  constraint products_location_pair
    check ((latitude is null) = (longitude is null)),
  constraint products_image_urls_max_six
    check (cardinality(image_urls) <= 6),
  constraint products_ai_grade_allowed
    check (ai_grade is null or ai_grade in ('A', 'B', 'C', 'D')),
  constraint products_ai_confidence_range
    check (ai_confidence is null or ai_confidence between 0 and 1),
  constraint products_final_grade_allowed
    check (final_grade in ('A', 'B', 'C', 'D')),
  constraint products_grade_override_consistent
    check (grade_overridden = (ai_grade is not null and ai_grade is distinct from final_grade)),
  constraint products_status_allowed
    check (status in ('active', 'sold'))
);

-- These indexes match the current database query shapes. Search remains client-side.
create index products_active_created_at_idx
  on public.products (created_at desc)
  where status = 'active';

create index products_active_category_created_at_idx
  on public.products (category, created_at desc)
  where status = 'active';

create index products_seller_status_created_at_idx
  on public.products (seller_id, status, created_at desc);

-- Read the caller's persisted role without re-entering profiles RLS from a
-- products policy. The function is private and will be executable only by
-- authenticated in 002_rls.sql.
create or replace function private.current_user_role()
returns text
language sql
stable
security definer
set search_path = ''
as $$
  select p.role
    from public.profiles as p
   where p.id = (select auth.uid())
   limit 1;
$$;

create or replace function private.set_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

-- Fail the Auth user's insert if the required role/display-name metadata is absent
-- or invalid. The profile is created atomically with the auth.users row.
create or replace function private.handle_new_auth_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_role text := new.raw_user_meta_data ->> 'role';
  v_display_name text := btrim(coalesce(new.raw_user_meta_data ->> 'display_name', ''));
begin
  if v_role is null or v_role not in ('buyer', 'seller') then
    raise exception 'Signup role must be buyer or seller' using errcode = '23514';
  end if;

  if char_length(v_display_name) not between 1 and 80 then
    raise exception 'Signup display_name must contain 1 to 80 non-space characters'
      using errcode = '23514';
  end if;

  insert into public.profiles (id, display_name, role)
  values (new.id, v_display_name, v_role);

  return new;
end;
$$;

create or replace function private.prevent_profile_role_change()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  -- Authenticated API requests cannot change the persisted authorization role.
  -- Dashboard/admin corrections have no end-user auth.uid() and remain possible.
  if auth.uid() is not null and new.role is distinct from old.role then
    raise exception 'Profile role cannot be changed through the client API'
      using errcode = '42501';
  end if;
  return new;
end;
$$;

create or replace function private.sync_product_seller_name()
returns trigger
language plpgsql
set search_path = ''
as $$
declare
  v_display_name text;
begin
  if auth.uid() is not null then
    if tg_op = 'INSERT' and new.seller_id is distinct from auth.uid() then
      raise exception 'Product seller_id must match the signed-in user'
        using errcode = '42501';
    end if;

    if tg_op = 'UPDATE' and new.seller_id is distinct from old.seller_id then
      raise exception 'Product seller_id cannot be changed through the client API'
        using errcode = '42501';
    end if;

    select p.display_name
      into v_display_name
      from public.profiles as p
     where p.id = new.seller_id;

    if v_display_name is null then
      raise exception 'A product seller must have a profile'
        using errcode = '23503';
    end if;

    -- The public listing name comes from the seller's profile, not client input.
    new.seller_name := v_display_name;
  end if;

  return new;
end;
$$;

create trigger profiles_set_updated_at
before update on public.profiles
for each row execute function private.set_updated_at();

create trigger profiles_prevent_role_change
before update on public.profiles
for each row execute function private.prevent_profile_role_change();

create trigger products_set_updated_at
before update on public.products
for each row execute function private.set_updated_at();

create trigger products_sync_seller_name
before insert or update on public.products
for each row execute function private.sync_product_seller_name();

create trigger on_auth_user_created
after insert on auth.users
for each row execute function private.handle_new_auth_user();

commit;

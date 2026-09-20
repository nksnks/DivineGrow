-- DivineGrow Supabase setup. Run in the SQL editor, then create admin users in Authentication.
create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  role text not null default 'user' check (role in ('user', 'admin')),
  created_at timestamptz not null default now()
);

create table if not exists public.enquiries (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  name text not null,
  company text not null,
  email text not null,
  phone text not null,
  product text not null,
  quantity text not null,
  destination text not null,
  timeline text,
  packing text,
  grade text,
  message text not null,
  source text not null default 'website',
  status text not null default 'new' check (status in ('new', 'in_progress', 'quoted', 'closed'))
);

create index if not exists enquiries_created_at_idx on public.enquiries (created_at desc);
create index if not exists enquiries_status_idx on public.enquiries (status);
create index if not exists enquiries_email_idx on public.enquiries (email);

alter table public.profiles enable row level security;
alter table public.enquiries enable row level security;

create or replace function public.is_admin()
returns boolean language sql stable security definer set search_path = public
as $$
  select exists (select 1 from public.profiles where id = auth.uid() and role = 'admin')
    or coalesce((auth.jwt() -> 'app_metadata' ->> 'admin')::boolean, false);
$$;

-- Public visitors can submit enquiries, but cannot read or modify them.
drop policy if exists "Anyone can submit enquiries" on public.enquiries;
create policy "Anyone can submit enquiries" on public.enquiries for insert to anon, authenticated with check (true);
drop policy if exists "Admins can read enquiries" on public.enquiries;
create policy "Admins can read enquiries" on public.enquiries for select to authenticated using (public.is_admin());
drop policy if exists "Admins can update enquiries" on public.enquiries;
create policy "Admins can update enquiries" on public.enquiries for update to authenticated using (public.is_admin()) with check (public.is_admin());

-- Only admins can read profiles; assign admins in SQL or trusted app_metadata.
drop policy if exists "Admins can read profiles" on public.profiles;
create policy "Admins can read profiles" on public.profiles for select to authenticated using (public.is_admin());

-- After creating an auth user, promote them with:
-- insert into public.profiles (id, role) values ('AUTH_USER_UUID', 'admin')
-- on conflict (id) do update set role = 'admin';
-- Never use user_metadata for admin flags: users can edit their own user metadata.

-- Run in Supabase SQL Editor. Run BEFORE inviting any staff.
-- Replace the example email below with the administrator's real email.
create table if not exists public.allowed_staff (
  email text primary key,
  created_at timestamptz not null default now()
);
create table if not exists public.workspaces (
  id integer primary key check (id = 1),
  data jsonb not null,
  revision bigint not null default 0,
  updated_at timestamptz not null default now()
);
insert into public.workspaces(id,data,revision) values (1,'{"students":[],"attendance":{},"exam":{},"notes":{},"settings":{"start":"2026-10-01","end":"2026-11-23","minimum":24,"examDate":"2026-11-23"}}',0) on conflict (id) do nothing;
create or replace function public.is_tks_staff() returns boolean language sql stable security definer set search_path = '' as $$
  select exists(select 1 from public.allowed_staff a where lower(a.email)=lower((select auth.jwt()->>'email')))
$$;
revoke all on function public.is_tks_staff() from public;
grant execute on function public.is_tks_staff() to authenticated;
alter table public.allowed_staff enable row level security;
alter table public.workspaces enable row level security;
revoke all on public.allowed_staff from anon, authenticated;
revoke all on public.workspaces from anon;
grant select, update on public.workspaces to authenticated;
drop policy if exists "approved staff can read workspace" on public.workspaces;
create policy "approved staff can read workspace" on public.workspaces for select to authenticated using (public.is_tks_staff());
drop policy if exists "approved staff can update workspace" on public.workspaces;
create policy "approved staff can update workspace" on public.workspaces for update to authenticated using (public.is_tks_staff()) with check (public.is_tks_staff());
-- In SQL Editor (admin only), add staff:
-- insert into public.allowed_staff(email) values ('admin@example.com') on conflict do nothing;
-- insert into public.allowed_staff(email) values ('coach@example.com') on conflict do nothing;
-- Revoke access:
-- delete from public.allowed_staff where email = 'coach@example.com';
-- For live updates, enable Realtime replication for public.workspaces in Supabase dashboard.

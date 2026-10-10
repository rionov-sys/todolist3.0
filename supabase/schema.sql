-- ============================================================================
-- KeepGrinding — Supabase schema (Opsi A: Auth + Tasks full-cloud)
-- ============================================================================
-- Run once in: Supabase Dashboard → SQL Editor → New query → Run.
--
-- Idempotent: safe to re-run (CREATE ... IF NOT EXISTS + DROP POLICY IF EXISTS).
-- ============================================================================

-- ---------------------------------------------------------------------------
-- 0. GOOGLE SIGN-IN (native idToken flow)
-- ---------------------------------------------------------------------------
--   1. Google Cloud Console → APIs & Services → Credentials
--        • OAuth consent screen → External → add scopes email, profile
--        • Create OAuth client ID → type "Web application"
--          → copy the CLIENT ID  (this is GOOGLE_WEB_CLIENT_ID)
--   2. Supabase Dashboard → Authentication → Providers → Google
--        • enable it, paste the SAME Web client ID + client secret
--        • (Authorized redirect URLs → ignore; native flow needs none)
--   3. Build with:
--        flutter run \
--          --dart-define=SUPABASE_URL=https://xxx.supabase.co \
--          --dart-define=SUPABASE_ANON_KEY=eyJ... \
--          --dart-define=GOOGLE_WEB_CLIENT_ID=xxxx.apps.googleusercontent.com
--   On Android the native picker reads the SHA-1 of your signing keystore, so
--   register an Android OAuth client too (type "Android", package
--   com.keepgrinding.keepgrinding, SHA-1 from: keytool -list -v -keystore
--   ~/.android/debug.keystore -alias androiddebugkey -storepass android).
-- ============================================================================

-- ---------------------------------------------------------------------------
-- 1. tasks — one row per task, owned by the signed-in user
-- ---------------------------------------------------------------------------
create table if not exists public.tasks (
  id              uuid primary key default gen_random_uuid(),
  user_id         uuid not null references auth.users (id) on delete cascade,
  title           text not null default '',
  description     text not null default '',
  category        text not null default 'meeting',
  status          text not null default 'todo',
  date            date not null default current_date,
  time            text not null default '09:00',
  estimate_minutes integer not null default 45,
  progress        integer not null default 0,
  high_priority   boolean not null default false,
  tag             text,
  meta            text,
  points          integer not null default 10,
  updated_at      timestamptz not null default now()
);

-- Index used by the default `.order('date')` + per-user RLS scans.
create index if not exists tasks_user_date_idx
  on public.tasks (user_id, date);

-- ---------------------------------------------------------------------------
-- 2. profiles — display name + productivity focus (mirrors signup metadata)
-- ---------------------------------------------------------------------------
create table if not exists public.profiles (
  id         uuid primary key references auth.users (id) on delete cascade,
  name       text not null default '',
  focus      text not null default 'Pribadi',
  updated_at timestamptz not null default now()
);

-- ---------------------------------------------------------------------------
-- 3. Row Level Security — a user can only ever see and touch their own rows.
--    This is what makes the anon key safe to ship inside the app.
-- ---------------------------------------------------------------------------
alter table public.tasks enable row level security;
alter table public.profiles enable row level security;

-- tasks policies
drop policy if exists "tasks are owner-only select" on public.tasks;
create policy "tasks are owner-only select"
  on public.tasks for select
  using (auth.uid() = user_id);

drop policy if exists "tasks are owner-only insert" on public.tasks;
create policy "tasks are owner-only insert"
  on public.tasks for insert
  with check (auth.uid() = user_id);

drop policy if exists "tasks are owner-only update" on public.tasks;
create policy "tasks are owner-only update"
  on public.tasks for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

drop policy if exists "tasks are owner-only delete" on public.tasks;
create policy "tasks are owner-only delete"
  on public.tasks for delete
  using (auth.uid() = user_id);

-- profiles policies
drop policy if exists "profiles are owner-only select" on public.profiles;
create policy "profiles are owner-only select"
  on public.profiles for select
  using (auth.uid() = id);

drop policy if exists "profiles are owner-only insert" on public.profiles;
create policy "profiles are owner-only insert"
  on public.profiles for insert
  with check (auth.uid() = id);

drop policy if exists "profiles are owner-only update" on public.profiles;
create policy "profiles are owner-only update"
  on public.profiles for update
  using (auth.uid() = id)
  with check (auth.uid() = id);

-- ---------------------------------------------------------------------------
-- 4. Optional: auto-create a profile row on signup.
--    Lets `SupabaseAuthService` upsert instead of insert, and keeps the
--    Profile screen populated even if the client write fails (e.g. offline).
-- ---------------------------------------------------------------------------
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, name, focus)
  values (
    new.id,
    coalesce(new.raw_user_meta_data ->> 'name', ''),
    coalesce(new.raw_user_meta_data ->> 'focus', 'Pribadi')
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ============================================================================
-- Done. Next: Authentication → Providers → enable Email, then either
--   • turn OFF "Confirm email" for instant signup during development, or
--   • leave it ON and confirm the address via the email link.
-- ============================================================================

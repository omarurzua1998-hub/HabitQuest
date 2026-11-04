-- HabitQuest v1 · Ejecutar en Supabase > SQL Editor.
-- RLS: cada usuario puede ver/modificar exclusivamente sus propios registros.
create table if not exists public.habits (
  id uuid primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  name text not null check (char_length(name) between 1 and 65),
  emoji text not null default '✨',
  color text not null default '#52dbc5',
  created_at timestamptz not null,
  updated_at timestamptz not null,
  deleted_at timestamptz
);
create table if not exists public.habit_checks (
  id uuid primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  habit_id uuid not null references public.habits(id) on delete cascade,
  day date not null,
  done boolean not null default false,
  updated_at timestamptz not null,
  unique(user_id, habit_id, day)
);
create index if not exists habits_by_owner on public.habits(user_id);
create index if not exists habit_checks_by_owner_day on public.habit_checks(user_id,day);
alter table public.habits enable row level security;
alter table public.habit_checks enable row level security;
create policy "Own habits select" on public.habits for select to authenticated using ((select auth.uid())=user_id);
create policy "Own habits insert" on public.habits for insert to authenticated with check ((select auth.uid())=user_id);
create policy "Own habits update" on public.habits for update to authenticated using ((select auth.uid())=user_id) with check ((select auth.uid())=user_id);
create policy "Own checks select" on public.habit_checks for select to authenticated using ((select auth.uid())=user_id);
create policy "Own checks insert" on public.habit_checks for insert to authenticated with check ((select auth.uid())=user_id and exists(select 1 from public.habits h where h.id=habit_id and h.user_id=(select auth.uid())));
create policy "Own checks update" on public.habit_checks for update to authenticated using ((select auth.uid())=user_id) with check ((select auth.uid())=user_id and exists(select 1 from public.habits h where h.id=habit_id and h.user_id=(select auth.uid())));
grant select,insert,update on public.habits, public.habit_checks to authenticated;

-- HabitQuest v1.1: ejecutar este bloque adicional si ya instalaste el esquema v1.0.
-- Notas emocionales privadas protegidas con RLS por usuario.
create table if not exists public.mood_entries (
  id uuid primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  day date not null,
  mood text not null check (mood in ('great','good','calm','neutral','anxious','sad','stressed','angry')),
  note text not null default '' check (char_length(note)<=2000),
  updated_at timestamptz not null,
  unique(user_id,day)
);
create index if not exists mood_entries_by_owner_day on public.mood_entries(user_id,day);
alter table public.mood_entries enable row level security;
create policy "Own moods select" on public.mood_entries for select to authenticated using ((select auth.uid())=user_id);
create policy "Own moods insert" on public.mood_entries for insert to authenticated with check ((select auth.uid())=user_id);
create policy "Own moods update" on public.mood_entries for update to authenticated using ((select auth.uid())=user_id) with check ((select auth.uid())=user_id);
grant select,insert,update on public.mood_entries to authenticated;

-- Ejecutar UNA VEZ si ya instalaste HabitQuest v1.0 en Supabase.
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

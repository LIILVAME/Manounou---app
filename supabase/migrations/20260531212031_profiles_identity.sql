-- M1 — Table profiles (1:1 avec auth.users) + trigger bootstrap handle_new_user
-- Stocke le profil étendu du parent : nom, téléphone, avatar, langue, rôle, plan.
-- Le trigger crée automatiquement la ligne profiles dès qu'un compte auth est créé,
-- évitant tout profil orphelin.

-- ============ profiles ============
create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade default auth.uid(),
  first_name text,
  last_name text,
  phone text,
  avatar_url text,
  language text not null default 'fr',
  role text not null default 'parent' check (role in ('parent','nanny','admin')),
  plan text not null default 'free' check (plan in ('free','starter','full')),
  plan_status text not null default 'active' check (plan_status in ('active','past_due','canceled')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- ============ RLS ============
alter table public.profiles enable row level security;

create policy "profiles_self_all" on public.profiles
  for all using (auth.uid() = id) with check (auth.uid() = id);

-- ============ updated_at trigger ============
create trigger trg_profiles_updated_at
  before update on public.profiles
  for each row execute function public.update_updated_at_column();

-- ============ bootstrap trigger ============
-- Crée la ligne profiles dès qu'un utilisateur s'inscrit.
-- SECURITY DEFINER nécessaire pour écrire dans public.profiles depuis le contexte
-- de auth.users (schéma auth). search_path='' pour fixer la résolution des objets.
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.profiles (id, first_name, last_name)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'first_name', split_part(new.email, '@', 1)),
    coalesce(new.raw_user_meta_data->>'last_name', '')
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

-- Le trigger est SECURITY DEFINER mais ne doit pas être appelable via RPC
revoke execute on function public.handle_new_user() from public, anon, authenticated;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

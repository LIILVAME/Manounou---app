-- =====================================================
-- Manounou — Schéma de base (children / events / documents)
-- =====================================================
-- Dérivé EXACTEMENT des DTO Swift (ChildDTO/EventDTO/DocumentDTO).
-- Les colonnes propriétaire (parent_id/owner_id/user_id) utilisent
-- DEFAULT auth.uid() car le client iOS ne les envoie pas à l'insert.
-- Remplace les anciens fichiers de migration incohérents
-- (schema.sql, 20250814170751_*, create_nannies_tables.sql) qui
-- supposaient un schéma différent (owner_id/start_at/full_name…).
-- =====================================================

create extension if not exists pgcrypto;

create or replace function public.update_updated_at_column()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

-- ============ children ============
create table public.children (
  id uuid primary key default gen_random_uuid(),
  parent_id uuid not null references auth.users(id) on delete cascade default auth.uid(),
  first_name text not null,
  last_name text not null,
  birth_date date not null,
  gender text,
  profile_image_url text,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- ============ events ============
create table public.events (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users(id) on delete cascade default auth.uid(),
  child_id uuid references public.children(id) on delete cascade,
  title text not null,
  description text,
  start_date timestamptz not null,
  end_date timestamptz not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint events_valid_range check (end_date >= start_date)
);

-- ============ documents ============
create table public.documents (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade default auth.uid(),
  child_id uuid references public.children(id) on delete cascade,
  title text not null,
  description text,
  document_type text not null,
  file_name text,
  file_url text,
  file_size integer,
  mime_type text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- ============ indexes ============
create index idx_children_parent_id on public.children(parent_id);
create index idx_events_owner_id on public.events(owner_id);
create index idx_events_child_id on public.events(child_id);
create index idx_events_start_date on public.events(start_date);
create index idx_documents_user_id on public.documents(user_id);
create index idx_documents_child_id on public.documents(child_id);

-- ============ updated_at triggers ============
create trigger trg_children_updated_at before update on public.children
  for each row execute function public.update_updated_at_column();
create trigger trg_events_updated_at before update on public.events
  for each row execute function public.update_updated_at_column();
create trigger trg_documents_updated_at before update on public.documents
  for each row execute function public.update_updated_at_column();

-- ============ RLS ============
alter table public.children enable row level security;
alter table public.events enable row level security;
alter table public.documents enable row level security;

create policy "children_owner_all" on public.children
  for all using (auth.uid() = parent_id) with check (auth.uid() = parent_id);
create policy "events_owner_all" on public.events
  for all using (auth.uid() = owner_id) with check (auth.uid() = owner_id);
create policy "documents_owner_all" on public.documents
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

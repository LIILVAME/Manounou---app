-- Household members — membres du foyer / intervenants liés à un compte parent.
-- Utilisé pour les sélecteurs "Déposé par / Récupéré par" dans le planning.

create table public.household_members (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid not null references auth.users(id) on delete cascade,
  name       text not null,
  color      text not null default '#7A5AE0',
  role       text not null default 'parent'
             check (role in ('parent', 'nounou', 'babysitter', 'other')),
  sort_order int  not null default 0,
  created_at timestamptz not null default now()
);

alter table public.household_members enable row level security;

create policy "household_members_owner" on public.household_members
  using  (user_id = auth.uid())
  with check (user_id = auth.uid());

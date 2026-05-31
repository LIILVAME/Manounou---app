-- Planning schedules — configuration de garde persistée par utilisateur.
-- Une seule ligne par user (UNIQUE sur user_id + ON CONFLICT dans upsert).

create table public.planning_schedules (
  id            uuid primary key default gen_random_uuid(),
  user_id       uuid not null references auth.users(id) on delete cascade,
  schedule_mode int  not null default 0,              -- 0=fixe, 1=roulement
  active_days   int[] not null default '{1,2,3,4,5}', -- 1=lun … 7=dim
  drop_time     text not null default '09:00',
  pick_time     text not null default '17:00',
  drop_by       text not null default 'Papa',
  pick_by       text not null default 'Maman',
  carer_name    text not null default 'la nounou',
  updated_at    timestamptz not null default now()
);

alter table public.planning_schedules enable row level security;

create policy "planning_schedules_owner" on public.planning_schedules
  using  (user_id = auth.uid())
  with check (user_id = auth.uid());

create unique index planning_schedules_user_id_key
  on public.planning_schedules(user_id);

create trigger trg_planning_schedules_updated_at
  before update on public.planning_schedules
  for each row execute function public.update_updated_at_column();

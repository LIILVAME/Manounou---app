-- Plans — configuration des offres d'abonnement (lecture publique).
-- Les quotas et tarifs sont ici, plus dans le code Swift.

create table public.plans (
  id            text primary key,
  display_name  text not null,
  price_label   text not null,
  max_children  int  not null,
  max_documents int  not null,
  color_hex     text not null
);

alter table public.plans enable row level security;

create policy "plans_public_read" on public.plans
  for select using (true);

insert into public.plans (id, display_name, price_label, max_children, max_documents, color_hex) values
  ('free',    'Gratuit', '0€/mois',  2,  10,   '#9CA3AF'),
  ('starter', 'Starter', '9€/mois',  5,  100,  '#3B82F6'),
  ('full',    'Complet', '19€/mois', 20, 1000, '#8B5CF6');

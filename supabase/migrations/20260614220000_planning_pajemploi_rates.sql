-- =====================================================
-- Manounou — Taux Pajemploi du foyer (planning_schedules)
-- =====================================================
-- Ajoute les taux qui alimentent le calcul RÉEL de la déclaration mensuelle
-- Pajemploi (heures × taux net, jours × indemnités). Jusqu'ici le planning ne
-- portait que les horaires : les montants affichés à l'écran étaient des
-- données de démonstration codées en dur (PajemploiDeclaration.sample).
--
-- Additif et non destructif : ADD COLUMN ... NOT NULL DEFAULT, donc les lignes
-- existantes reçoivent le barème indicatif par défaut. Les défauts SQL sont
-- alignés sur ceux du modèle Swift `PlanningSchedule`
-- (Manounou/Services/PlanningScheduleService.swift).
--
-- RLS inchangée (policy `planning_schedules_owner` déjà en place) : aucun
-- nouveau finding `security` attendu (à valider via get_advisors après apply,
-- une fois le projet Supabase réactivé).
-- =====================================================

alter table public.planning_schedules
  add column if not exists net_hourly_rate numeric(6,2) not null default 4.50,
  add column if not exists upkeep_per_day  numeric(6,2) not null default 3.50,
  add column if not exists meal_per_day    numeric(6,2) not null default 0.00;

comment on column public.planning_schedules.net_hourly_rate is 'Taux horaire net de la nounou (EUR/h) — base du salaire net declare.';
comment on column public.planning_schedules.upkeep_per_day  is 'Indemnite d''entretien par jour de garde (EUR/j).';
comment on column public.planning_schedules.meal_per_day    is 'Indemnite repas par jour de garde (EUR/j), optionnelle.';

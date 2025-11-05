-- ============================================
-- MANOUNOU - Schéma Horaires (Schedules)
-- Version: 1.0.0
-- Date: 2025-01-13
-- ============================================

-- Table schedules - Planning principal d'un enfant
CREATE TABLE IF NOT EXISTS public.schedules (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  child_id UUID NOT NULL REFERENCES public.children(id) ON DELETE CASCADE,
  type TEXT NOT NULL CHECK (type IN ('regular', 'daily', 'punctual')),
  -- 'regular' : horaire récurrent hebdomadaire
  -- 'daily' : horaire variable par jour
  -- 'punctual' : horaire ponctuel pour une date précise
  name TEXT, -- Nom du planning (ex: "Garderie", "École", "Nounou")
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Table schedule_items - Horaires détaillés (dépôt/récupération)
CREATE TABLE IF NOT EXISTS public.schedule_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  schedule_id UUID NOT NULL REFERENCES public.schedules(id) ON DELETE CASCADE,
  day_of_week INTEGER CHECK (day_of_week BETWEEN 0 AND 6), -- 0 = Dimanche, 1 = Lundi, etc. NULL pour ponctuel
  date DATE, -- Date spécifique pour horaire ponctuel (NULL pour récurrent)
  drop_off_time TIME, -- Heure de dépôt (HH:MM)
  pick_up_time TIME, -- Heure de récupération (HH:MM)
  notes TEXT, -- Notes optionnelles (ex: "Vestiaire A")
  is_exception BOOLEAN DEFAULT FALSE, -- Exception sur un planning régulier
  parent_schedule_item_id UUID REFERENCES public.schedule_items(id) ON DELETE SET NULL, -- Référence à l'item régulier si exception
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  -- Contrainte : soit day_of_week (récurrent), soit date (ponctuel)
  CONSTRAINT check_day_or_date CHECK (
    (day_of_week IS NOT NULL AND date IS NULL) OR
    (day_of_week IS NULL AND date IS NOT NULL)
  )
);

-- Index pour performances
CREATE INDEX IF NOT EXISTS idx_schedules_child_id ON public.schedules(child_id);
CREATE INDEX IF NOT EXISTS idx_schedules_type ON public.schedules(type);
CREATE INDEX IF NOT EXISTS idx_schedule_items_schedule_id ON public.schedule_items(schedule_id);
CREATE INDEX IF NOT EXISTS idx_schedule_items_day_of_week ON public.schedule_items(day_of_week);
CREATE INDEX IF NOT EXISTS idx_schedule_items_date ON public.schedule_items(date);

-- Fonction pour mettre à jour updated_at automatiquement
CREATE OR REPLACE FUNCTION update_schedule_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_schedules_updated_at
  BEFORE UPDATE ON public.schedules
  FOR EACH ROW
  EXECUTE FUNCTION update_schedule_updated_at();

CREATE TRIGGER update_schedule_items_updated_at
  BEFORE UPDATE ON public.schedule_items
  FOR EACH ROW
  EXECUTE FUNCTION update_schedule_updated_at();

-- Vue pour faciliter les requêtes (horaires actifs par enfant)
CREATE OR REPLACE VIEW public.active_schedules_view AS
SELECT 
  s.id as schedule_id,
  s.child_id,
  s.type,
  s.name,
  si.id as item_id,
  si.day_of_week,
  si.date,
  si.drop_off_time,
  si.pick_up_time,
  si.is_exception,
  si.notes
FROM public.schedules s
INNER JOIN public.schedule_items si ON s.id = si.schedule_id
WHERE s.is_active = TRUE
ORDER BY s.child_id, si.date, si.day_of_week;


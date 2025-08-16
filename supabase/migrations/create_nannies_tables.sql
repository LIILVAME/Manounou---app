-- Migration: Create nannies and related tables
-- Description: Tables pour la gestion des nannies et des dépôts d'enfants

-- Table des nannies
CREATE TABLE IF NOT EXISTS nannies (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  phone TEXT NOT NULL,
  email TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table de liaison enfants-nannies (many-to-many)
CREATE TABLE IF NOT EXISTS child_nannies (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  child_id UUID NOT NULL REFERENCES children(id) ON DELETE CASCADE,
  nanny_id UUID NOT NULL REFERENCES nannies(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(child_id, nanny_id)
);

-- Table des dépôts/récupérations
CREATE TABLE IF NOT EXISTS dropoffs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  child_id UUID NOT NULL REFERENCES children(id) ON DELETE CASCADE,
  nanny_id UUID NOT NULL REFERENCES nannies(id) ON DELETE CASCADE,
  dropoff_time TIMESTAMP WITH TIME ZONE NOT NULL,
  expected_pickup_time TIMESTAMP WITH TIME ZONE NOT NULL,
  actual_pickup_time TIMESTAMP WITH TIME ZONE,
  status TEXT NOT NULL DEFAULT 'scheduled' CHECK (status IN ('scheduled', 'in_progress', 'completed', 'cancelled')),
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS sur toutes les tables
ALTER TABLE nannies ENABLE ROW LEVEL SECURITY;
ALTER TABLE child_nannies ENABLE ROW LEVEL SECURITY;
ALTER TABLE dropoffs ENABLE ROW LEVEL SECURITY;

-- Policies pour les nannies
CREATE POLICY "Users can manage their own nannies" ON nannies
  FOR ALL USING (auth.uid() IS NOT NULL);

-- Policies pour child_nannies
CREATE POLICY "Users can manage their child-nanny associations" ON child_nannies
  FOR ALL USING (auth.uid() IS NOT NULL);

-- Policies pour dropoffs
CREATE POLICY "Users can manage their dropoffs" ON dropoffs
  FOR ALL USING (auth.uid() IS NOT NULL);

-- Fonction pour mettre à jour updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Triggers pour updated_at
CREATE TRIGGER update_nannies_updated_at BEFORE UPDATE ON nannies
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_dropoffs_updated_at BEFORE UPDATE ON dropoffs
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Index pour optimiser les performances
CREATE INDEX IF NOT EXISTS idx_child_nannies_child_id ON child_nannies(child_id);
CREATE INDEX IF NOT EXISTS idx_child_nannies_nanny_id ON child_nannies(nanny_id);
CREATE INDEX IF NOT EXISTS idx_dropoffs_child_id ON dropoffs(child_id);
CREATE INDEX IF NOT EXISTS idx_dropoffs_nanny_id ON dropoffs(nanny_id);
CREATE INDEX IF NOT EXISTS idx_dropoffs_status ON dropoffs(status);
CREATE INDEX IF NOT EXISTS idx_dropoffs_dropoff_time ON dropoffs(dropoff_time);

-- Données de test (optionnel)
INSERT INTO nannies (name, phone, email) VALUES 
  ('Marie Dubois', '+33123456789', 'marie.dubois@email.com'),
  ('Sophie Martin', '+33987654321', 'sophie.martin@email.com'),
  ('Claire Rousseau', '+33555666777', NULL)
ON CONFLICT DO NOTHING;
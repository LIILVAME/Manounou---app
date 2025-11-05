-- ============================================
-- Migration: Ajout gender aux enfants
-- Date: 2025-01-13
-- ============================================

-- Ajouter la colonne gender à la table children
ALTER TABLE public.children
ADD COLUMN IF NOT EXISTS gender TEXT CHECK (gender IN ('M', 'F'));

-- Commentaire pour documentation
COMMENT ON COLUMN public.children.gender IS 'Genre de l''enfant: M (Masculin) ou F (Féminin). Utilisé pour sélectionner aléatoirement un avatar Studio Ghibli';


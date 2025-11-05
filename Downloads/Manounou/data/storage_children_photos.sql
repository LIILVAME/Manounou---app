-- ============================================
-- MANOUNOU - Storage Photos Enfants
-- Version: 1.0.0
-- Date: 2025-01-13
-- ============================================

-- Créer le bucket "children-photos" pour stocker les photos d'enfants
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'children-photos',
  'children-photos',
  false, -- Bucket privé (non public)
  5242880, -- 5MB max par photo
  ARRAY[
    'image/jpeg',
    'image/png',
    'image/heic',
    'image/webp'
  ]
)
ON CONFLICT (id) DO NOTHING;

-- ============================================
-- POLICIES STORAGE - Accès sécurisé aux photos enfants
-- ============================================

-- Policy : Utilisateurs authentifiés peuvent uploader des photos pour leurs enfants
-- Structure : children-photos/{user_id}/{child_id}/{filename}
CREATE POLICY "Users can upload photos for their children"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'children-photos' AND
  auth.uid()::text = (storage.foldername(name))[1]
);

-- Policy : Utilisateurs authentifiés peuvent lire les photos de leurs enfants
CREATE POLICY "Users can read photos of their children"
ON storage.objects
FOR SELECT
TO authenticated
USING (
  bucket_id = 'children-photos' AND
  auth.uid()::text = (storage.foldername(name))[1]
);

-- Policy : Utilisateurs authentifiés peuvent supprimer les photos de leurs enfants
CREATE POLICY "Users can delete photos of their children"
ON storage.objects
FOR DELETE
TO authenticated
USING (
  bucket_id = 'children-photos' AND
  auth.uid()::text = (storage.foldername(name))[1]
);

-- Policy : Utilisateurs authentifiés peuvent mettre à jour les photos de leurs enfants
CREATE POLICY "Users can update photos of their children"
ON storage.objects
FOR UPDATE
TO authenticated
USING (
  bucket_id = 'children-photos' AND
  auth.uid()::text = (storage.foldername(name))[1]
)
WITH CHECK (
  bucket_id = 'children-photos' AND
  auth.uid()::text = (storage.foldername(name))[1]
);


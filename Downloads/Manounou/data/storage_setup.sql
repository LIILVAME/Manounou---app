-- ============================================
-- MANOUNOU - Configuration Storage Supabase
-- Version: 1.0.0
-- Date: 2025-01-13
-- ============================================

-- Créer le bucket "documents" pour stocker les fichiers
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'documents',
  'documents',
  false, -- Bucket privé (non public)
  52428800, -- 50MB max par fichier
  ARRAY[
    'image/jpeg',
    'image/png',
    'image/heic',
    'application/pdf',
    'application/msword',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
  ]
)
ON CONFLICT (id) DO NOTHING;

-- ============================================
-- POLICIES STORAGE - Accès sécurisé aux documents
-- ============================================

-- Policy : Utilisateurs authentifiés peuvent uploader leurs propres documents
-- Structure : documents/{user_id}/{filename}
CREATE POLICY "Users can upload their own documents"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'documents' AND
  auth.uid()::text = (storage.foldername(name))[1]
);

-- Policy : Utilisateurs authentifiés peuvent lire leurs propres documents
CREATE POLICY "Users can read their own documents"
ON storage.objects
FOR SELECT
TO authenticated
USING (
  bucket_id = 'documents' AND
  auth.uid()::text = (storage.foldername(name))[1]
);

-- Policy : Utilisateurs authentifiés peuvent supprimer leurs propres documents
CREATE POLICY "Users can delete their own documents"
ON storage.objects
FOR DELETE
TO authenticated
USING (
  bucket_id = 'documents' AND
  auth.uid()::text = (storage.foldername(name))[1]
);

-- Policy : Utilisateurs authentifiés peuvent mettre à jour leurs propres documents
CREATE POLICY "Users can update their own documents"
ON storage.objects
FOR UPDATE
TO authenticated
USING (
  bucket_id = 'documents' AND
  auth.uid()::text = (storage.foldername(name))[1]
)
WITH CHECK (
  bucket_id = 'documents' AND
  auth.uid()::text = (storage.foldername(name))[1]
);


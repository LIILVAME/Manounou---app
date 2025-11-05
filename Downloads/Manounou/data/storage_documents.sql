-- ============================================
-- MANOUNOU - Storage Bucket pour Documents
-- Version: 1.0.0
-- Date: 2025-01-13
-- ============================================

-- ============================================
-- MISE À JOUR DU BUCKET "documents"
-- Supprimer les restrictions MIME types pour autoriser tous les fichiers (PDF inclus)
-- ============================================

-- Supprimer toutes les restrictions de types MIME
-- NULL = autoriser TOUS les types MIME (images, PDF, documents, etc.)
UPDATE storage.buckets
SET 
  allowed_mime_types = NULL,
  public = true,
  file_size_limit = 52428800  -- 50MB max
WHERE id = 'documents';

-- Si le bucket n'existe pas encore, le créer sans restriction MIME
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
SELECT 
  'documents',
  'documents',
  true,
  52428800,
  NULL  -- NULL = autoriser tous les types
WHERE NOT EXISTS (
  SELECT 1 FROM storage.buckets WHERE id = 'documents'
);

-- ============================================
-- RLS Policies pour Storage "documents"
-- ============================================

-- Policy: Parents can upload documents for their children
-- Structure du chemin : {child_id}/{filename}
DROP POLICY IF EXISTS "Parents can upload documents" ON storage.objects;
CREATE POLICY "Parents can upload documents"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'documents' AND
  auth.uid() IN (
    SELECT parent_id 
    FROM public.children 
    WHERE id::text = (string_to_array(name, '/'))[1]
  )
);

-- Policy: Parents can view documents for their children
DROP POLICY IF EXISTS "Parents can view documents" ON storage.objects;
CREATE POLICY "Parents can view documents"
ON storage.objects
FOR SELECT
TO authenticated
USING (
  bucket_id = 'documents' AND
  (
    -- Public read pour tous les documents (car bucket public)
    true
    OR
    auth.uid() IN (
      SELECT parent_id 
      FROM public.children 
      WHERE id::text = (string_to_array(name, '/'))[1]
    )
  )
);

-- Policy: Parents can update documents for their children
DROP POLICY IF EXISTS "Parents can update documents" ON storage.objects;
CREATE POLICY "Parents can update documents"
ON storage.objects
FOR UPDATE
TO authenticated
USING (
  bucket_id = 'documents' AND
  auth.uid() IN (
    SELECT parent_id 
    FROM public.children 
    WHERE id::text = (string_to_array(name, '/'))[1]
  )
)
WITH CHECK (
  bucket_id = 'documents' AND
  auth.uid() IN (
    SELECT parent_id 
    FROM public.children 
    WHERE id::text = (string_to_array(name, '/'))[1]
  )
);

-- Policy: Parents can delete documents for their children
DROP POLICY IF EXISTS "Parents can delete documents" ON storage.objects;
CREATE POLICY "Parents can delete documents"
ON storage.objects
FOR DELETE
TO authenticated
USING (
  bucket_id = 'documents' AND
  auth.uid() IN (
    SELECT parent_id 
    FROM public.children 
    WHERE id::text = (string_to_array(name, '/'))[1]
  )
);


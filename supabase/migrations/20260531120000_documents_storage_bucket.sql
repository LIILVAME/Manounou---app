-- Manounou — Stockage des pièces jointes de documents
--
-- Crée le bucket Storage privé `documents` et les policies RLS sur
-- storage.objects. Modèle de sécurité : chaque utilisateur ne peut lire/écrire
-- que les objets rangés sous un dossier portant son propre `auth.uid()`
-- (chemin = "<uid>/<uuid>_<nom_fichier>"). Bucket privé → accès uniquement via
-- URL signée générée côté client authentifié. Cohérent avec la RLS des tables
-- (events.owner_id, documents.user_id = auth.uid()).

-- 1) Bucket privé (idempotent)
insert into storage.buckets (id, name, public)
values ('documents', 'documents', false)
on conflict (id) do nothing;

-- 2) Policies RLS sur storage.objects, scopées au dossier <uid>/
--    (storage.objects a déjà RLS activée par défaut sur Supabase)

drop policy if exists "documents_read_own" on storage.objects;
create policy "documents_read_own"
  on storage.objects for select
  to authenticated
  using (
    bucket_id = 'documents'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

drop policy if exists "documents_insert_own" on storage.objects;
create policy "documents_insert_own"
  on storage.objects for insert
  to authenticated
  with check (
    bucket_id = 'documents'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

drop policy if exists "documents_update_own" on storage.objects;
create policy "documents_update_own"
  on storage.objects for update
  to authenticated
  using (
    bucket_id = 'documents'
    and (storage.foldername(name))[1] = auth.uid()::text
  )
  with check (
    bucket_id = 'documents'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

drop policy if exists "documents_delete_own" on storage.objects;
create policy "documents_delete_own"
  on storage.objects for delete
  to authenticated
  using (
    bucket_id = 'documents'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

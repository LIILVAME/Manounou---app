-- =====================================================
-- CONFIGURATION SUPABASE POUR MANOUNOU
-- =====================================================
-- Copiez et collez ce script dans le SQL Editor de votre dashboard Supabase
-- URL: https://app.supabase.com/project/emgrtgencepzainsknsb/sql

-- =====================================================
-- 1. TABLE DES PROFILS UTILISATEURS
-- =====================================================

-- Créer la table des profils
CREATE TABLE IF NOT EXISTS profiles (
  id UUID REFERENCES auth.users(id) PRIMARY KEY,
  first_name TEXT NOT NULL,
  last_name TEXT NOT NULL,
  email TEXT NOT NULL,
  avatar_url TEXT,
  phone TEXT,
  date_of_birth DATE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Activer Row Level Security
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Politiques de sécurité pour les profils
DROP POLICY IF EXISTS "Users can view own profile" ON profiles;
CREATE POLICY "Users can view own profile" ON profiles
  FOR SELECT USING (auth.uid() = id);

DROP POLICY IF EXISTS "Users can update own profile" ON profiles;
CREATE POLICY "Users can update own profile" ON profiles
  FOR UPDATE USING (auth.uid() = id);

DROP POLICY IF EXISTS "Users can insert own profile" ON profiles;
CREATE POLICY "Users can insert own profile" ON profiles
  FOR INSERT WITH CHECK (auth.uid() = id);

-- =====================================================
-- 2. TABLE DES ENFANTS
-- =====================================================

-- Créer la table des enfants
CREATE TABLE IF NOT EXISTS children (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  parent_id UUID REFERENCES auth.users(id) NOT NULL,
  first_name TEXT NOT NULL,
  last_name TEXT NOT NULL,
  date_of_birth DATE NOT NULL,
  gender TEXT CHECK (gender IN ('male', 'female', 'other')),
  avatar_url TEXT,
  medical_info JSONB DEFAULT '{}',
  emergency_contact JSONB DEFAULT '{}',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Activer Row Level Security
ALTER TABLE children ENABLE ROW LEVEL SECURITY;

-- Politiques de sécurité pour les enfants
DROP POLICY IF EXISTS "Users can view own children" ON children;
CREATE POLICY "Users can view own children" ON children
  FOR SELECT USING (auth.uid() = parent_id);

DROP POLICY IF EXISTS "Users can update own children" ON children;
CREATE POLICY "Users can update own children" ON children
  FOR UPDATE USING (auth.uid() = parent_id);

DROP POLICY IF EXISTS "Users can insert own children" ON children;
CREATE POLICY "Users can insert own children" ON children
  FOR INSERT WITH CHECK (auth.uid() = parent_id);

DROP POLICY IF EXISTS "Users can delete own children" ON children;
CREATE POLICY "Users can delete own children" ON children
  FOR DELETE USING (auth.uid() = parent_id);

-- =====================================================
-- 3. TABLE DES ÉVÉNEMENTS/CALENDRIER (SUPPRIMÉE - VOIR SECTION 3 PLUS BAS)
-- =====================================================
-- Cette section a été supprimée pour éviter les doublons.
-- La définition correcte de la table events se trouve dans la section 3 ci-dessous.

-- =====================================================
-- 4. TABLE DES DOCUMENTS
-- =====================================================

-- Créer la table des documents
CREATE TABLE IF NOT EXISTS documents (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  parent_id UUID REFERENCES auth.users(id) NOT NULL,
  child_id UUID REFERENCES children(id),
  title TEXT NOT NULL,
  description TEXT,
  document_type TEXT NOT NULL CHECK (document_type IN ('medical', 'school', 'identity', 'insurance', 'vaccination', 'other')),
  file_url TEXT,
  file_name TEXT,
  file_size INTEGER,
  mime_type TEXT,
  tags TEXT[] DEFAULT '{}',
  is_favorite BOOLEAN DEFAULT FALSE,
  metadata JSONB DEFAULT '{}',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Activer Row Level Security
ALTER TABLE documents ENABLE ROW LEVEL SECURITY;

-- Politiques de sécurité pour les documents
DROP POLICY IF EXISTS "Users can view own documents" ON documents;
CREATE POLICY "Users can view own documents" ON documents
  FOR SELECT USING (auth.uid() = parent_id);

DROP POLICY IF EXISTS "Users can update own documents" ON documents;
CREATE POLICY "Users can update own documents" ON documents
  FOR UPDATE USING (auth.uid() = parent_id);

DROP POLICY IF EXISTS "Users can insert own documents" ON documents;
CREATE POLICY "Users can insert own documents" ON documents
  FOR INSERT WITH CHECK (auth.uid() = parent_id);

DROP POLICY IF EXISTS "Users can delete own documents" ON documents;
CREATE POLICY "Users can delete own documents" ON documents
  FOR DELETE USING (auth.uid() = parent_id);

-- =====================================================
-- 5. TABLE DES RELATIONS FAMILIALES
-- =====================================================

-- Créer la table des relations familiales
CREATE TABLE IF NOT EXISTS family_relationships (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) NOT NULL,
  related_user_id UUID REFERENCES auth.users(id) NOT NULL,
  relationship_type TEXT NOT NULL CHECK (relationship_type IN ('spouse', 'parent', 'child', 'sibling', 'grandparent', 'other')),
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'declined', 'blocked')),
  permissions JSONB DEFAULT '{"view_children": false, "edit_children": false, "view_events": false, "edit_events": false}',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, related_user_id)
);

-- Activer Row Level Security
ALTER TABLE family_relationships ENABLE ROW LEVEL SECURITY;

-- Politiques de sécurité pour les relations familiales
DROP POLICY IF EXISTS "Users can view own relationships" ON family_relationships;
CREATE POLICY "Users can view own relationships" ON family_relationships
  FOR SELECT USING (auth.uid() = user_id OR auth.uid() = related_user_id);

DROP POLICY IF EXISTS "Users can update own relationships" ON family_relationships;
CREATE POLICY "Users can update own relationships" ON family_relationships
  FOR UPDATE USING (auth.uid() = user_id OR auth.uid() = related_user_id);

DROP POLICY IF EXISTS "Users can insert own relationships" ON family_relationships;
CREATE POLICY "Users can insert own relationships" ON family_relationships
  FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete own relationships" ON family_relationships;
CREATE POLICY "Users can delete own relationships" ON family_relationships
  FOR DELETE USING (auth.uid() = user_id);

-- =====================================================
-- 3. TABLE DES ÉVÉNEMENTS
-- =====================================================

-- Créer la table des événements
CREATE TABLE IF NOT EXISTS events (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  parent_id UUID REFERENCES auth.users(id) NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  event_type TEXT NOT NULL CHECK (event_type IN ('medical', 'school', 'activity', 'family', 'other')),
  start_date TIMESTAMP WITH TIME ZONE NOT NULL,
  end_date TIMESTAMP WITH TIME ZONE,
  child_id UUID REFERENCES children(id),
  location TEXT,
  reminder_minutes INTEGER DEFAULT 15,
  is_recurring BOOLEAN DEFAULT FALSE,
  recurrence_pattern JSONB DEFAULT '{}',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Activer Row Level Security
ALTER TABLE events ENABLE ROW LEVEL SECURITY;

-- Politiques de sécurité pour les événements
DROP POLICY IF EXISTS "Users can view own events" ON events;
CREATE POLICY "Users can view own events" ON events
  FOR SELECT USING (auth.uid() = parent_id);

DROP POLICY IF EXISTS "Users can insert own events" ON events;
CREATE POLICY "Users can insert own events" ON events
  FOR INSERT WITH CHECK (auth.uid() = parent_id);

DROP POLICY IF EXISTS "Users can update own events" ON events;
CREATE POLICY "Users can update own events" ON events
  FOR UPDATE USING (auth.uid() = parent_id);

DROP POLICY IF EXISTS "Users can delete own events" ON events;
CREATE POLICY "Users can delete own events" ON events
  FOR DELETE USING (auth.uid() = parent_id);

-- Index pour améliorer les performances
CREATE INDEX IF NOT EXISTS idx_events_parent_id ON events(parent_id);
CREATE INDEX IF NOT EXISTS idx_events_start_date ON events(start_date);
CREATE INDEX IF NOT EXISTS idx_events_child_id ON events(child_id);
CREATE INDEX IF NOT EXISTS idx_events_type ON events(event_type);

-- =====================================================
-- 4. FONCTIONS ET TRIGGERS
-- =====================================================

-- Fonction pour mettre à jour updated_at automatiquement
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Triggers pour mettre à jour updated_at sur toutes les tables
CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON profiles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_children_updated_at BEFORE UPDATE ON children
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_events_updated_at BEFORE UPDATE ON events
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_documents_updated_at BEFORE UPDATE ON documents
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_family_relationships_updated_at BEFORE UPDATE ON family_relationships
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- 7. FONCTION POUR CRÉER UN PROFIL AUTOMATIQUEMENT
-- =====================================================

-- Fonction pour créer automatiquement un profil lors de l'inscription
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, first_name, last_name, email)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'first_name', 'Prénom'),
    COALESCE(NEW.raw_user_meta_data->>'last_name', 'Nom'),
    NEW.email
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger pour créer automatiquement un profil
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- =====================================================
-- 8. INDEXES POUR OPTIMISER LES PERFORMANCES
-- =====================================================

-- Index pour les enfants par parent
CREATE INDEX IF NOT EXISTS idx_children_parent_id ON children(parent_id);

-- Index pour les événements par utilisateur et date
CREATE INDEX IF NOT EXISTS idx_events_parent_date ON events(parent_id, start_date);

-- Index pour les documents par utilisateur et type
CREATE INDEX IF NOT EXISTS idx_documents_user_type ON documents(user_id, document_type);
CREATE INDEX IF NOT EXISTS idx_documents_child_id ON documents(child_id);

-- Index pour les relations familiales
CREATE INDEX IF NOT EXISTS idx_family_relationships_users ON family_relationships(user_id, related_user_id);

-- =====================================================
-- 9. CONFIGURATION DU STOCKAGE (STORAGE)
-- =====================================================

-- Créer un bucket pour les documents
INSERT INTO storage.buckets (id, name, public)
VALUES ('documents', 'documents', false)
ON CONFLICT (id) DO NOTHING;

-- Créer un bucket pour les avatars
INSERT INTO storage.buckets (id, name, public)
VALUES ('avatars', 'avatars', true)
ON CONFLICT (id) DO NOTHING;

-- Politiques de sécurité pour le stockage des documents
DROP POLICY IF EXISTS "Users can upload own documents" ON storage.objects;
CREATE POLICY "Users can upload own documents" ON storage.objects
  FOR INSERT WITH CHECK (
    bucket_id = 'documents' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );

DROP POLICY IF EXISTS "Users can view own documents" ON storage.objects;
CREATE POLICY "Users can view own documents" ON storage.objects
  FOR SELECT USING (
    bucket_id = 'documents' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );

DROP POLICY IF EXISTS "Users can update own documents" ON storage.objects;
CREATE POLICY "Users can update own documents" ON storage.objects
  FOR UPDATE USING (
    bucket_id = 'documents' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );

DROP POLICY IF EXISTS "Users can delete own documents" ON storage.objects;
CREATE POLICY "Users can delete own documents" ON storage.objects
  FOR DELETE USING (
    bucket_id = 'documents' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );

-- Politiques de sécurité pour le stockage des avatars
DROP POLICY IF EXISTS "Users can upload own avatars" ON storage.objects;
CREATE POLICY "Users can upload own avatars" ON storage.objects
  FOR INSERT WITH CHECK (
    bucket_id = 'avatars' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );

DROP POLICY IF EXISTS "Anyone can view avatars" ON storage.objects;
CREATE POLICY "Anyone can view avatars" ON storage.objects
  FOR SELECT USING (bucket_id = 'avatars');

DROP POLICY IF EXISTS "Users can update own avatars" ON storage.objects;
CREATE POLICY "Users can update own avatars" ON storage.objects
  FOR UPDATE USING (
    bucket_id = 'avatars' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );

DROP POLICY IF EXISTS "Users can delete own avatars" ON storage.objects;
CREATE POLICY "Users can delete own avatars" ON storage.objects
  FOR DELETE USING (
    bucket_id = 'avatars' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );

-- =====================================================
-- 10. DONNÉES DE TEST (OPTIONNEL)
-- =====================================================

-- Vous pouvez décommenter ces lignes pour créer des données de test
-- après avoir créé votre premier utilisateur

/*
-- Exemple d'insertion d'un enfant (remplacez l'UUID par votre ID utilisateur)
INSERT INTO children (parent_id, first_name, last_name, date_of_birth, gender)
VALUES (
  'YOUR_USER_ID_HERE',
  'Emma',
  'Dupont',
  '2018-05-15',
  'female'
);

-- Exemple d'insertion d'un événement
INSERT INTO events (parent_id, title, description, event_type, start_date)
VALUES (
  'YOUR_USER_ID_HERE',
  'Rendez-vous pédiatre',
  'Visite de contrôle annuelle',
  'medical',
  NOW() + INTERVAL '1 week'
);
*/

-- =====================================================
-- SCRIPT TERMINÉ
-- =====================================================
-- Toutes les tables et configurations sont maintenant créées !
-- Votre application Manounou peut maintenant fonctionner pleinement.
-- 
-- Prochaines étapes :
-- 1. Testez l'inscription dans votre app
-- 2. Vérifiez que le profil est créé automatiquement
-- 3. Testez les fonctionnalités de l'application
-- =====================================================
-- =====================================================
-- MIGRATION : CORRECTION DES TABLES SUPABASE
-- Date: 14 Août 2025
-- Objectif: Corriger les incohérences identifiées dans l'audit 360°
-- =====================================================

-- =====================================================
-- 1. CORRECTION TABLE CHILDREN - AJOUT CHAMPS MANQUANTS
-- =====================================================

-- Ajouter les champs manquants identifiés dans l'audit
ALTER TABLE children 
ADD COLUMN IF NOT EXISTS allergies TEXT,
ADD COLUMN IF NOT EXISTS medical_notes TEXT,
ADD COLUMN IF NOT EXISTS emergency_contact_name TEXT,
ADD COLUMN IF NOT EXISTS emergency_contact_phone TEXT;

-- Mettre à jour la structure medical_info pour inclure les nouveaux champs
COMMENT ON COLUMN children.allergies IS 'Allergies connues de l\'enfant';
COMMENT ON COLUMN children.medical_notes IS 'Notes médicales importantes';
COMMENT ON COLUMN children.emergency_contact_name IS 'Nom du contact d\'urgence';
COMMENT ON COLUMN children.emergency_contact_phone IS 'Téléphone du contact d\'urgence';

-- =====================================================
-- 2. CORRECTION TABLE EVENTS - AJOUT CHAMPS MANQUANTS
-- =====================================================

-- Ajouter les champs manquants pour compatibilité avec React Native
ALTER TABLE events 
ADD COLUMN IF NOT EXISTS all_day BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS notes TEXT,
ADD COLUMN IF NOT EXISTS status TEXT DEFAULT 'confirmed' CHECK (status IN ('confirmed', 'pending', 'cancelled'));

-- Ajouter commentaires pour clarification
COMMENT ON COLUMN events.all_day IS 'Événement sur toute la journée';
COMMENT ON COLUMN events.notes IS 'Notes additionnelles sur l\'événement';
COMMENT ON COLUMN events.status IS 'Statut de l\'événement';

-- =====================================================
-- 3. CORRECTION TABLE DOCUMENTS - AJOUT CHAMPS MANQUANTS
-- =====================================================

-- Ajouter les champs manquants pour compatibilité
ALTER TABLE documents 
ADD COLUMN IF NOT EXISTS file_type TEXT,
ADD COLUMN IF NOT EXISTS uploaded_by UUID REFERENCES auth.users(id);

-- Mettre à jour les contraintes pour file_url (optionnel)
ALTER TABLE documents ALTER COLUMN file_url DROP NOT NULL;
ALTER TABLE documents ALTER COLUMN file_name DROP NOT NULL;

-- Ajouter commentaires
COMMENT ON COLUMN documents.file_type IS 'Type MIME du fichier';
COMMENT ON COLUMN documents.uploaded_by IS 'Utilisateur qui a uploadé le document';

-- =====================================================
-- 4. CORRECTION DES INDEX ERRONÉS
-- =====================================================

-- Supprimer l'index incorrect identifié dans l'audit
DROP INDEX IF EXISTS idx_documents_user_type;

-- Créer l'index correct avec parent_id
CREATE INDEX IF NOT EXISTS idx_documents_parent_type ON documents(parent_id, document_type);

-- Ajouter des index manquants pour les nouveaux champs
CREATE INDEX IF NOT EXISTS idx_events_status ON events(status);
CREATE INDEX IF NOT EXISTS idx_events_all_day ON events(all_day);
CREATE INDEX IF NOT EXISTS idx_documents_file_type ON documents(file_type);

-- =====================================================
-- 5. MISE À JOUR DES TRIGGERS POUR NOUVEAUX CHAMPS
-- =====================================================

-- Les triggers updated_at existants fonctionneront automatiquement
-- pour les nouveaux champs car ils sont au niveau table

-- =====================================================
-- 6. AJOUT DE DONNÉES DE TEST COHÉRENTES
-- =====================================================

-- Fonction pour créer des données de test cohérentes
CREATE OR REPLACE FUNCTION create_test_data(user_uuid UUID)
RETURNS void AS $$
DECLARE
    child1_id UUID;
    child2_id UUID;
    child3_id UUID;
BEGIN
    -- Créer 3 enfants de test
    INSERT INTO children (
        parent_id, first_name, last_name, date_of_birth, gender,
        allergies, medical_notes, emergency_contact_name, emergency_contact_phone
    ) VALUES 
    (user_uuid, 'Emma', 'Martin', '2018-03-15', 'female', 'Arachides', 'RAS', 'Grand-mère Marie', '+33123456789'),
    (user_uuid, 'Lucas', 'Martin', '2020-07-22', 'male', NULL, 'Asthme léger', 'Oncle Pierre', '+33987654321'),
    (user_uuid, 'Chloé', 'Martin', '2016-11-08', 'female', 'Lactose', 'Lunettes', 'Tante Sophie', '+33456789123')
    RETURNING id INTO child1_id, child2_id, child3_id;
    
    -- Créer des événements de test
    INSERT INTO events (
        parent_id, title, description, event_type, start_date, end_date,
        child_id, location, all_day, status, notes
    ) VALUES 
    (user_uuid, 'Rendez-vous pédiatre', 'Visite de contrôle Emma', 'medical', 
     NOW() + INTERVAL '1 week', NOW() + INTERVAL '1 week' + INTERVAL '1 hour',
     child1_id, 'Cabinet Dr. Dubois', false, 'confirmed', 'Apporter carnet de santé'),
    (user_uuid, 'Réunion école', 'Réunion parents-professeurs', 'school',
     NOW() + INTERVAL '2 weeks', NOW() + INTERVAL '2 weeks' + INTERVAL '2 hours',
     child3_id, 'École primaire', false, 'confirmed', 'Discuter des résultats'),
    (user_uuid, 'Anniversaire Emma', 'Fête d\'anniversaire', 'family',
     DATE_TRUNC('day', NOW() + INTERVAL '1 month'), DATE_TRUNC('day', NOW() + INTERVAL '1 month') + INTERVAL '1 day',
     child1_id, 'Maison', true, 'confirmed', 'Inviter les amis de classe');
     
    -- Créer des documents de test
    INSERT INTO documents (
        parent_id, child_id, title, description, document_type,
        file_name, file_type, uploaded_by
    ) VALUES 
    (user_uuid, child1_id, 'Carnet de vaccination Emma', 'Vaccinations à jour', 'vaccination',
     'carnet_vaccination_emma.pdf', 'application/pdf', user_uuid),
    (user_uuid, child2_id, 'Certificat médical Lucas', 'Certificat pour le sport', 'medical',
     'certificat_lucas.pdf', 'application/pdf', user_uuid),
    (user_uuid, child3_id, 'Bulletin scolaire Chloé', 'Trimestre 1', 'school',
     'bulletin_chloe_t1.pdf', 'application/pdf', user_uuid);
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 7. VÉRIFICATION DE LA COHÉRENCE DES DONNÉES
-- =====================================================

-- Fonction de vérification de l'intégrité
CREATE OR REPLACE FUNCTION verify_data_integrity()
RETURNS TABLE(
    table_name TEXT,
    issue_count BIGINT,
    issue_description TEXT
) AS $$
BEGIN
    -- Vérifier les enfants sans parent valide
    RETURN QUERY
    SELECT 
        'children'::TEXT,
        COUNT(*)::BIGINT,
        'Enfants avec parent_id invalide'::TEXT
    FROM children c
    LEFT JOIN auth.users u ON c.parent_id = u.id
    WHERE u.id IS NULL;
    
    -- Vérifier les événements sans parent valide
    RETURN QUERY
    SELECT 
        'events'::TEXT,
        COUNT(*)::BIGINT,
        'Événements avec parent_id invalide'::TEXT
    FROM events e
    LEFT JOIN auth.users u ON e.parent_id = u.id
    WHERE u.id IS NULL;
    
    -- Vérifier les documents sans parent valide
    RETURN QUERY
    SELECT 
        'documents'::TEXT,
        COUNT(*)::BIGINT,
        'Documents avec parent_id invalide'::TEXT
    FROM documents d
    LEFT JOIN auth.users u ON d.parent_id = u.id
    WHERE u.id IS NULL;
    
    -- Vérifier les événements avec child_id invalide
    RETURN QUERY
    SELECT 
        'events'::TEXT,
        COUNT(*)::BIGINT,
        'Événements avec child_id invalide'::TEXT
    FROM events e
    WHERE e.child_id IS NOT NULL
    AND NOT EXISTS (SELECT 1 FROM children c WHERE c.id = e.child_id);
    
    -- Vérifier les documents avec child_id invalide
    RETURN QUERY
    SELECT 
        'documents'::TEXT,
        COUNT(*)::BIGINT,
        'Documents avec child_id invalide'::TEXT
    FROM documents d
    WHERE d.child_id IS NOT NULL
    AND NOT EXISTS (SELECT 1 FROM children c WHERE c.id = d.child_id);
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 8. MISE À JOUR DES POLITIQUES RLS
-- =====================================================

-- Mettre à jour les politiques pour les nouveaux champs
-- (Les politiques existantes couvrent déjà les nouveaux champs)

-- =====================================================
-- 9. STATISTIQUES ET MONITORING
-- =====================================================

-- Vue pour les statistiques de l'application
CREATE OR REPLACE VIEW app_statistics AS
SELECT 
    'users' as entity,
    COUNT(*) as total_count,
    COUNT(CASE WHEN created_at >= NOW() - INTERVAL '30 days' THEN 1 END) as last_30_days
FROM auth.users
UNION ALL
SELECT 
    'profiles' as entity,
    COUNT(*) as total_count,
    COUNT(CASE WHEN created_at >= NOW() - INTERVAL '30 days' THEN 1 END) as last_30_days
FROM profiles
UNION ALL
SELECT 
    'children' as entity,
    COUNT(*) as total_count,
    COUNT(CASE WHEN created_at >= NOW() - INTERVAL '30 days' THEN 1 END) as last_30_days
FROM children
UNION ALL
SELECT 
    'events' as entity,
    COUNT(*) as total_count,
    COUNT(CASE WHEN created_at >= NOW() - INTERVAL '30 days' THEN 1 END) as last_30_days
FROM events
UNION ALL
SELECT 
    'documents' as entity,
    COUNT(*) as total_count,
    COUNT(CASE WHEN created_at >= NOW() - INTERVAL '30 days' THEN 1 END) as last_30_days
FROM documents;

-- =====================================================
-- 10. FINALISATION
-- =====================================================

-- Mettre à jour les commentaires de la base
COMMENT ON TABLE children IS 'Table des enfants avec champs étendus pour compatibilité';
COMMENT ON TABLE events IS 'Table des événements avec support all_day et status';
COMMENT ON TABLE documents IS 'Table des documents avec métadonnées complètes';

-- Log de la migration
DO $$
BEGIN
    RAISE NOTICE 'Migration 20250814170751 terminée avec succès';
    RAISE NOTICE 'Tables mises à jour: children, events, documents';
    RAISE NOTICE 'Nouveaux champs ajoutés pour compatibilité TypeScript/Swift';
    RAISE NOTICE 'Index corrigés et optimisés';
    RAISE NOTICE 'Fonctions de test et vérification créées';
END $$;

-- =====================================================
-- INSTRUCTIONS POST-MIGRATION
-- =====================================================
/*
APRÈS CETTE MIGRATION :

1. Vérifier l'intégrité :
   SELECT * FROM verify_data_integrity();

2. Créer des données de test (optionnel) :
   SELECT create_test_data('YOUR_USER_UUID_HERE');

3. Voir les statistiques :
   SELECT * FROM app_statistics;

4. Tester les nouvelles fonctionnalités dans l'app

5. Vérifier que les erreurs HTTP 400 sont corrigées
*/
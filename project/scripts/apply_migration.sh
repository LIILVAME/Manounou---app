#!/bin/bash

# =====================================================
# SCRIPT D'APPLICATION DE LA MIGRATION SUPABASE
# =====================================================

echo "🔧 Application de la migration de correction..."
echo "📋 Migration: 20250814170751_create_missing_tables.sql"
echo ""

# Vérifier si le fichier de migration existe
MIGRATION_FILE="supabase/migrations/20250814170751_create_missing_tables.sql"

if [ ! -f "$MIGRATION_FILE" ]; then
    echo "❌ Erreur: Fichier de migration non trouvé: $MIGRATION_FILE"
    exit 1
fi

echo "✅ Fichier de migration trouvé"
echo "📊 Taille du fichier: $(wc -l < "$MIGRATION_FILE") lignes"
echo ""

echo "🚀 INSTRUCTIONS POUR APPLIQUER LA MIGRATION:"
echo ""
echo "1. 🌐 Ouvrir le dashboard Supabase:"
echo "   https://app.supabase.com/project/emgrtgencepzainsknsb/sql"
echo ""
echo "2. 📋 Copier le contenu de la migration:"
echo "   Le contenu du fichier $MIGRATION_FILE"
echo ""
echo "3. 📝 Coller dans l'éditeur SQL Supabase"
echo ""
echo "4. ▶️  Cliquer sur 'Run' pour exécuter"
echo ""
echo "5. ✅ Vérifier les résultats:"
echo "   - Aucune erreur dans les logs"
echo "   - Tables mises à jour avec succès"
echo ""

echo "📄 CONTENU DE LA MIGRATION À COPIER:"
echo "======================================"
echo ""
cat "$MIGRATION_FILE"
echo ""
echo "======================================"
echo ""

echo "🔍 VÉRIFICATIONS POST-MIGRATION:"
echo ""
echo "Après avoir exécuté la migration, testez ces requêtes:"
echo ""
echo "-- Vérifier l'intégrité des données"
echo "SELECT * FROM verify_data_integrity();"
echo ""
echo "-- Voir les statistiques"
echo "SELECT * FROM app_statistics;"
echo ""
echo "-- Vérifier les nouvelles colonnes"
echo "SELECT column_name, data_type, is_nullable "
echo "FROM information_schema.columns "
echo "WHERE table_name IN ('children', 'events', 'documents')"
echo "ORDER BY table_name, ordinal_position;"
echo ""

echo "🎯 OBJECTIFS DE CETTE MIGRATION:"
echo "✅ Ajouter champs manquants: allergies, medical_notes, emergency_contact"
echo "✅ Ajouter support all_day, notes, status pour events"
echo "✅ Ajouter file_type, uploaded_by pour documents"
echo "✅ Corriger index erronés (user_id -> parent_id)"
echo "✅ Ajouter fonctions de test et vérification"
echo "✅ Créer vue de statistiques"
echo ""

echo "⚠️  IMPORTANT:"
echo "Cette migration corrige les incohérences identifiées dans l'audit 360°"
echo "Elle assure la compatibilité entre les modèles TypeScript et Swift"
echo ""

echo "🔄 Après la migration, relancez l'application pour tester:"
echo "cd ../.. && cd ManounouSwiftUI"
echo "xcodebuild -project Manounou.xcodeproj -scheme Manounou build"
echo ""

echo "✨ Migration prête à être appliquée!"
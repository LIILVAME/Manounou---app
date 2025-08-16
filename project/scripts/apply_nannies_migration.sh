#!/bin/bash

# Script pour appliquer la migration des tables nannies
# Usage: ./apply_nannies_migration.sh

set -e

echo "🚀 Application de la migration des tables nannies..."

# Chemin vers le fichier de migration
MIGRATION_FILE="../../ManounouSwiftUI/supabase/migrations/create_nannies_tables.sql"

# Vérifier que le fichier existe
if [ ! -f "$MIGRATION_FILE" ]; then
    echo "❌ Erreur: Le fichier de migration n'existe pas: $MIGRATION_FILE"
    exit 1
fi

# Vérifier que les variables d'environnement Supabase sont définies
if [ -z "$SUPABASE_URL" ] || [ -z "$SUPABASE_ANON_KEY" ]; then
    echo "❌ Erreur: Les variables SUPABASE_URL et SUPABASE_ANON_KEY doivent être définies"
    echo "💡 Conseil: Créez un fichier .env avec vos clés Supabase"
    exit 1
fi

echo "📋 Contenu de la migration:"
echo "- Table nannies (informations des nannies)"
echo "- Table child_nannies (associations enfants-nannies)"
echo "- Table dropoffs (dépôts et récupérations)"
echo "- Policies RLS pour la sécurité"
echo "- Index pour les performances"
echo "- Données de test optionnelles"
echo ""

# Demander confirmation
read -p "🤔 Voulez-vous appliquer cette migration ? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Migration annulée"
    exit 0
fi

echo "⏳ Application de la migration..."

# Appliquer la migration via psql (nécessite d'avoir configuré la connexion)
# Alternative 1: Via psql direct
if command -v psql &> /dev/null; then
    echo "📡 Connexion à Supabase via psql..."
    # Remplacez par votre chaîne de connexion Supabase
    # psql "$SUPABASE_CONNECTION_STRING" -f "$MIGRATION_FILE"
fi

# Alternative 2: Via l'API Supabase (nécessite curl et jq)
if command -v curl &> /dev/null && command -v jq &> /dev/null; then
    echo "📡 Application via l'API Supabase..."
    
    # Lire le contenu du fichier SQL
    SQL_CONTENT=$(cat "$MIGRATION_FILE")
    
    # Exécuter via l'API REST de Supabase
    # Note: Cette méthode nécessite des permissions appropriées
    echo "⚠️  Note: L'exécution via API nécessite des permissions administrateur"
    echo "💡 Conseil: Utilisez le dashboard Supabase ou la CLI supabase pour exécuter:"
    echo "   supabase db reset --linked"
    echo "   ou copiez le contenu de $MIGRATION_FILE dans l'éditeur SQL du dashboard"
fi

echo "✅ Script terminé"
echo "📝 Prochaines étapes:"
echo "   1. Vérifiez que les tables ont été créées dans votre dashboard Supabase"
echo "   2. Testez les policies RLS"
echo "   3. Mettez à jour les ViewModels pour utiliser Supabase"
echo "   4. Testez l'application avec les vraies données"
#!/bin/bash

# Script pour exécuter le SQL dans Supabase via l'API REST
# Vous devez remplacer YOUR_SUPABASE_ANON_KEY par votre clé anonyme

echo "🔧 Exécution du script SQL dans Supabase..."
echo ""
echo "⚠️  IMPORTANT: Ce script nécessite votre clé API Supabase"
echo "📋 Instructions:"
echo "1. Allez sur https://app.supabase.com/project/emgrtgencepzainsknsb/settings/api"
echo "2. Copiez votre 'anon' key"
echo "3. Remplacez YOUR_SUPABASE_ANON_KEY dans ce script"
echo "4. Ou mieux encore, allez directement dans le SQL Editor:"
echo "   https://app.supabase.com/project/emgrtgencepzainsknsb/sql"
echo "5. Copiez-collez le contenu de supabase_setup.sql"
echo "6. Cliquez sur 'Run'"
echo ""
echo "✅ Le script SQL a été corrigé et est prêt à être exécuté!"
echo "✅ Toutes les politiques utilisent maintenant DROP POLICY IF EXISTS"
echo "✅ Plus d'erreurs de conflit!"
echo ""
echo "🚀 Votre base de données sera configurée avec:"
echo "   - Table profiles (profils utilisateur)"
echo "   - Table children (enfants)"
echo "   - Table events (événements/calendrier)"
echo "   - Table documents (stockage fichiers)"
echo "   - Table family_relationships (relations familiales)"
echo "   - Politiques de sécurité RLS"
echo "   - Index optimisés"
echo "   - Triggers automatiques"
echo "   - Buckets de stockage"
echo ""

# Exemple de commande curl (nécessite la clé API)
# curl -X POST \
#   'https://emgrtgencepzainsknsb.supabase.co/rest/v1/rpc/exec_sql' \
#   -H 'apikey: YOUR_SUPABASE_ANON_KEY' \
#   -H 'Authorization: Bearer YOUR_SUPABASE_ANON_KEY' \
#   -H 'Content-Type: application/json' \
#   -d '{"sql": "SELECT 1"}'
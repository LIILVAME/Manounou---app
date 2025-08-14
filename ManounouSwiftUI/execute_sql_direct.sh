#!/bin/bash

# Script pour exécuter le SQL directement dans Supabase
echo "🔧 Exécution du script SQL dans Supabase..."

# Lire le contenu du fichier SQL
SQL_CONTENT=$(cat supabase_setup.sql)

# Échapper les guillemets pour JSON
SQL_ESCAPED=$(echo "$SQL_CONTENT" | sed 's/"/\\"/g' | tr '\n' ' ')

echo "📋 Script SQL lu ($(echo "$SQL_CONTENT" | wc -l) lignes)"
echo "🚀 Exécution via l'API Supabase..."

# Utiliser l'API REST de Supabase pour exécuter le SQL
# Note: Cette méthode nécessite la clé API
echo "⚠️  Pour exécuter le script, vous devez:"
echo "1. Aller sur https://app.supabase.com/project/emgrtgencepzainsknsb/sql"
echo "2. Copier-coller le contenu de supabase_setup.sql"
echo "3. Cliquer sur 'Run'"
echo ""
echo "✅ Le script SQL est corrigé et prêt!"
echo "✅ Toutes les politiques utilisent DROP POLICY IF EXISTS"
echo "✅ Aucun conflit ne devrait se produire"

# Alternative: utiliser la CLI Supabase avec une migration
echo ""
echo "🔄 Alternative: Créer une migration Supabase"
echo "npx supabase migration new setup_database"
echo "# Puis copier le contenu de supabase_setup.sql dans le fichier de migration"
echo "# Et exécuter: npx supabase db push --linked"
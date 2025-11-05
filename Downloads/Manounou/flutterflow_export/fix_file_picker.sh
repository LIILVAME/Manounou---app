#!/bin/bash

# Script pour corriger l'erreur file_picker iOS
# À exécuter après chaque 'flutter pub get'

echo "🔧 Correction de l'erreur file_picker iOS..."

# Trouver tous les fichiers FilePickerPlugin.m dans le cache pub
FILE_PICKER_FILES=$(find ~/.pub-cache/hosted/pub.dev -name "FilePickerPlugin.m" -path "*/file_picker-*/ios/*" 2>/dev/null)

if [ -z "$FILE_PICKER_FILES" ]; then
    echo "❌ Fichier FilePickerPlugin.m non trouvé dans le cache pub"
    echo "💡 Exécutez d'abord: flutter pub get"
    exit 1
fi

# Corriger tous les fichiers trouvés
CORRECTED=0
SKIPPED=0

while IFS= read -r file; do
    if [ -z "$file" ]; then
        continue
    fi
    
    echo "📁 Fichier: $file"
    
    # Vérifier si la correction est déjà appliquée
    if grep -q "newUrls = \[urls mutableCopy\];" "$file"; then
        echo "   ✅ Déjà corrigé"
        SKIPPED=$((SKIPPED + 1))
        continue
    fi
    
    # Vérifier si la ligne problématique existe
    if ! grep -q "newUrls = urls;" "$file"; then
        echo "   ⚠️  Ligne problématique non trouvée (peut-être déjà corrigée ou version différente)"
        continue
    fi
    
    # Appliquer la correction
    sed -i '' 's/newUrls = urls;/newUrls = [urls mutableCopy];/' "$file"
    
    if [ $? -eq 0 ]; then
        echo "   ✅ Correction appliquée"
        CORRECTED=$((CORRECTED + 1))
    else
        echo "   ❌ Erreur lors de l'application"
    fi
done <<< "$FILE_PICKER_FILES"

echo ""
echo "📊 Résumé:"
echo "   - Fichiers corrigés: $CORRECTED"
echo "   - Fichiers déjà OK: $SKIPPED"
echo ""
if [ $CORRECTED -gt 0 ]; then
    echo "✅ Correction(s) appliquée(s) avec succès"
    echo "📝 Vous pouvez maintenant compiler l'app iOS"
fi


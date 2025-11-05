#!/bin/bash

# Script pour corriger les erreurs SDWebImage iOS
# À exécuter après chaque 'flutter pub get' ou 'pod install'

echo "🔧 Correction des erreurs SDWebImage iOS..."

# Trouver le dossier Pods SDWebImage
SDWEBIMAGE_DIR="ios/Pods/SDWebImage"

if [ ! -d "$SDWEBIMAGE_DIR" ]; then
    echo "❌ Dossier SDWebImage non trouvé dans $SDWEBIMAGE_DIR"
    echo "💡 Exécutez d'abord: cd ios && pod install"
    exit 1
fi

# Fonction pour corriger un fichier
fix_file() {
    local file="$1"
    if [ -f "$file" ]; then
        local corrected=0
        
        # Remplacer les #import entre guillemets par des angle brackets
        # Format: #import "Header.h" -> #import <SDWebImage/Header.h>
        if grep -q '#import "' "$file" 2>/dev/null; then
            sed -i '' 's/#import "\([^"]*\)"/#import <SDWebImage\/\1>/g' "$file"
            corrected=1
        fi
        
        # Remplacer les #include entre guillemets par des angle brackets
        # Format: #include "Header.h" -> #include <SDWebImage/Header.h>
        if grep -q '#include "' "$file" 2>/dev/null; then
            sed -i '' 's/#include "\([^"]*\)"/#include <SDWebImage\/\1>/g' "$file"
            corrected=1
        fi
        
        if [ $corrected -eq 1 ]; then
            echo "   ✅ Corrigé: $(basename $file)"
            return 0
        fi
    fi
    return 1
}

# Corriger tous les fichiers .h dans SDWebImage/Core
CORRECTED=0
SKIPPED=0

echo "📁 Correction des fichiers d'en-tête..."

# Trouver tous les fichiers .h dans Core
# Utiliser process substitution pour éviter le sous-shell
while IFS= read -r file; do
    # Vérifier si le fichier contient des imports/includes à corriger
    if grep -qE '(#include|#import) "' "$file" 2>/dev/null; then
        if fix_file "$file"; then
            CORRECTED=$((CORRECTED + 1))
        else
            SKIPPED=$((SKIPPED + 1))
        fi
    else
        SKIPPED=$((SKIPPED + 1))
    fi
done < <(find "$SDWEBIMAGE_DIR/SDWebImage/Core" -name "*.h" -type f)

# Corriger aussi le fichier umbrella
UMBRELLA_FILE="$SDWEBIMAGE_DIR/Target Support Files/SDWebImage/SDWebImage-umbrella.h"
if [ -f "$UMBRELLA_FILE" ]; then
    if grep -qE '(#include|#import) "' "$UMBRELLA_FILE" 2>/dev/null; then
        if fix_file "$UMBRELLA_FILE"; then
            CORRECTED=$((CORRECTED + 1))
        fi
    fi
fi

echo ""
echo "📊 Résumé:"
echo "   - Fichiers corrigés: $CORRECTED"
echo "   - Fichiers déjà OK: $SKIPPED"
echo ""
if [ $CORRECTED -gt 0 ]; then
    echo "✅ Corrections appliquées avec succès"
    echo "📝 Vous pouvez maintenant compiler l'app iOS"
    echo "💡 N'oubliez pas: Product > Clean Build Folder (⇧⌘K) dans Xcode"
else
    echo "ℹ️  Aucune correction nécessaire"
fi


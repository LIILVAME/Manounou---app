#!/bin/bash

# Script pour corriger le fichier header sqflite_darwin dans le cache pub
# Modifie SqfliteImportPublic.h pour utiliser un chemin relatif vers Flutter.h

echo "🔧 Correction du header sqflite_darwin..."

# Trouver le fichier header
HEADER_FILE=$(find ~/.pub-cache/hosted/pub.dev -name "SqfliteImportPublic.h" -path "*sqflite_darwin*" 2>/dev/null | head -1)

if [ -z "$HEADER_FILE" ]; then
    echo "❌ Fichier SqfliteImportPublic.h non trouvé"
    echo "💡 Exécutez d'abord: flutter pub get"
    exit 1
fi

echo "📁 Fichier trouvé: $HEADER_FILE"

# Créer une sauvegarde
cp "$HEADER_FILE" "$HEADER_FILE.backup"

# Lire le contenu actuel
CURRENT_CONTENT=$(cat "$HEADER_FILE")

# Vérifier si le fichier utilise déjà #ifndef ou si on doit modifier
if echo "$CURRENT_CONTENT" | grep -q "#import <Flutter/Flutter.h>"; then
    echo "   ℹ️  Le fichier utilise déjà #import <Flutter/Flutter.h>"
    echo "   💡 Le problème vient probablement des HEADER_SEARCH_PATHS"
elif echo "$CURRENT_CONTENT" | grep -q "#import \"Flutter/Flutter.h\""; then
    echo "   📝 Remplacement de #import \"Flutter/Flutter.h\" par #import <Flutter/Flutter.h>"
    # Remplacer les imports entre guillemets par des angle brackets
    sed -i '' 's|#import "Flutter/Flutter.h"|#import <Flutter/Flutter.h>|g' "$HEADER_FILE"
    echo "   ✅ Modification appliquée"
elif echo "$CURRENT_CONTENT" | grep -q "Flutter/Flutter.h"; then
    echo "   📝 Format trouvé: $(grep 'Flutter/Flutter.h' "$HEADER_FILE")"
    # Essayer de corriger en remplaçant par #import <Flutter/Flutter.h>
    sed -i '' 's|.*Flutter/Flutter.h.*|#import <Flutter/Flutter.h>|g' "$HEADER_FILE"
    echo "   ✅ Modification appliquée"
else
    echo "   ⚠️  Aucune référence à Flutter/Flutter.h trouvée"
    echo "   📄 Contenu actuel:"
    cat "$HEADER_FILE"
    mv "$HEADER_FILE.backup" "$HEADER_FILE"
    exit 1
fi

# Vérifier le résultat
NEW_CONTENT=$(cat "$HEADER_FILE")
if echo "$NEW_CONTENT" | grep -q "#import <Flutter/Flutter.h>"; then
    echo "   ✅ Header corrigé avec succès"
    rm -f "$HEADER_FILE.backup"
    echo ""
    echo "✅ Correction du header terminée"
    echo "💡 Vous devrez peut-être aussi:"
    echo "   1. Nettoyer le DerivedData: rm -rf ~/Library/Developer/Xcode/DerivedData"
    echo "   2. Dans Xcode: Product > Clean Build Folder (⇧⌘K)"
    echo "   3. Supprimer la phase VerifyModule manuellement si nécessaire"
else
    echo "   ❌ Échec de la correction"
    mv "$HEADER_FILE.backup" "$HEADER_FILE"
    exit 1
fi


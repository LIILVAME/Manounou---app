#!/bin/bash

# Script simplifié pour compilation simulateur uniquement
# Évite les modifications du projet et utilise des paramètres de build spécifiques

set -e

echo "🔧 Compilation Manounou pour simulateur uniquement..."

PROJECT_DIR="/Users/vametoure/Library/Mobile Documents/com~apple~CloudDocs/VAM/PROJETS - STARTUP/Manounou - app"
cd "$PROJECT_DIR"

# Nettoyer le cache
echo "🧹 Nettoyage du cache..."
rm -rf ~/Library/Developer/Xcode/DerivedData/Manounou-* || true

# Lister les simulateurs disponibles
echo "📱 Simulateurs disponibles :"
xcrun simctl list devices available | grep "iPhone 15" | head -3

# Paramètres de build pour éviter les problèmes de signature
BUILD_SETTINGS=(
    "CODE_SIGN_IDENTITY="
    "CODE_SIGN_STYLE=Manual"
    "DEVELOPMENT_TEAM="
    "PROVISIONING_PROFILE_SPECIFIER="
    "ONLY_ACTIVE_ARCH=YES"
)

# Construire la chaîne de paramètres
BUILD_PARAMS=""
for setting in "${BUILD_SETTINGS[@]}"; do
    BUILD_PARAMS="$BUILD_PARAMS $setting"
done

echo "🔨 Compilation pour simulateur..."
echo "Paramètres utilisés : $BUILD_PARAMS"

# Compilation avec paramètres spécifiques
if xcodebuild clean build \
    -project Manounou.xcodeproj \
    -scheme Manounou \
    -destination 'platform=iOS Simulator,name=iPhone 15' \
    $BUILD_PARAMS \
    -quiet; then
    
    echo "✅ Compilation réussie !"
    echo ""
    echo "🚀 Pour lancer l'application :"
    echo "   1. Ouvrez Xcode"
    echo "   2. Sélectionnez un simulateur iPhone"
    echo "   3. Appuyez sur Cmd+R pour lancer"
    echo ""
    echo "📱 Ou utilisez le script de test :"
    echo "   ./test_modern_app.sh"
    
else
    echo "❌ Échec de compilation"
    echo ""
    echo "🔍 Solutions possibles :"
    echo "1. Ouvrez Xcode et configurez manuellement :"
    echo "   - Allez dans Project Settings > Signing & Capabilities"
    echo "   - Décochez 'Automatically manage signing'"
    echo "   - Laissez 'Provisioning Profile' vide"
    echo "   - Sélectionnez un simulateur comme destination"
    echo ""
    echo "2. Ou ajoutez votre compte développeur Apple :"
    echo "   - Xcode > Preferences > Accounts"
    echo "   - Cliquez sur '+' et ajoutez votre Apple ID"
    echo ""
    exit 1
fi
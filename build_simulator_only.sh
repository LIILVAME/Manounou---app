#!/bin/bash

# Script de build automatisé pour simulateur iOS
# Partie du pipeline de build automatisé

set -e

echo "🔧 Build automatisé Manounou - Simulateur iOS"
echo "================================================"

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_DIR"

# Étape 1: Nettoyage
echo "🧹 Nettoyage du cache et des artefacts précédents..."
rm -rf ~/Library/Developer/Xcode/DerivedData/Manounou-* || true
rm -rf build/ || true
# Le manifeste SPM Manounou/Package.swift est un résidu non utilisé par le
# projet Xcode ; lancer 'swift package resolve' dessus crée un Manounou/.build
# qui fait échouer la résolution de paquets d'xcodebuild. On nettoie par sûreté.
rm -rf Manounou/.build Manounou/Package.resolved || true

# Étape 2: Résolution des dépendances du projet Xcode
echo "📦 Résolution des dépendances Swift Package Manager..."
xcodebuild -resolvePackageDependencies -project Manounou.xcodeproj -scheme Manounou || true

# Étape 3: Détection automatique du simulateur
echo "📱 Détection du simulateur disponible..."
SIMULATOR=$(xcrun simctl list devices available | grep -oE "iPhone [0-9]+( Pro( Max)?| Plus| mini)?" | head -1)

if [ -z "$SIMULATOR" ]; then
    echo "❌ Aucun simulateur iPhone disponible"
    exit 1
fi

echo "✅ Simulateur sélectionné: $SIMULATOR"

# Étape 4: Configuration de build pour simulateur
BUILD_SETTINGS=(
    "CODE_SIGN_IDENTITY="
    "CODE_SIGN_STYLE=Manual"
    "DEVELOPMENT_TEAM="
    "PROVISIONING_PROFILE_SPECIFIER="
    "ONLY_ACTIVE_ARCH=YES"
    "SKIP_INSTALL=NO"
)

BUILD_PARAMS=""
for setting in "${BUILD_SETTINGS[@]}"; do
    BUILD_PARAMS="$BUILD_PARAMS $setting"
done

# Étape 5: Compilation
echo "🔨 Compilation en cours..."
echo "Destination: platform=iOS Simulator,name=$SIMULATOR"

if xcodebuild clean build \
    -project Manounou.xcodeproj \
    -scheme Manounou \
    -destination "platform=iOS Simulator,name=$SIMULATOR" \
    $BUILD_PARAMS \
    -quiet; then
    
    echo ""
    echo "✅ BUILD RÉUSSI !"
    echo "================================================"
    echo "📊 Résumé du build:"
    echo "   • Projet: Manounou"
    echo "   • Plateforme: iOS Simulator"
    echo "   • Simulateur: $SIMULATOR"
    echo "   • Configuration: Debug"
    echo ""
    echo "🚀 Prochaines étapes:"
    echo "   1. Exécuter les tests: ./run_tests.sh"
    echo "   2. Lancer dans Xcode pour test manuel"
    echo ""
    
else
    echo ""
    echo "❌ ÉCHEC DE COMPILATION"
    echo "================================================"
    echo "🔍 Solutions possibles:"
    echo "   1. Vérifiez les erreurs de compilation dans Xcode"
    echo "   2. Assurez-vous que toutes les dépendances sont installées"
    echo "   3. Vérifiez la configuration de signature"
    echo ""
    exit 1
fi
#!/bin/bash

# Script d'exécution des tests unitaires
# Partie du pipeline de build automatisé

set -e

echo "🧪 Pipeline de Tests Automatisés - Manounou"
echo "============================================"

PROJECT_DIR="/Users/vametoure/Library/Mobile Documents/com~apple~CloudDocs/VAM/PROJETS - STARTUP/Manounou - app"
cd "$PROJECT_DIR"

# Étape 1: Nettoyage des artefacts de test
echo "🧹 Nettoyage des artefacts de test précédents..."
rm -rf ~/Library/Developer/Xcode/DerivedData/Manounou-*/Build/Products/Debug-iphonesimulator/ManounouTests.xctest || true
rm -rf test-results/ || true
mkdir -p test-results

# Étape 2: Détection du simulateur pour les tests
echo "📱 Configuration du simulateur de test..."
SIMULATOR=$(xcrun simctl list devices available | grep "iPhone SE (3rd generation)" | head -1 | sed 's/.*name:\([^}]*\).*/\1/' | xargs)

if [ -z "$SIMULATOR" ]; then
    echo "❌ Simulateur iPhone SE non disponible pour les tests"
    exit 1
fi

echo "✅ Simulateur de test: $SIMULATOR"

# Étape 3: Exécution des tests unitaires
echo "🔬 Exécution des tests unitaires..."

if xcodebuild test \
    -project Manounou.xcodeproj \
    -scheme Manounou \
    -destination "platform=iOS Simulator,name=$SIMULATOR" \
    CODE_SIGN_IDENTITY="" \
    CODE_SIGN_STYLE=Manual \
    DEVELOPMENT_TEAM="" \
    PROVISIONING_PROFILE_SPECIFIER="" \
    ONLY_ACTIVE_ARCH=YES \
    -resultBundlePath test-results/TestResults.xcresult \
    -quiet; then
    
    echo ""
    echo "✅ TESTS RÉUSSIS !"
    echo "============================================"
    echo "📊 Résumé des tests:"
    echo "   • Plateforme: iOS Simulator"
    echo "   • Simulateur: $SIMULATOR"
    echo "   • Résultats: test-results/TestResults.xcresult"
    echo ""
    
    # Extraction des métriques de test
    if command -v xcrun &> /dev/null; then
        echo "📈 Métriques de test:"
        xcrun xcresulttool get --format json --path test-results/TestResults.xcresult | \
        jq -r '.actions._values[0].actionResult.testsRef.id._value' 2>/dev/null || echo "   • Métriques détaillées disponibles dans TestResults.xcresult"
    fi
    
    echo ""
    echo "🚀 Prochaines étapes:"
    echo "   1. Générer les artefacts: ./generate_artifacts.sh"
    echo "   2. Déployer si tous les tests passent"
    echo ""
    
else
    echo ""
    echo "❌ ÉCHEC DES TESTS"
    echo "============================================"
    echo "🔍 Analyse des échecs:"
    echo "   • Vérifiez les logs de test dans Xcode"
    echo "   • Consultez test-results/TestResults.xcresult"
    echo "   • Corrigez les tests défaillants avant de continuer"
    echo ""
    exit 1
fi
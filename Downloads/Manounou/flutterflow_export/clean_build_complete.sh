#!/bin/bash

# Script de nettoyage complet pour résoudre les problèmes iOS
# À exécuter depuis flutterflow_export

echo "🧹 Nettoyage COMPLET pour résoudre les problèmes iOS..."
echo ""

# Vérifier qu'on est dans le bon répertoire
if [ ! -d "ios" ] || [ ! -f "pubspec.yaml" ]; then
    echo "❌ Erreur: Ce script doit être exécuté depuis le dossier flutterflow_export"
    exit 1
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "1️⃣  Nettoyage Flutter..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
flutter clean
echo "✅ Flutter nettoyé"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "2️⃣  Nettoyage Pods..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
cd ios
rm -rf Pods Podfile.lock .symlinks DerivedData
cd ..
echo "✅ Pods nettoyés"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "3️⃣  Nettoyage DerivedData Xcode..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
rm -rf ~/Library/Developer/Xcode/DerivedData
echo "✅ DerivedData nettoyé"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "4️⃣  Génération fichiers Flutter..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
flutter pub get
echo "✅ Fichiers Flutter générés"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "5️⃣  Réinstallation Pods..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
cd ios
LC_ALL=en_US.UTF-8 pod install --repo-update
cd ..
echo "✅ Pods réinstallés"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "6️⃣  Application des corrections iOS..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
./fix_all_ios.sh
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "7️⃣  Suppression VerifyModule..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
./remove_verify_module.sh
echo ""

# Vérifier si VerifyModule existe encore
if [ -f "ios/Pods/Pods.xcodeproj/project.pbxproj" ]; then
    VERIFY_COUNT=$(grep -c "modules-verifier" "ios/Pods/Pods.xcodeproj/project.pbxproj" 2>/dev/null || echo "0")
    if [ "$VERIFY_COUNT" -gt 0 ]; then
        echo "⚠️  VerifyModule toujours présent, tentative force..."
        ./force_remove_verify_module.sh
    fi
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "7️⃣  Tentative suppression VerifyModule avec Ruby..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ -f "ios/Pods/Pods.xcodeproj/project.pbxproj" ]; then
    ruby remove_verify_module_ruby.rb ios/Pods/Pods.xcodeproj 2>/dev/null || echo "⚠️  Ruby script non disponible, suppression manuelle requise"
else
    echo "⚠️  Projet Pods non trouvé"
fi
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Nettoyage terminé"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📝 Prochaines étapes dans Xcode:"
echo ""
echo "⚠️  IMPORTANT - Si l'erreur VerifyModule persiste:"
echo ""
echo "1. Ouvrir le projet Pods:"
echo "   open ios/Pods/Pods.xcodeproj"
echo ""
echo "2. Dans Xcode:"
echo "   - Sélectionner le target 'sqflite_darwin'"
echo "   - Onglet 'Build Phases'"
echo "   - Chercher la phase 'Run Script' contenant 'modules-verifier'"
echo "   - Sélectionner cette phase et appuyer sur Delete"
echo ""
echo "3. Nettoyer et recompiler:"
echo "   - Product > Clean Build Folder (⇧⌘K)"
echo "   - Fermer Xcode complètement"
echo "   - rm -rf ~/Library/Developer/Xcode/DerivedData"
echo "   - Rouvrir Xcode et recompiler"
echo ""
echo "📚 Documentation détaillée:"
echo "   docs/SUPPRESSION_MANUALE_VERIFY_MODULE.md"


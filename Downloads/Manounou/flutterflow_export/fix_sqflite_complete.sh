#!/bin/bash

# Script complet pour corriger définitivement sqflite_darwin
# À exécuter depuis flutterflow_export

echo "🔧 Correction complète sqflite_darwin..."
echo ""

# Vérifier qu'on est dans le bon répertoire
if [ ! -d "ios" ] || [ ! -f "pubspec.yaml" ]; then
    echo "❌ Erreur: Ce script doit être exécuté depuis le dossier flutterflow_export"
    exit 1
fi

# 1. Nettoyer complètement
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "1️⃣  Nettoyage complet..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
cd ios
rm -rf Pods Podfile.lock .symlinks
cd ..
echo "✅ Nettoyage terminé"
echo ""

# 2. Réinstaller les pods (le Podfile désactivera VerifyModule)
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "2️⃣  Réinstallation des pods..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
cd ios
pod install --repo-update
cd ..
echo "✅ Pods réinstallés"
echo ""

# 3. Appliquer toutes les corrections
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "3️⃣  Application des corrections..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
./fix_all_ios.sh
echo ""

# 4. Supprimer VerifyModule (méthode agressive)
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "4️⃣  Suppression de VerifyModule..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
./remove_verify_module.sh
echo ""

# Si ça ne fonctionne pas, essayer la méthode force
if [ -f "ios/Pods/Pods.xcodeproj/project.pbxproj" ]; then
    VERIFY_COUNT=$(grep -c "modules-verifier" "ios/Pods/Pods.xcodeproj/project.pbxproj" 2>/dev/null || echo "0")
    if [ "$VERIFY_COUNT" -gt 0 ]; then
        echo "⚠️  Phase VerifyModule toujours présente, tentative force..."
        ./force_remove_verify_module.sh
    fi
fi

# 5. Vérifier que VerifyModule est bien désactivé
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "5️⃣  Vérification finale..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Vérifier les fichiers .xcconfig
if [ -f "ios/Pods/Target Support Files/sqflite_darwin/sqflite_darwin.debug.xcconfig" ]; then
    if grep -q "ENABLE_MODULE_VERIFIER = NO" "ios/Pods/Target Support Files/sqflite_darwin/sqflite_darwin.debug.xcconfig"; then
        echo "✅ ENABLE_MODULE_VERIFIER = NO dans .xcconfig"
    else
        echo "⚠️  ENABLE_MODULE_VERIFIER non trouvé dans .xcconfig"
    fi
else
    echo "⚠️  Fichier .xcconfig non trouvé"
fi

# Vérifier si la phase VerifyModule existe encore dans le projet
if [ -f "ios/Pods/Pods.xcodeproj/project.pbxproj" ]; then
    VERIFY_COUNT=$(grep -c "modules-verifier" "ios/Pods/Pods.xcodeproj/project.pbxproj" 2>/dev/null || echo "0")
    if [ "$VERIFY_COUNT" -eq 0 ]; then
        echo "✅ Phase VerifyModule supprimée du projet"
    else
        echo "❌ Phase VerifyModule toujours présente ($VERIFY_COUNT occurrences)"
        echo "💡 Suppression MANUELLE requise dans Xcode (voir instructions ci-dessous)"
    fi
else
    echo "⚠️  Projet Pods non trouvé"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Correction terminée"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📝 Prochaines étapes dans Xcode:"
echo "   1. Product > Clean Build Folder (⇧⌘K)"
echo "   2. Fermer Xcode complètement"
echo "   3. Nettoyer DerivedData: rm -rf ~/Library/Developer/Xcode/DerivedData"
echo "   4. Rouvrir Xcode et recompiler"
echo ""
echo "⚠️  Si l'erreur persiste:"
echo "   - Ouvrir ios/Pods/Pods.xcodeproj dans Xcode"
echo "   - Sélectionner le target 'sqflite_darwin'"
echo "   - Build Phases → Supprimer la phase 'VerifyModule' manuellement"


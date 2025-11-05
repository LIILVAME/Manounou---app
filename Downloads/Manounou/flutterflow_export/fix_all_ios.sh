#!/bin/bash

# Script combiné pour corriger tous les problèmes iOS courants
# À exécuter après 'flutter pub get' et 'pod install'

# Vérifier qu'on est dans le bon répertoire
if [ ! -d "ios" ] || [ ! -f "pubspec.yaml" ]; then
    echo "❌ Erreur: Ce script doit être exécuté depuis le dossier flutterflow_export"
    echo "💡 Répertoire actuel: $(pwd)"
    echo "💡 Exécutez: cd flutterflow_export && ./fix_all_ios.sh"
    exit 1
fi

echo "🔧 Correction de tous les problèmes iOS..."
echo "📁 Répertoire: $(pwd)"
echo ""

# Correction file_picker
if [ -f "fix_file_picker.sh" ]; then
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "1️⃣  Correction file_picker..."
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    bash fix_file_picker.sh
    echo ""
else
    echo "⚠️  Script fix_file_picker.sh non trouvé"
fi

# Correction SDWebImage
if [ -f "fix_sdwebimage.sh" ]; then
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "2️⃣  Correction SDWebImage..."
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    bash fix_sdwebimage.sh
    echo ""
else
    echo "⚠️  Script fix_sdwebimage.sh non trouvé"
fi

# Correction sqflite_darwin
if [ -f "fix_sqflite_darwin.sh" ]; then
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "3️⃣  Correction sqflite_darwin..."
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    bash fix_sqflite_darwin.sh
    echo ""
else
    echo "⚠️  Script fix_sqflite_darwin.sh non trouvé"
fi

# Supprimer la phase VerifyModule si elle existe
if [ -f "remove_verify_module.sh" ]; then
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "4️⃣  Suppression phase VerifyModule..."
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    bash remove_verify_module.sh
    echo ""
else
    echo "⚠️  Script remove_verify_module.sh non trouvé"
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Toutes les corrections ont été appliquées"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "💡 Prochaines étapes:"
echo "   1. Dans Xcode: Product > Clean Build Folder (⇧⌘K)"
echo "   2. Recompiler le projet"
echo ""


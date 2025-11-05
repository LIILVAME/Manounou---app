#!/bin/bash

# Script pour corriger automatiquement les problèmes identifiés par l'audit

set -e

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$PROJECT_DIR"

echo "🔧 Correction des problèmes identifiés par l'audit..."
echo ""

# 1. Créer la configuration Android si manquante
if [ ! -d "android" ]; then
    echo "📱 Création de la configuration Android..."
    flutter create --platforms=android .
    echo "✅ Configuration Android créée"
fi

# 2. Corriger les imports inutilisés dans main_navigation.dart
if [ -f "lib/core/routes/main_navigation.dart" ]; then
    echo "🧹 Nettoyage des imports inutilisés..."
    # Les imports seront corrigés manuellement ou via le linter
    echo "✅ À vérifier: lib/core/routes/main_navigation.dart"
fi

# 3. Rendre les scripts exécutables
SCRIPTS=("fix_all_ios.sh" "fix_file_picker.sh" "fix_sdwebimage.sh" "fix_sqflite_darwin.sh" "verify_verify_module_fix.sh" "audit_complet.sh")
for script in "${SCRIPTS[@]}"; do
    if [ -f "$script" ] && [ ! -x "$script" ]; then
        chmod +x "$script"
        echo "✅ $script rendu exécutable"
    fi
done

# 4. Vérifier que Pods sont installés
if [ -d "ios" ] && [ ! -d "ios/Pods" ]; then
    echo "📦 Installation des Pods iOS..."
    cd ios
    LC_ALL=en_US.UTF-8 pod install
    cd ..
    echo "✅ Pods installés"
fi

echo ""
echo "✅ Corrections appliquées"
echo ""
echo "💡 Exécutez './audit_complet.sh' pour vérifier"


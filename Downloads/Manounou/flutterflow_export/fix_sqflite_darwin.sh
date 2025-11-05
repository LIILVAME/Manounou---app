#!/bin/bash

# Script pour corriger les erreurs sqflite_darwin iOS
# À exécuter après chaque 'pod install'

echo "🔧 Correction des erreurs sqflite_darwin iOS..."

# Chemin vers le fichier umbrella
UMBRELLA_FILE="ios/Pods/Target Support Files/sqflite_darwin/sqflite_darwin-umbrella.h"

if [ ! -f "$UMBRELLA_FILE" ]; then
    echo "❌ Fichier umbrella sqflite_darwin non trouvé"
    echo "💡 Exécutez d'abord: cd ios && pod install"
    exit 1
fi

CORRECTED=0

# Corriger le fichier umbrella
echo "📁 Correction du fichier umbrella..."
if grep -qE '(#include|#import) "' "$UMBRELLA_FILE" 2>/dev/null; then
    # Remplacer les includes entre guillemets par des angle brackets
    sed -i '' 's/#include "\([^"]*\)"/#include <sqflite_darwin\/\1>/g' "$UMBRELLA_FILE"
    sed -i '' 's/#import "\([^"]*\)"/#import <sqflite_darwin\/\1>/g' "$UMBRELLA_FILE"
    echo "   ✅ Corrigé: sqflite_darwin-umbrella.h"
    CORRECTED=$((CORRECTED + 1))
else
    echo "   ℹ️  Déjà corrigé: sqflite_darwin-umbrella.h"
fi

# Corriger le fichier SqfliteImportPublic.h dans le cache pub
echo "📁 Correction du fichier SqfliteImportPublic.h..."
SQFLITE_HEADER=$(find ~/.pub-cache/hosted/pub.dev -path "*/sqflite_darwin-*/darwin/sqflite_darwin/Sources/sqflite_darwin/include/sqflite_darwin/SqfliteImportPublic.h" 2>/dev/null | head -1)

if [ -n "$SQFLITE_HEADER" ] && [ -f "$SQFLITE_HEADER" ]; then
    echo "   📄 Fichier trouvé: $SQFLITE_HEADER"
    
    # Vérifier si Flutter.h est trouvable, sinon utiliser une alternative
    if grep -q '#import <Flutter/Flutter.h>' "$SQFLITE_HEADER" 2>/dev/null; then
        # Essayer de corriger en utilisant FlutterMacOS.h ou une autre méthode
        # Pour iOS, on peut utiliser le chemin relatif
        if ! grep -q 'Flutter\.h' "$SQFLITE_HEADER" 2>/dev/null || grep -q '#import <Flutter/Flutter.h>' "$SQFLITE_HEADER" 2>/dev/null; then
            # Garder la structure mais s'assurer que le chemin est correct
            # Le problème est souvent que le header search path n'est pas configuré
            echo "   ℹ️  Le fichier utilise déjà le bon format <Flutter/Flutter.h>"
            echo "   💡 Le problème vient probablement des HEADER_SEARCH_PATHS"
            echo "   💡 Vérifiez que le Podfile configure correctement les chemins Flutter"
        fi
    fi
else
    echo "   ⚠️  Fichier SqfliteImportPublic.h non trouvé dans le cache pub"
    echo "   💡 Exécutez d'abord: flutter pub get"
fi

# Vérifier et corriger les fichiers .xcconfig si nécessaire
echo "📁 Vérification des fichiers .xcconfig..."
XCCONFIG_FILES=(
    "ios/Pods/Target Support Files/sqflite_darwin/sqflite_darwin.debug.xcconfig"
    "ios/Pods/Target Support Files/sqflite_darwin/sqflite_darwin.release.xcconfig"
)

for xcconfig in "${XCCONFIG_FILES[@]}"; do
    if [ -f "$xcconfig" ]; then
        local_updated=0
        
        # Vérifier si HEADER_SEARCH_PATHS contient les chemins Flutter
        if ! grep -q "Flutter.framework/Headers" "$xcconfig" 2>/dev/null; then
            echo "   📝 Ajout des HEADER_SEARCH_PATHS Flutter dans $(basename $xcconfig)..."
            # Ajouter les chemins Flutter si HEADER_SEARCH_PATHS existe déjà
            if grep -q "^HEADER_SEARCH_PATHS" "$xcconfig" 2>/dev/null; then
                # Ajouter au chemin existant (méthode plus sûre)
                sed -i '' '/^HEADER_SEARCH_PATHS = / {
                    s|"$(PODS_CONFIGURATION_BUILD_DIR)/Flutter/Flutter.framework/Headers"||
                    s|"$(PODS_ROOT)/../Flutter/Flutter.framework/Headers"||
                }' "$xcconfig"
                sed -i '' 's|^HEADER_SEARCH_PATHS = \(.*\)|HEADER_SEARCH_PATHS = \1 "$(PODS_CONFIGURATION_BUILD_DIR)/Flutter/Flutter.framework/Headers" "$(PODS_ROOT)/../Flutter/Flutter.framework/Headers" "$(SRCROOT)/../Flutter/Flutter.framework/Headers"|' "$xcconfig"
            else
                # Ajouter une nouvelle ligne
                echo "" >> "$xcconfig"
                echo "HEADER_SEARCH_PATHS = \$(inherited) \"\$(PODS_CONFIGURATION_BUILD_DIR)/Flutter/Flutter.framework/Headers\" \"\$(PODS_ROOT)/../Flutter/Flutter.framework/Headers\" \"\$(SRCROOT)/../Flutter/Flutter.framework/Headers\"" >> "$xcconfig"
            fi
            echo "   ✅ Chemins Flutter ajoutés dans $(basename $xcconfig)"
            local_updated=1
        else
            echo "   ℹ️  $(basename $xcconfig) contient déjà les chemins Flutter"
        fi
        
        # S'assurer que CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES est activé
        if ! grep -q "^CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES" "$xcconfig" 2>/dev/null; then
            echo "   📝 Ajout de CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES dans $(basename $xcconfig)..."
            echo "" >> "$xcconfig"
            echo "CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES = YES" >> "$xcconfig"
            echo "   ✅ Paramètre ajouté dans $(basename $xcconfig)"
            local_updated=1
        fi
        
        # CRITIQUE : Désactiver ENABLE_MODULE_VERIFIER
        if ! grep -q "^ENABLE_MODULE_VERIFIER" "$xcconfig" 2>/dev/null; then
            echo "   📝 Désactivation de ENABLE_MODULE_VERIFIER dans $(basename $xcconfig)..."
            echo "" >> "$xcconfig"
            echo "ENABLE_MODULE_VERIFIER = NO" >> "$xcconfig"
            echo "   ✅ VerifyModule désactivé dans $(basename $xcconfig)"
            local_updated=1
        elif grep -q "^ENABLE_MODULE_VERIFIER = YES" "$xcconfig" 2>/dev/null; then
            echo "   📝 Désactivation de ENABLE_MODULE_VERIFIER dans $(basename $xcconfig)..."
            sed -i '' 's/^ENABLE_MODULE_VERIFIER = YES/ENABLE_MODULE_VERIFIER = NO/' "$xcconfig"
            echo "   ✅ VerifyModule désactivé dans $(basename $xcconfig)"
            local_updated=1
        else
            echo "   ℹ️  ENABLE_MODULE_VERIFIER déjà désactivé dans $(basename $xcconfig)"
        fi
        
        # Désactiver CLANG_ENABLE_MODULE_DEBUGGING
        if ! grep -q "^CLANG_ENABLE_MODULE_DEBUGGING" "$xcconfig" 2>/dev/null; then
            echo "   📝 Désactivation de CLANG_ENABLE_MODULE_DEBUGGING dans $(basename $xcconfig)..."
            echo "" >> "$xcconfig"
            echo "CLANG_ENABLE_MODULE_DEBUGGING = NO" >> "$xcconfig"
            echo "   ✅ Module debugging désactivé dans $(basename $xcconfig)"
            local_updated=1
        fi
        
        if [ $local_updated -eq 1 ]; then
            CORRECTED=$((CORRECTED + 1))
        fi
    else
        echo "   ⚠️  $(basename $xcconfig) non trouvé (pods pas encore installés ?)"
    fi
done

# CORRECTION CRITIQUE : Modifier le projet Xcode pour supprimer la phase VerifyModule
echo "📁 Modification du projet Xcode pour désactiver VerifyModule..."
PODS_PROJECT="ios/Pods/Pods.xcodeproj/project.pbxproj"

if [ -f "$PODS_PROJECT" ]; then
    # Vérifier si on peut utiliser Ruby pour modifier le projet
    if command -v ruby &> /dev/null; then
        echo "   📝 Utilisation de Ruby pour modifier le projet Xcode..."
        # Créer un script Ruby temporaire pour modifier le projet
        cat > /tmp/fix_sqflite_verify.rb << 'RUBY_SCRIPT'
require 'xcodeproj'

project_path = ARGV[0]
project = Xcodeproj::Project.open(project_path)

project.targets.each do |target|
  next unless target.name == 'sqflite_darwin'
  
  # Supprimer les phases VerifyModule
  phases_to_remove = []
  target.build_phases.each do |phase|
    if phase.is_a?(Xcodeproj::Project::Object::PBXShellScriptBuildPhase)
      script = phase.shell_script || ''
      if script.include?('modules-verifier') || script.include?('VerifyModule')
        phases_to_remove << phase
      end
    end
  end
  phases_to_remove.each { |phase| target.build_phases.delete(phase) }
  
  # Forcer les settings
  target.build_configurations.each do |config|
    config.build_settings['ENABLE_MODULE_VERIFIER'] = 'NO'
    config.build_settings['CLANG_ENABLE_MODULE_DEBUGGING'] = 'NO'
  end
end

project.save
RUBY_SCRIPT
        
        if ruby /tmp/fix_sqflite_verify.rb "$PODS_PROJECT" 2>/dev/null; then
            echo "   ✅ Phase VerifyModule supprimée du projet Xcode"
            CORRECTED=$((CORRECTED + 1))
        else
            echo "   ⚠️  Impossible de modifier le projet Xcode automatiquement"
            echo "   💡 Vous devrez peut-être le faire manuellement dans Xcode"
        fi
        rm -f /tmp/fix_sqflite_verify.rb
    else
        echo "   ⚠️  Ruby non disponible pour modifier le projet Xcode"
        echo "   💡 Le Podfile devrait déjà gérer cela lors de 'pod install'"
    fi
else
    echo "   ⚠️  Projet Pods non trouvé (pods pas encore installés ?)"
fi

echo ""
echo "📊 Résumé:"
echo "   - Fichiers corrigés: $CORRECTED"
echo ""
if [ $CORRECTED -gt 0 ]; then
    echo "✅ Corrections appliquées avec succès"
    echo "📝 Vous pouvez maintenant compiler l'app iOS"
    echo ""
    echo "⚠️  IMPORTANT - Si VerifyModule cause encore des erreurs:"
    echo "   1. Dans Xcode: Ouvrir ios/Pods/Pods.xcodeproj"
    echo "   2. Sélectionner le target 'sqflite_darwin'"
    echo "   3. Onglet 'Build Phases' → Supprimer la phase 'VerifyModule' si elle existe"
    echo "   4. Product > Clean Build Folder (⇧⌘K)"
    echo "   5. Recompiler"
else
    echo "ℹ️  Aucune correction nécessaire ou fichiers non trouvés"
    echo ""
    echo "💡 Si vous voyez toujours des erreurs VerifyModule:"
    echo "   1. Exécutez: cd ios && rm -rf Pods Podfile.lock && pod install"
    echo "   2. Le Podfile devrait automatiquement désactiver VerifyModule"
    echo "   3. Si ça ne fonctionne pas, supprimez manuellement la phase dans Xcode"
fi


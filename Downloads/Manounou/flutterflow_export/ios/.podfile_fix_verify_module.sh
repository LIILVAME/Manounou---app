#!/bin/bash

# Script automatique pour supprimer VerifyModule après pod install
# Ce script peut être ajouté comme hook après pod install

PROJECT_FILE="Pods/Pods.xcodeproj/project.pbxproj"

if [ ! -f "$PROJECT_FILE" ]; then
    exit 0
fi

# Supprimer toutes les lignes contenant modules-verifier
sed -i '' '/modules-verifier/d' "$PROJECT_FILE" 2>/dev/null

# Vérifier et corriger les fichiers .xcconfig
for config_type in debug release; do
    XCCONFIG="Pods/Target Support Files/sqflite_darwin/sqflite_darwin.${config_type}.xcconfig"
    if [ -f "$XCCONFIG" ]; then
        # Forcer DEFINES_MODULE = NO
        sed -i '' 's/^DEFINES_MODULE = .*/DEFINES_MODULE = NO/' "$XCCONFIG"
        
        # Ajouter les settings s'ils n'existent pas
        if ! grep -q "^ENABLE_MODULE_VERIFIER" "$XCCONFIG"; then
            echo "ENABLE_MODULE_VERIFIER = NO" >> "$XCCONFIG"
        fi
        if ! grep -q "^CLANG_ENABLE_MODULES" "$XCCONFIG"; then
            echo "CLANG_ENABLE_MODULES = NO" >> "$XCCONFIG"
        fi
    fi
done


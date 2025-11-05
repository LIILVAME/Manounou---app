#!/bin/bash

# Script de vérification de la solution VerifyModule
# À exécuter depuis flutterflow_export/

echo "🔍 Vérification de la solution VerifyModule..."
echo ""

# Vérifier DEFINES_MODULE
echo "1️⃣  Vérification DEFINES_MODULE dans les fichiers .xcconfig :"
if [ -d "ios/Pods/Target Support Files/sqflite_darwin" ]; then
    grep "DEFINES_MODULE" ios/Pods/Target\ Support\ Files/sqflite_darwin/sqflite_darwin.*.xcconfig 2>/dev/null
    if [ $? -eq 0 ]; then
        echo "   ✅ DEFINES_MODULE trouvé"
    else
        echo "   ⚠️  DEFINES_MODULE non trouvé"
    fi
else
    echo "   ⚠️  Dossier sqflite_darwin non trouvé. Exécutez 'pod install' d'abord."
fi
echo ""

# Vérifier modules-verifier dans project.pbxproj
echo "2️⃣  Vérification de modules-verifier dans project.pbxproj :"
if [ -f "ios/Pods/Pods.xcodeproj/project.pbxproj" ]; then
    COUNT=$(grep -c "modules-verifier" ios/Pods/Pods.xcodeproj/project.pbxproj 2>/dev/null)
    COUNT=${COUNT:-0}  # Définir à 0 si vide
    if [ "$COUNT" -eq 0 ]; then
        echo "   ✅ Aucune occurrence de modules-verifier (0)"
    else
        echo "   ⚠️  $COUNT occurrence(s) de modules-verifier trouvée(s)"
    fi
else
    echo "   ⚠️  Fichier project.pbxproj non trouvé. Exécutez 'pod install' d'abord."
fi
echo ""

# Vérifier que le Podfile contient la solution
echo "3️⃣  Vérification que le Podfile contient la solution :"
if [ -f "ios/Podfile" ]; then
    if grep -q "SOLUTION PÉRENNE" ios/Podfile; then
        echo "   ✅ Solution pérenne trouvée dans Podfile"
    else
        echo "   ⚠️  Solution pérenne non trouvée dans Podfile"
    fi
else
    echo "   ⚠️  Podfile non trouvé"
fi
echo ""

echo "✅ Vérification terminée"
echo ""
echo "💡 Pour appliquer la solution :"
echo "   cd ios && LC_ALL=en_US.UTF-8 pod install"


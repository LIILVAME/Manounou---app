#!/bin/bash

# Script ultra-agressif pour supprimer définitivement VerifyModule
# À utiliser en dernier recours

echo "🔧 Suppression FORCÉE de la phase VerifyModule..."

PROJECT_FILE="ios/Pods/Pods.xcodeproj/project.pbxproj"

if [ ! -f "$PROJECT_FILE" ]; then
    echo "❌ Fichier projet non trouvé: $PROJECT_FILE"
    echo "💡 Exécutez d'abord: cd ios && pod install"
    exit 1
fi

# Créer une sauvegarde
cp "$PROJECT_FILE" "$PROJECT_FILE.backup"
echo "✅ Sauvegarde créée: $PROJECT_FILE.backup"

# Compter avant
BEFORE=$(grep -c "modules-verifier" "$PROJECT_FILE" 2>/dev/null || echo "0")
echo "📊 Occurrences trouvées: $BEFORE"

if [ "$BEFORE" -eq 0 ]; then
    echo "✅ Aucune occurrence - VerifyModule déjà supprimé"
    rm -f "$PROJECT_FILE.backup"
    exit 0
fi

# Méthode 1: Supprimer toutes les lignes contenant modules-verifier
echo "📝 Suppression de toutes les lignes contenant 'modules-verifier'..."
sed -i '' '/modules-verifier/d' "$PROJECT_FILE"

# Vérifier
AFTER1=$(grep -c "modules-verifier" "$PROJECT_FILE" 2>/dev/null || echo "0")
echo "   Après suppression: $AFTER1 occurrences"

if [ "$AFTER1" -eq 0 ]; then
    echo "✅ Suppression réussie!"
    rm -f "$PROJECT_FILE.backup"
    exit 0
fi

# Méthode 2: Utiliser Python pour une suppression plus précise
echo "📝 Tentative avec Python pour suppression plus précise..."
python3 << PYTHON_SCRIPT
import re
import sys

project_file = "$PROJECT_FILE"

try:
    with open(project_file, 'r') as f:
        content = f.read()
    
    original = content
    
    # Supprimer toutes les lignes contenant modules-verifier
    lines = content.split('\n')
    new_lines = [line for line in lines if 'modules-verifier' not in line]
    
    new_content = '\n'.join(new_lines)
    
    if new_content != original:
        with open(project_file, 'w') as f:
            f.write(new_content)
        print("   ✅ Suppression Python réussie")
        sys.exit(0)
    else:
        print("   ⚠️  Aucune modification")
        sys.exit(1)
        
except Exception as e:
    print(f"   ❌ Erreur: {e}")
    sys.exit(1)
PYTHON_SCRIPT

if [ $? -eq 0 ]; then
    AFTER2=$(grep -c "modules-verifier" "$PROJECT_FILE" 2>/dev/null || echo "0")
    if [ "$AFTER2" -eq 0 ]; then
        echo "✅ Suppression complète réussie!"
        rm -f "$PROJECT_FILE.backup"
        exit 0
    fi
fi

# Si on arrive ici, la suppression a échoué
echo "⚠️  Impossible de supprimer toutes les références"
echo "💡 Restauration de la sauvegarde et instructions manuelles..."
mv "$PROJECT_FILE.backup" "$PROJECT_FILE"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "❌ ÉCHEC - Suppression manuelle requise"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Instructions pour supprimer manuellement dans Xcode:"
echo ""
echo "1. Ouvrir le projet Pods:"
echo "   open ios/Pods/Pods.xcodeproj"
echo ""
echo "2. Dans Xcode:"
echo "   - Sélectionner le target 'sqflite_darwin'"
echo "   - Onglet 'Build Phases'"
echo "   - Chercher la phase 'Run Script' ou 'VerifyModule'"
echo "   - Supprimer cette phase (clic droit → Delete)"
echo ""
echo "3. Nettoyer:"
echo "   - Product > Clean Build Folder (⇧⌘K)"
echo "   - rm -rf ~/Library/Developer/Xcode/DerivedData"
echo "   - Recompiler"
echo ""

exit 1


#!/bin/bash

# Script pour supprimer la phase VerifyModule de sqflite_darwin dans le projet Xcode
# À exécuter après 'pod install'

echo "🔧 Suppression de la phase VerifyModule pour sqflite_darwin..."

PROJECT_FILE="ios/Pods/Pods.xcodeproj/project.pbxproj"

if [ ! -f "$PROJECT_FILE" ]; then
    echo "❌ Fichier projet non trouvé: $PROJECT_FILE"
    echo "💡 Exécutez d'abord: cd ios && pod install"
    exit 1
fi

# Créer une sauvegarde
cp "$PROJECT_FILE" "$PROJECT_FILE.backup"

# Trouver les UUIDs associés à sqflite_darwin et VerifyModule
echo "📝 Recherche des phases VerifyModule pour sqflite_darwin..."

# Compter les occurrences avant
BEFORE=$(grep -c "modules-verifier" "$PROJECT_FILE" 2>/dev/null || echo "0")

if [ "$BEFORE" -eq 0 ]; then
    echo "   ✅ Aucune phase VerifyModule trouvée - déjà supprimée"
    rm -f "$PROJECT_FILE.backup"
    exit 0
fi

echo "   📊 Trouvé $BEFORE occurrence(s) de modules-verifier"

# Méthode plus robuste: utiliser Python pour parser le fichier pbxproj
if command -v python3 &> /dev/null; then
    echo "   📝 Utilisation de Python pour modifier le projet..."
    
    python3 << 'PYTHON_SCRIPT'
import re
import sys

project_file = sys.argv[1]

try:
    with open(project_file, 'r') as f:
        content = f.read()
    
    # Trouver toutes les phases shell script qui contiennent modules-verifier
    # Pattern pour trouver une phase shell script avec modules-verifier
    # On cherche les sections qui contiennent "modules-verifier" dans le shellScript
    
    # Méthode simple: supprimer les lignes qui contiennent modules-verifier dans les sections shell script
    # Mais on doit être prudent pour ne pas casser le fichier
    
    # Trouver les UUIDs de phases qui contiennent modules-verifier
    pattern = r'(\w+) = \{.*?shellScript = .*?modules-verifier.*?\n.*?\};'
    
    # Compter les occurrences
    matches = re.findall(pattern, content, re.DOTALL)
    
    if matches:
        print(f"   Trouvé {len(matches)} phase(s) VerifyModule")
        # Pour chaque UUID trouvé, supprimer la section complète
        for uuid in matches:
            # Supprimer la référence à cette phase
            content = re.sub(rf'{uuid} = \{{.*?shellScript = .*?modules-verifier.*?\n.*?\}};', '', content, flags=re.DOTALL)
            # Supprimer aussi les références dans les buildPhases
            content = re.sub(rf'\s+{uuid},?\s*\n', '', content)
        
        with open(project_file, 'w') as f:
            f.write(content)
        
        print("   ✅ Phases VerifyModule supprimées")
        sys.exit(0)
    else:
        print("   ℹ️  Aucune phase VerifyModule trouvée avec cette méthode")
        sys.exit(0)
        
except Exception as e:
    print(f"   ❌ Erreur: {e}")
    sys.exit(1)
PYTHON_SCRIPT
    
    if [ $? -eq 0 ]; then
        echo "   ✅ Modification réussie avec Python"
        rm -f "$PROJECT_FILE.backup"
        exit 0
    fi
fi

# Méthode: Supprimer toutes les références à modules-verifier
# On supprime les lignes qui contiennent "modules-verifier" dans le shell script
echo "   📝 Suppression des références modules-verifier..."

# Supprimer les lignes contenant modules-verifier
# Mais d'abord, on doit trouver les sections complètes des phases shell script
# et supprimer uniquement celles qui contiennent modules-verifier

# Créer un script Python temporaire pour une suppression plus précise
python3 << 'PYTHON_SCRIPT'
import re
import sys

project_file = sys.argv[1]

try:
    with open(project_file, 'r') as f:
        content = f.read()
    
    original_content = content
    
    # Pattern pour trouver une phase shell script complète avec modules-verifier
    # On cherche les sections qui commencent par un UUID et contiennent modules-verifier
    # Format typique: UUID = { ... shellScript = "...modules-verifier..."; ... };
    
    # Méthode plus sûre: supprimer ligne par ligne les lignes contenant modules-verifier
    # mais seulement dans le contexte d'une phase shell script
    lines = content.split('\n')
    new_lines = []
    skip_next_empty = False
    
    for i, line in enumerate(lines):
        # Si la ligne contient modules-verifier, on la saute
        if 'modules-verifier' in line:
            skip_next_empty = True
            continue
        
        # Si on vient de sauter une ligne avec modules-verifier et que c'est une ligne vide,
        # on peut aussi la sauter (optionnel, pour nettoyer)
        if skip_next_empty and line.strip() == '':
            skip_next_empty = False
            continue
        
        skip_next_empty = False
        new_lines.append(line)
    
    new_content = '\n'.join(new_lines)
    
    if new_content != original_content:
        with open(project_file, 'w') as f:
            f.write(new_content)
        print("   ✅ Références modules-verifier supprimées")
        sys.exit(0)
    else:
        print("   ℹ️  Aucune modification nécessaire")
        sys.exit(0)
        
except Exception as e:
    print(f"   ❌ Erreur: {e}")
    sys.exit(1)
PYTHON_SCRIPT

if [ $? -eq 0 ]; then
    # Vérifier le résultat
    AFTER=$(grep -c "modules-verifier" "$PROJECT_FILE" 2>/dev/null || echo "0")
    
    if [ "$AFTER" -eq 0 ]; then
        echo "   ✅ Toutes les références supprimées (avant: $BEFORE, après: $AFTER)"
        rm -f "$PROJECT_FILE.backup"
        echo ""
        echo "✅ Phase VerifyModule supprimée avec succès"
        echo "💡 Nettoyez le build dans Xcode: Product > Clean Build Folder (⇧⌘K)"
        exit 0
    else
        echo "   ⚠️  Il reste $AFTER occurrence(s) (avant: $BEFORE)"
        echo "   💡 Tentative de suppression plus agressive..."
        
        # Suppression plus agressive: supprimer toutes les lignes contenant modules-verifier
        sed -i '' '/modules-verifier/d' "$PROJECT_FILE"
        
        AFTER2=$(grep -c "modules-verifier" "$PROJECT_FILE" 2>/dev/null || echo "0")
        if [ "$AFTER2" -eq 0 ]; then
            echo "   ✅ Suppression réussie après deuxième tentative"
            rm -f "$PROJECT_FILE.backup"
            echo ""
            echo "✅ Phase VerifyModule supprimée"
            exit 0
        else
            echo "   ❌ Impossible de supprimer toutes les références"
            mv "$PROJECT_FILE.backup" "$PROJECT_FILE"
            echo "   💡 Vous devrez supprimer manuellement la phase dans Xcode"
            exit 1
        fi
    fi
else
    echo "   ❌ Erreur lors de la suppression Python"
    echo "   💡 Tentative avec sed..."
    sed -i '' '/modules-verifier/d' "$PROJECT_FILE"
    
    AFTER=$(grep -c "modules-verifier" "$PROJECT_FILE" 2>/dev/null || echo "0")
    if [ "$AFTER" -eq 0 ]; then
        echo "   ✅ Suppression réussie avec sed"
        rm -f "$PROJECT_FILE.backup"
        exit 0
    else
        mv "$PROJECT_FILE.backup" "$PROJECT_FILE"
        echo "   ❌ Échec de la suppression"
        exit 1
    fi
fi


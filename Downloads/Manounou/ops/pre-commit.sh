#!/bin/bash
# 🔍 Script de validation pré-commit pour Manounou
# Usage: ./ops/pre-commit.sh

set -e

echo "🔍 Validation pré-commit Manounou..."

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Vérifier que Flutter est installé
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}❌ Flutter n'est pas installé${NC}"
    exit 1
fi

cd flutterflow_export

# 1. Vérifier les dépendances
echo -e "${YELLOW}📦 Vérification des dépendances...${NC}"
flutter pub get

# 2. Analyse statique
echo -e "${YELLOW}🔍 Analyse statique du code...${NC}"
if ! flutter analyze --no-fatal-infos; then
    echo -e "${RED}❌ L'analyse a détecté des problèmes${NC}"
    exit 1
fi

# 3. Vérifier le formatage (optionnel)
echo -e "${YELLOW}✨ Vérification du formatage...${NC}"
dart format --set-exit-if-changed lib/ || {
    echo -e "${YELLOW}⚠️  Certains fichiers ne sont pas formatés. Exécutez: dart format lib/${NC}"
}

# 4. Tests unitaires (si disponibles)
if [ -d "test" ]; then
    echo -e "${YELLOW}🧪 Exécution des tests...${NC}"
    flutter test || {
        echo -e "${RED}❌ Les tests ont échoué${NC}"
        exit 1
    }
fi

echo -e "${GREEN}✅ Validation pré-commit réussie !${NC}"
exit 0


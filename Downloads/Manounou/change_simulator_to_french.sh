#!/bin/bash

# 🌐 Script pour changer la langue du simulateur iOS en français
# Usage: ./change_simulator_to_french.sh

echo "🌐 === Changement de Langue du Simulateur iOS ==="
echo ""

# Couleurs pour le terminal
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 1. Lister les simulateurs disponibles
echo "${BLUE}📱 Recherche des simulateurs disponibles...${NC}"
echo ""

DEVICES=$(xcrun simctl list devices available | grep "iPhone" | head -5)

if [ -z "$DEVICES" ]; then
    echo "${YELLOW}⚠️  Aucun simulateur trouvé.${NC}"
    echo "💡 Ouvrez Xcode et créez un simulateur :"
    echo "   Window > Devices and Simulators > + (bouton en bas)"
    exit 1
fi

echo "${GREEN}✅ Simulateurs trouvés :${NC}"
echo "$DEVICES"
echo ""

# 2. Ouvrir le simulateur
echo "${BLUE}🚀 Ouverture du simulateur...${NC}"
open -a Simulator

echo ""
echo "${GREEN}✅ Simulateur ouvert !${NC}"
echo ""
echo "${YELLOW}📝 MAINTENANT, SUIVEZ CES ÉTAPES DANS LE SIMULATEUR :${NC}"
echo ""
echo "   1️⃣  Cliquez sur l'icône 'Réglages' (⚙️ roue crantée) sur l'écran d'accueil"
echo "   2️⃣  Faites défiler et cliquez sur 'Général'"
echo "   3️⃣  Cliquez sur 'Langue et région'"
echo "   4️⃣  Cliquez sur 'Langue de l'iPhone'"
echo "   5️⃣  Sélectionnez 'Français' dans la liste"
echo "   6️⃣  Cliquez sur 'Terminé' en haut à droite"
echo "   7️⃣  Le simulateur redémarrera automatiquement"
echo ""
echo "${GREEN}✅ Après le redémarrage, le clavier sera en AZERTY !${NC}"
echo ""
echo "${BLUE}💡 Pour tester :${NC}"
echo "   cd flutterflow_export"
echo "   flutter run"
echo ""


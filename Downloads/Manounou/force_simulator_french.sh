#!/bin/bash

# 🔧 Script pour FORCER le français sur le simulateur iOS
# Résout le problème de mapping clavier (@ donne §)

echo "🔧 === FORCAGE FRANÇAIS SUR SIMULATEUR iOS ==="
echo ""

# Couleurs
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# 1. Trouver le simulateur booté
BOOTED_DEVICE=$(xcrun simctl list devices | grep "Booted" | head -1 | awk -F'(' '{print $2}' | awk -F')' '{print $1}')

if [ -z "$BOOTED_DEVICE" ]; then
    echo "${YELLOW}⚠️  Aucun simulateur n'est démarré.${NC}"
    echo "${BLUE}💡 Démarrage d'un simulateur...${NC}"
    xcrun simctl boot "iPhone 17 Pro" 2>/dev/null || xcrun simctl boot "iPhone 15 Pro" 2>/dev/null || {
        echo "${RED}❌ Impossible de démarrer un simulateur.${NC}"
        echo "💡 Ouvrez Xcode > Window > Devices and Simulators et créez un simulateur"
        exit 1
    }
    BOOTED_DEVICE=$(xcrun simctl list devices | grep "Booted" | head -1 | awk -F'(' '{print $2}' | awk -F')' '{print $1}')
    sleep 2
fi

echo "${GREEN}✅ Simulateur trouvé : ${BOOTED_DEVICE}${NC}"
echo ""

# 2. Arrêter le simulateur
echo "${BLUE}🔄 Arrêt du simulateur...${NC}"
xcrun simctl shutdown "$BOOTED_DEVICE" 2>/dev/null
sleep 2

# 3. Forcer la langue française via les préférences
echo "${BLUE}🌐 Configuration de la langue française...${NC}"

# Créer un fichier temporaire avec les préférences
TEMP_PREFS=$(mktemp)
cat > "$TEMP_PREFS" << 'EOF'
{
  "AppleLanguages" = (
    "fr-FR",
    "en-US"
  );
  "AppleLocale" = "fr_FR";
}
EOF

# Appliquer les préférences au simulateur
xcrun simctl spawn "$BOOTED_DEVICE" defaults write NSGlobalDomain AppleLanguages -array "fr-FR" "en-US" 2>/dev/null || true
xcrun simctl spawn "$BOOTED_DEVICE" defaults write NSGlobalDomain AppleLocale "fr_FR" 2>/dev/null || true

rm -f "$TEMP_PREFS"

# 4. Redémarrer le simulateur
echo "${BLUE}🚀 Redémarrage du simulateur...${NC}"
xcrun simctl boot "$BOOTED_DEVICE"
sleep 3

# 5. Ouvrir le simulateur
open -a Simulator

echo ""
echo "${GREEN}✅ Simulateur redémarré !${NC}"
echo ""
echo "${YELLOW}📝 IMPORTANT : Deux solutions pour le clavier :${NC}"
echo ""
echo "${BLUE}Option 1 : Utiliser le clavier VIRTUEL iOS (recommandé)${NC}"
echo "   1. Dans le simulateur, cliquez sur :"
echo "      I/O > Keyboard > Connect Hardware Keyboard"
echo "   2. DÉCOCHER cette option"
echo "   3. Le clavier virtuel iOS apparaîtra (en AZERTY si le simulateur est en français)"
echo "   4. Taper directement sur le clavier virtuel à l'écran"
echo ""
echo "${BLUE}Option 2 : Configurer le mapping Mac${NC}"
echo "   1. Préférences Système Mac > Clavier > Sources d'entrée"
echo "   2. Ajouter 'Français - AZERTY' si pas présent"
echo "   3. Dans le simulateur : I/O > Keyboard > Connect Hardware Keyboard (décoché)"
echo "   4. OU utiliser le clavier virtuel iOS"
echo ""
echo "${GREEN}💡 Pour tester :${NC}"
echo "   cd flutterflow_export"
echo "   flutter run"
echo ""
echo "${YELLOW}⚠️  Si '@' donne toujours '§', utilisez le clavier virtuel iOS !${NC}"
echo ""


#!/bin/bash

# 🧪 Script de Test - Application Manounou Refactorisée
# Date: 18 Août 2025
# Description: Lance l'application avec les nouveaux composants pour tests

set -e

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PROJECT_DIR="/Users/vametoure/Library/Mobile Documents/com~apple~CloudDocs/VAM/PROJETS - STARTUP/Manounou - app"
PROJECT_NAME="Manounou.xcodeproj"
SCHEME_NAME="Manounou"
SIMULATOR_ID="4139A0AC-23BF-416E-B6E9-A9B9789E6B07" # iPhone 15

echo -e "${BLUE}🚀 Script de Test - Application Manounou Refactorisée${NC}"
echo -e "${BLUE}=================================================${NC}"
echo ""

# Fonction pour afficher les étapes
print_step() {
    echo -e "${YELLOW}📋 $1${NC}"
}

# Fonction pour afficher les succès
print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

# Fonction pour afficher les erreurs
print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Vérification des prérequis
print_step "Vérification des prérequis..."

# Vérifier que Xcode est installé
if ! command -v xcodebuild &> /dev/null; then
    print_error "Xcode n'est pas installé ou xcodebuild n'est pas dans le PATH"
    exit 1
fi

# Vérifier que le projet existe
if [ ! -d "$PROJECT_DIR" ]; then
    print_error "Le répertoire du projet n'existe pas: $PROJECT_DIR"
    exit 1
fi

cd "$PROJECT_DIR"

if [ ! -f "$PROJECT_NAME/project.pbxproj" ]; then
    print_error "Le fichier projet Xcode n'existe pas: $PROJECT_NAME"
    exit 1
fi

print_success "Prérequis vérifiés"

# Nettoyage du build
print_step "Nettoyage du build précédent..."
xcodebuild clean -project "$PROJECT_NAME" -scheme "$SCHEME_NAME" > /dev/null 2>&1
print_success "Build nettoyé"

# Résolution des dépendances
print_step "Résolution des dépendances Swift Package Manager..."
xcodebuild -resolvePackageDependencies -project "$PROJECT_NAME" > /dev/null 2>&1
print_success "Dépendances résolues"

# Compilation
print_step "Compilation du projet..."
echo -e "${BLUE}Cela peut prendre quelques minutes...${NC}"

if xcodebuild build -project "$PROJECT_NAME" -scheme "$SCHEME_NAME" -destination "platform=iOS Simulator,id=$SIMULATOR_ID" > build.log 2>&1; then
    print_success "Compilation réussie"
else
    print_error "Échec de la compilation"
    echo -e "${RED}Consultez build.log pour plus de détails${NC}"
    tail -20 build.log
    exit 1
fi

# Lancement du simulateur
print_step "Démarrage du simulateur iPhone 15..."
xcrun simctl boot "$SIMULATOR_ID" > /dev/null 2>&1 || true
sleep 3
print_success "Simulateur démarré"

# Installation et lancement de l'app
print_step "Installation et lancement de l'application..."

if xcodebuild build -project "$PROJECT_NAME" -scheme "$SCHEME_NAME" -destination "platform=iOS Simulator,id=$SIMULATOR_ID" > install.log 2>&1; then
    print_success "Application installée et lancée"
else
    print_error "Échec du lancement"
    echo -e "${RED}Consultez install.log pour plus de détails${NC}"
    tail -20 install.log
    exit 1
fi

# Ouverture du simulateur
print_step "Ouverture du simulateur..."
open -a Simulator

echo ""
echo -e "${GREEN}🎉 APPLICATION LANCÉE AVEC SUCCÈS !${NC}"
echo ""
echo -e "${BLUE}📱 L'application Manounou est maintenant en cours d'exécution sur le simulateur iPhone 15${NC}"
echo ""
echo -e "${YELLOW}📋 ÉTAPES DE TEST RECOMMANDÉES :${NC}"
echo "1. Vérifiez que les 5 onglets sont visibles (Accueil, Enfants, Calendrier, Documents, Paramètres)"
echo "2. Testez la navigation entre les onglets"
echo "3. Testez les boutons d'ajout (+) dans chaque section"
echo "4. Testez les formulaires de création/modification"
echo "5. Testez les fonctionnalités de suppression (swipe to delete)"
echo "6. Testez l'accessibilité (VoiceOver)"
echo "7. Testez le Dark Mode (Paramètres > Affichage > Sombre)"
echo ""
echo -e "${BLUE}📖 Guide de test complet : Documentation/MANUAL_TESTING_GUIDE.md${NC}"
echo ""

# Fonction pour surveiller les logs
monitor_logs() {
    print_step "Surveillance des logs de l'application..."
    echo -e "${BLUE}Appuyez sur Ctrl+C pour arrêter la surveillance${NC}"
    xcrun simctl spawn "$SIMULATOR_ID" log stream --predicate 'subsystem contains "com.manounou.app"' --level debug
}

# Demander si l'utilisateur veut surveiller les logs
echo -e "${YELLOW}Voulez-vous surveiller les logs de l'application ? (y/n)${NC}"
read -r response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    monitor_logs
fi

# Nettoyage des fichiers de log
rm -f build.log install.log

echo -e "${GREEN}✨ Test terminé avec succès !${NC}"
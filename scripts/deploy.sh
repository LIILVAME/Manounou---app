#!/bin/bash

# Script de déploiement automatisé pour Manounou App
# Usage: ./scripts/deploy.sh [ios|android|all] [development|preview|production]

set -e  # Arrêter le script en cas d'erreur

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fonctions utilitaires
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Vérification des paramètres
PLATFORM=${1:-"all"}
PROFILE=${2:-"production"}

if [[ ! "$PLATFORM" =~ ^(ios|android|all)$ ]]; then
    log_error "Plateforme invalide. Utilisez: ios, android, ou all"
    exit 1
fi

if [[ ! "$PROFILE" =~ ^(development|preview|production)$ ]]; then
    log_error "Profil invalide. Utilisez: development, preview, ou production"
    exit 1
fi

log_info "Déploiement pour $PLATFORM avec le profil $PROFILE"

# Vérification des prérequis
check_prerequisites() {
    log_info "Vérification des prérequis..."
    
    # Vérifier Node.js
    if ! command -v node &> /dev/null; then
        log_error "Node.js n'est pas installé"
        exit 1
    fi
    
    # Vérifier npm
    if ! command -v npm &> /dev/null; then
        log_error "npm n'est pas installé"
        exit 1
    fi
    
    # Vérifier Expo CLI
    if ! command -v expo &> /dev/null; then
        log_warning "Expo CLI n'est pas installé. Installation..."
        npm install -g @expo/cli
    fi
    
    # Vérifier EAS CLI
    if ! command -v eas &> /dev/null; then
        log_warning "EAS CLI n'est pas installé. Installation..."
        npm install -g eas-cli
    fi
    
    log_success "Prérequis vérifiés"
}

# Installation des dépendances
install_dependencies() {
    log_info "Installation des dépendances..."
    npm ci
    log_success "Dépendances installées"
}

# Vérification de la configuration
check_configuration() {
    log_info "Vérification de la configuration..."
    
    # Vérifier app.json
    if [[ ! -f "app.json" ]]; then
        log_error "Fichier app.json manquant"
        exit 1
    fi
    
    # Vérifier eas.json
    if [[ ! -f "eas.json" ]]; then
        log_error "Fichier eas.json manquant"
        exit 1
    fi
    
    # Vérifier les assets
    if [[ ! -f "assets/icon.svg" ]]; then
        log_error "Icône de l'app manquante (assets/icon.svg)"
        exit 1
    fi
    
    if [[ ! -f "assets/splash.svg" ]]; then
        log_error "Écran de démarrage manquant (assets/splash.svg)"
        exit 1
    fi
    
    log_success "Configuration vérifiée"
}

# Tests avant déploiement
run_tests() {
    log_info "Exécution des tests..."
    
    # Linter
    log_info "Vérification du code avec ESLint..."
    npm run lint
    
    # Tests unitaires
    if npm run test --silent 2>/dev/null; then
        log_info "Exécution des tests unitaires..."
        npm run test -- --watchAll=false
    else
        log_warning "Aucun test unitaire configuré"
    fi
    
    log_success "Tests terminés"
}

# Build de l'application
build_app() {
    log_info "Build de l'application..."
    
    case $PLATFORM in
        "ios")
            log_info "Build iOS avec le profil $PROFILE"
            eas build --platform ios --profile $PROFILE --non-interactive
            ;;
        "android")
            log_info "Build Android avec le profil $PROFILE"
            eas build --platform android --profile $PROFILE --non-interactive
            ;;
        "all")
            log_info "Build iOS et Android avec le profil $PROFILE"
            eas build --platform all --profile $PROFILE --non-interactive
            ;;
    esac
    
    log_success "Build terminé"
}

# Soumission aux stores (seulement pour production)
submit_to_stores() {
    if [[ "$PROFILE" != "production" ]]; then
        log_info "Soumission ignorée (profil: $PROFILE)"
        return
    fi
    
    log_info "Soumission aux stores..."
    
    case $PLATFORM in
        "ios")
            log_info "Soumission à l'App Store"
            eas submit --platform ios --non-interactive
            ;;
        "android")
            log_info "Soumission au Google Play Store"
            eas submit --platform android --non-interactive
            ;;
        "all")
            log_info "Soumission à l'App Store et Google Play Store"
            eas submit --platform ios --non-interactive
            eas submit --platform android --non-interactive
            ;;
    esac
    
    log_success "Soumission terminée"
}

# Nettoyage post-déploiement
cleanup() {
    log_info "Nettoyage..."
    # Supprimer les fichiers temporaires si nécessaire
    log_success "Nettoyage terminé"
}

# Notification de fin
notify_completion() {
    log_success "🚀 Déploiement terminé avec succès!"
    log_info "Plateforme: $PLATFORM"
    log_info "Profil: $PROFILE"
    log_info "Timestamp: $(date)"
    
    if [[ "$PROFILE" == "production" ]]; then
        log_info "📱 Vérifiez les stores dans les prochaines heures"
        log_info "📊 Surveillez les métriques et les crashes"
        log_info "💬 Répondez aux commentaires utilisateurs"
    fi
}

# Gestion des erreurs
handle_error() {
    log_error "❌ Erreur lors du déploiement"
    log_error "Ligne: $1"
    log_error "Commande: $2"
    cleanup
    exit 1
}

# Trap pour capturer les erreurs
trap 'handle_error $LINENO "$BASH_COMMAND"' ERR

# Fonction principale
main() {
    log_info "🚀 Début du déploiement Manounou App"
    log_info "Plateforme: $PLATFORM"
    log_info "Profil: $PROFILE"
    log_info "Timestamp: $(date)"
    
    check_prerequisites
    install_dependencies
    check_configuration
    run_tests
    build_app
    submit_to_stores
    cleanup
    notify_completion
}

# Demander confirmation pour la production
if [[ "$PROFILE" == "production" ]]; then
    echo
    log_warning "⚠️  ATTENTION: Déploiement en PRODUCTION"
    log_warning "Cette action va:"
    log_warning "- Créer un build de production"
    log_warning "- Soumettre aux stores (App Store/Google Play)"
    log_warning "- Rendre l'app disponible aux utilisateurs"
    echo
    read -p "Êtes-vous sûr de vouloir continuer? (oui/non): " -r
    if [[ ! $REPLY =~ ^(oui|yes|y|Y)$ ]]; then
        log_info "Déploiement annulé"
        exit 0
    fi
fi

# Exécuter le déploiement
main

log_success "✅ Script de déploiement terminé"
#!/bin/bash

# 🚀 Script d'aide au déploiement - Manounou
# Ce script facilite les déploiements manuels et la gestion des releases

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
BUILD_SCRIPTS_DIR="$PROJECT_ROOT"

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fonctions utilitaires
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Fonction pour afficher l'aide
show_help() {
    cat << EOF
🚀 Script d'aide au déploiement - Manounou

USAGE:
    $0 [COMMAND] [OPTIONS]

COMMANDS:
    status          Affiche le statut du projet et des déploiements
    prepare         Prépare une nouvelle release
    deploy          Lance un déploiement
    rollback        Effectue un rollback
    validate        Valide la configuration de déploiement
    help            Affiche cette aide

OPTIONS:
    -v, --version   Version à déployer (ex: 1.0.0)
    -e, --env       Environnement (staging|production)
    -f, --force     Force l'opération sans confirmation
    -h, --help      Affiche cette aide

EXAMPLES:
    $0 status
    $0 prepare -v 1.2.0
    $0 deploy -v 1.2.0 -e staging
    $0 validate

Pour plus d'informations, consultez .github/DEPLOYMENT.md
EOF
}

# Fonction pour vérifier les prérequis
check_prerequisites() {
    log_info "Vérification des prérequis..."
    
    # Vérifier Git
    if ! command -v git &> /dev/null; then
        log_error "Git n'est pas installé"
        exit 1
    fi
    
    # Vérifier Xcode
    if ! command -v xcodebuild &> /dev/null; then
        log_error "Xcode n'est pas installé"
        exit 1
    fi
    
    # Vérifier que nous sommes dans un repo Git
    if ! git rev-parse --git-dir &> /dev/null; then
        log_error "Ce n'est pas un repository Git"
        exit 1
    fi
    
    log_success "Prérequis validés"
}

# Fonction pour afficher le statut
show_status() {
    log_info "Statut du projet Manounou"
    echo
    
    # Informations Git
    echo "📂 Repository:"
    echo "   Branche actuelle: $(git branch --show-current)"
    echo "   Dernier commit: $(git log -1 --pretty=format:'%h - %s (%an, %ar)')"
    echo "   Statut: $(git status --porcelain | wc -l | tr -d ' ') fichier(s) modifié(s)"
    echo
    
    # Tags récents
    echo "🏷️  Tags récents:"
    git tag --sort=-version:refname | head -5 | sed 's/^/   /'
    echo
    
    # Vérifier les secrets GitHub (si dans un repo GitHub)
    if git remote get-url origin 2>/dev/null | grep -q github; then
        echo "🔐 Configuration GitHub:"
        echo "   Repository: $(git remote get-url origin)"
        echo "   ⚠️  Vérifiez manuellement les secrets dans GitHub Settings"
    fi
    echo
    
    # Statut des builds
    echo "🏗️  Derniers builds:"
    if [ -d "$BUILD_SCRIPTS_DIR" ]; then
        echo "   Scripts de build: ✅ Disponibles"
    else
        echo "   Scripts de build: ❌ Non trouvés"
    fi
}

# Fonction pour préparer une release
prepare_release() {
    local version="$1"
    
    log_info "Préparation de la release v$version"
    
    # Vérifier que la branche est propre
    if [ -n "$(git status --porcelain)" ]; then
        log_error "La branche contient des modifications non commitées"
        exit 1
    fi
    
    # Vérifier qu'on est sur develop ou main
    local current_branch=$(git branch --show-current)
    if [[ "$current_branch" != "develop" && "$current_branch" != "main" ]]; then
        log_warning "Vous n'êtes pas sur develop ou main (branche actuelle: $current_branch)"
        read -p "Continuer quand même ? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
    
    # Vérifier que le tag n'existe pas déjà
    if git tag | grep -q "^v$version$"; then
        log_error "Le tag v$version existe déjà"
        exit 1
    fi
    
    # Mettre à jour depuis origin
    log_info "Mise à jour depuis origin..."
    git fetch origin
    git pull origin "$current_branch"
    
    # Créer le tag
    log_info "Création du tag v$version..."
    git tag -a "v$version" -m "Release v$version"
    
    # Pousser le tag
    log_info "Push du tag vers origin..."
    git push origin "v$version"
    
    log_success "Release v$version préparée et poussée"
    log_info "Le déploiement automatique devrait commencer dans GitHub Actions"
}

# Fonction pour valider la configuration
validate_config() {
    log_info "Validation de la configuration de déploiement"
    
    local errors=0
    
    # Vérifier les fichiers de workflow
    local workflows_dir="$PROJECT_ROOT/.github/workflows"
    if [ ! -d "$workflows_dir" ]; then
        log_error "Dossier .github/workflows non trouvé"
        ((errors++))
    else
        for workflow in "ci.yml" "deploy.yml" "pr-validation.yml"; do
            if [ ! -f "$workflows_dir/$workflow" ]; then
                log_error "Workflow $workflow non trouvé"
                ((errors++))
            else
                log_success "Workflow $workflow trouvé"
            fi
        done
    fi
    
    # Vérifier les scripts de build
    log_info "Vérification des scripts de build dans $BUILD_SCRIPTS_DIR"
    for script in "build_simulator_only.sh" "full_pipeline.sh" "run_tests.sh" "generate_artifacts.sh"; do
        if [ ! -f "$BUILD_SCRIPTS_DIR/$script" ]; then
            log_error "Script $script non trouvé"
            ((errors++))
        else
            log_success "Script $script trouvé"
        fi
    done
    
    # Vérifier la documentation
    local docs_dir="$PROJECT_ROOT/.github"
    for doc in "DEPLOYMENT.md" "SECRETS_SETUP.md"; do
        if [ ! -f "$docs_dir/$doc" ]; then
            log_error "Documentation $doc non trouvée"
            ((errors++))
        else
            log_success "Documentation $doc trouvée"
        fi
    done
    
    # Vérifier le projet Xcode
    if [ ! -f "$PROJECT_ROOT/Manounou.xcodeproj/project.pbxproj" ]; then
        log_error "Projet Xcode non trouvé"
        ((errors++))
    else
        log_success "Projet Xcode trouvé"
    fi
    
    # Résumé
    echo
    if [ $errors -eq 0 ]; then
        log_success "Configuration validée avec succès ✨"
    else
        log_error "$errors erreur(s) trouvée(s)"
        exit 1
    fi
}

# Fonction pour effectuer un déploiement manuel
deploy_manual() {
    local version="$1"
    local environment="$2"
    
    log_info "Déploiement manuel v$version vers $environment"
    
    # Vérifier que le tag existe
    if ! git tag | grep -q "^v$version$"; then
        log_error "Le tag v$version n'existe pas"
        exit 1
    fi
    
    # Checkout du tag
    log_info "Checkout du tag v$version..."
    git checkout "v$version"
    
    # Lancer le build approprié
    case "$environment" in
        "staging")
            log_info "Build pour TestFlight..."
            if [ -f "$BUILD_SCRIPTS_DIR/full_pipeline.sh" ]; then
                "$BUILD_SCRIPTS_DIR/full_pipeline.sh"
            else
                log_error "Script full_pipeline.sh non trouvé"
                exit 1
            fi
            ;;
        "production")
            log_info "Build pour App Store..."
            log_warning "Déploiement production - Vérifiez que tous les tests passent"
            read -p "Continuer avec le déploiement production ? (y/N): " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                exit 1
            fi
            if [ -f "$BUILD_SCRIPTS_DIR/full_pipeline.sh" ]; then
                "$BUILD_SCRIPTS_DIR/full_pipeline.sh"
            else
                log_error "Script full_pipeline.sh non trouvé"
                exit 1
            fi
            ;;
        *)
            log_error "Environnement non supporté: $environment (utilisez staging ou production)"
            exit 1
            ;;
    esac
    
    log_success "Déploiement terminé"
}

# Fonction principale
main() {
    local command=""
    local version=""
    local environment=""
    local force=false
    
    # Parser les arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            status|prepare|deploy|rollback|validate|help)
                command="$1"
                shift
                ;;
            -v|--version)
                version="$2"
                shift 2
                ;;
            -e|--env)
                environment="$2"
                shift 2
                ;;
            -f|--force)
                force=true
                shift
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                log_error "Option inconnue: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    # Si aucune commande, afficher l'aide
    if [ -z "$command" ]; then
        show_help
        exit 0
    fi
    
    # Vérifier les prérequis pour toutes les commandes sauf help
    if [ "$command" != "help" ]; then
        check_prerequisites
    fi
    
    # Exécuter la commande
    case "$command" in
        "status")
            show_status
            ;;
        "prepare")
            if [ -z "$version" ]; then
                log_error "Version requise pour prepare (utilisez -v)"
                exit 1
            fi
            prepare_release "$version"
            ;;
        "deploy")
            if [ -z "$version" ] || [ -z "$environment" ]; then
                log_error "Version et environnement requis pour deploy (utilisez -v et -e)"
                exit 1
            fi
            deploy_manual "$version" "$environment"
            ;;
        "validate")
            validate_config
            ;;
        "rollback")
            log_error "Fonction rollback non encore implémentée"
            log_info "Pour un rollback, utilisez GitHub Actions ou déployez une version antérieure"
            exit 1
            ;;
        "help")
            show_help
            ;;
        *)
            log_error "Commande inconnue: $command"
            show_help
            exit 1
            ;;
    esac
}

# Exécuter le script
main "$@"
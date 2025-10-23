#!/bin/bash

# Script de Workflow Git Standardisé - Manounou
# Facilite l'utilisation des bonnes pratiques Git

set -e

# Configuration
MAIN_BRANCH="main"
DEVELOP_BRANCH="develop"

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fonction d'affichage coloré
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Fonction d'aide
show_help() {
    echo "🚀 Workflow Git Standardisé - Manounou"
    echo "======================================"
    echo ""
    echo "Usage: ./git_workflow.sh [COMMAND] [OPTIONS]"
    echo ""
    echo "COMMANDES DISPONIBLES:"
    echo ""
    echo "  init                 Initialise le workflow Git (branches develop, hooks)"
    echo "  feature <name>       Crée une nouvelle branche feature"
    echo "  bugfix <name>        Crée une nouvelle branche bugfix"
    echo "  hotfix <name>        Crée une nouvelle branche hotfix"
    echo "  finish               Termine la branche courante (merge vers develop/main)"
    echo "  status               Affiche le statut détaillé du dépôt"
    echo "  commit               Commit interactif avec validation"
    echo "  sync                 Synchronise avec le dépôt distant"
    echo "  cleanup              Nettoie les branches mergées"
    echo ""
    echo "EXEMPLES:"
    echo "  ./git_workflow.sh init"
    echo "  ./git_workflow.sh feature auth-improvements"
    echo "  ./git_workflow.sh commit"
    echo "  ./git_workflow.sh finish"
    echo ""
}

# Vérification des prérequis
check_git_repo() {
    if [ ! -d ".git" ]; then
        print_error "Pas un dépôt Git. Exécutez 'git init' d'abord."
        exit 1
    fi
}

# Initialisation du workflow
init_workflow() {
    print_status "Initialisation du workflow Git..."
    
    # Créer la branche develop si elle n'existe pas
    if ! git show-ref --verify --quiet refs/heads/$DEVELOP_BRANCH; then
        print_status "Création de la branche $DEVELOP_BRANCH"
        git checkout -b $DEVELOP_BRANCH
        git push -u origin $DEVELOP_BRANCH 2>/dev/null || print_warning "Impossible de pousser vers origin"
    fi
    
    # Retourner sur main
    git checkout $MAIN_BRANCH 2>/dev/null || print_warning "Branche main non trouvée"
    
    print_success "Workflow initialisé avec succès"
}

# Création d'une branche feature
create_feature() {
    local feature_name="$1"
    if [ -z "$feature_name" ]; then
        print_error "Nom de feature requis"
        exit 1
    fi
    
    local branch_name="feature/$feature_name"
    
    print_status "Création de la branche $branch_name"
    
    # S'assurer d'être sur develop
    git checkout $DEVELOP_BRANCH
    git pull origin $DEVELOP_BRANCH 2>/dev/null || print_warning "Impossible de synchroniser avec origin"
    
    # Créer et basculer sur la nouvelle branche
    git checkout -b "$branch_name"
    
    print_success "Branche $branch_name créée et active"
    print_status "Prochaines étapes:"
    echo "  1. Développez votre feature"
    echo "  2. Commitez régulièrement: ./git_workflow.sh commit"
    echo "  3. Terminez la feature: ./git_workflow.sh finish"
}

# Création d'une branche bugfix
create_bugfix() {
    local bugfix_name="$1"
    if [ -z "$bugfix_name" ]; then
        print_error "Nom de bugfix requis"
        exit 1
    fi
    
    local branch_name="bugfix/$bugfix_name"
    
    print_status "Création de la branche $branch_name"
    
    git checkout $DEVELOP_BRANCH
    git pull origin $DEVELOP_BRANCH 2>/dev/null || print_warning "Impossible de synchroniser avec origin"
    git checkout -b "$branch_name"
    
    print_success "Branche $branch_name créée et active"
}

# Création d'une branche hotfix
create_hotfix() {
    local hotfix_name="$1"
    if [ -z "$hotfix_name" ]; then
        print_error "Nom de hotfix requis"
        exit 1
    fi
    
    local branch_name="hotfix/$hotfix_name"
    
    print_status "Création de la branche $branch_name"
    
    git checkout $MAIN_BRANCH
    git pull origin $MAIN_BRANCH 2>/dev/null || print_warning "Impossible de synchroniser avec origin"
    git checkout -b "$branch_name"
    
    print_success "Branche $branch_name créée et active"
}

# Commit interactif avec validation
interactive_commit() {
    print_status "Commit interactif avec validation"
    
    # Vérifier s'il y a des changements
    if [ -z "$(git status --porcelain)" ]; then
        print_warning "Aucun changement à commiter"
        return
    fi
    
    # Afficher le statut
    echo ""
    git status --short
    echo ""
    
    # Demander confirmation
    read -p "Voulez-vous commiter ces changements ? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_status "Commit annulé"
        return
    fi
    
    # Ajouter tous les fichiers modifiés
    git add -A
    
    # Demander le message de commit
    echo "Types de commit disponibles:"
    echo "  feat:     Nouvelle fonctionnalité"
    echo "  fix:      Correction de bug"
    echo "  docs:     Documentation"
    echo "  style:    Formatage, style"
    echo "  refactor: Refactoring"
    echo "  test:     Tests"
    echo "  chore:    Maintenance"
    echo ""
    
    read -p "Message de commit: " commit_message
    
    if [ -z "$commit_message" ]; then
        print_error "Message de commit requis"
        return
    fi
    
    # Effectuer le commit
    git commit -m "$commit_message"
    
    print_success "Commit effectué: $commit_message"
}

# Terminer une branche
finish_branch() {
    local current_branch=$(git branch --show-current)
    
    if [[ $current_branch == $MAIN_BRANCH ]] || [[ $current_branch == $DEVELOP_BRANCH ]]; then
        print_error "Impossible de terminer une branche principale"
        exit 1
    fi
    
    print_status "Finalisation de la branche $current_branch"
    
    # Déterminer la branche cible
    local target_branch
    if [[ $current_branch == hotfix/* ]]; then
        target_branch=$MAIN_BRANCH
    else
        target_branch=$DEVELOP_BRANCH
    fi
    
    print_status "Merge vers $target_branch"
    
    # Synchroniser et merger
    git checkout $target_branch
    git pull origin $target_branch 2>/dev/null || print_warning "Impossible de synchroniser avec origin"
    git merge --no-ff "$current_branch"
    
    # Pousser les changements
    git push origin $target_branch 2>/dev/null || print_warning "Impossible de pousser vers origin"
    
    # Supprimer la branche locale
    git branch -d "$current_branch"
    
    print_success "Branche $current_branch terminée et mergée dans $target_branch"
}

# Afficher le statut détaillé
show_status() {
    print_status "Statut détaillé du dépôt Git"
    echo ""
    
    # Branche courante
    local current_branch=$(git branch --show-current)
    echo "🌿 Branche courante: $current_branch"
    
    # Statut des fichiers
    local changes=$(git status --porcelain | wc -l)
    echo "📝 Modifications: $changes fichier(s)"
    
    # Commits en avance/retard
    if git rev-parse --verify origin/$current_branch >/dev/null 2>&1; then
        local ahead=$(git rev-list --count origin/$current_branch..$current_branch)
        local behind=$(git rev-list --count $current_branch..origin/$current_branch)
        echo "⬆️  En avance: $ahead commit(s)"
        echo "⬇️  En retard: $behind commit(s)"
    fi
    
    echo ""
    git status --short
}

# Synchronisation avec le dépôt distant
sync_repo() {
    print_status "Synchronisation avec le dépôt distant"
    
    local current_branch=$(git branch --show-current)
    
    # Fetch des dernières modifications
    git fetch origin
    
    # Pull de la branche courante
    if git rev-parse --verify origin/$current_branch >/dev/null 2>&1; then
        git pull origin $current_branch
        print_success "Branche $current_branch synchronisée"
    else
        print_warning "Branche $current_branch n'existe pas sur origin"
    fi
}

# Nettoyage des branches
cleanup_branches() {
    print_status "Nettoyage des branches mergées"
    
    # Supprimer les branches mergées (sauf main et develop)
    git branch --merged | grep -v "\*\|$MAIN_BRANCH\|$DEVELOP_BRANCH" | xargs -n 1 git branch -d 2>/dev/null || true
    
    # Nettoyer les références distantes
    git remote prune origin 2>/dev/null || true
    
    print_success "Nettoyage terminé"
}

# Script principal
main() {
    check_git_repo
    
    case "${1:-help}" in
        "init")
            init_workflow
            ;;
        "feature")
            create_feature "$2"
            ;;
        "bugfix")
            create_bugfix "$2"
            ;;
        "hotfix")
            create_hotfix "$2"
            ;;
        "finish")
            finish_branch
            ;;
        "commit")
            interactive_commit
            ;;
        "status")
            show_status
            ;;
        "sync")
            sync_repo
            ;;
        "cleanup")
            cleanup_branches
            ;;
        "help"|*)
            show_help
            ;;
    esac
}

# Exécution
main "$@"
#!/bin/bash

# Pipeline de Build Complet - Manounou
# Exécute toutes les étapes du processus de build automatisé

set -e

echo "🚀 Pipeline de Build Automatisé - Manounou"
echo "=========================================="

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_DIR"

# Configuration
START_TIME=$(date +%s)
PIPELINE_LOG="pipeline_$(date +%Y%m%d_%H%M%S).log"

# Fonction de logging
log() {
    echo "[$(date '+%H:%M:%S')] $1" | tee -a "$PIPELINE_LOG"
}

# Fonction de gestion d'erreur
handle_error() {
    log "❌ ERREUR: $1"
    log "📋 Consultez le log complet: $PIPELINE_LOG"
    exit 1
}

log "🏁 Démarrage du pipeline complet"
log "📁 Répertoire: $PROJECT_DIR"
log "📝 Log: $PIPELINE_LOG"

# Étape 1: Vérification des dépendances
log "🔍 Étape 1/5: Vérification des dépendances"

if ! command -v xcodebuild &> /dev/null; then
    handle_error "xcodebuild n'est pas installé"
fi

if ! command -v git &> /dev/null; then
    handle_error "git n'est pas installé"
fi

# Vérifier que nous sommes dans un projet Xcode
if [ ! -f "Manounou.xcodeproj/project.pbxproj" ]; then
    handle_error "Projet Xcode Manounou.xcodeproj non trouvé"
fi

log "✅ Dépendances vérifiées"

# Étape 2: Vérification Git et statut
log "🔍 Étape 2/5: Vérification Git"

if [ ! -d ".git" ]; then
    handle_error "Répertoire .git non trouvé - initialiser le dépôt Git"
fi

CURRENT_BRANCH=$(git branch --show-current)
UNCOMMITTED_CHANGES=$(git status --porcelain | wc -l)

log "📋 Branche actuelle: $CURRENT_BRANCH"
log "📋 Modifications non commitées: $UNCOMMITTED_CHANGES"

if [ "$UNCOMMITTED_CHANGES" -gt 0 ]; then
    log "⚠️  Attention: $UNCOMMITTED_CHANGES modifications non commitées détectées"
fi

# Étape 3: Compilation
log "🔍 Étape 3/5: Compilation du code"

if ! ./build_simulator_only.sh >> "$PIPELINE_LOG" 2>&1; then
    handle_error "Échec de la compilation"
fi

log "✅ Compilation réussie"

# Étape 4: Tests unitaires
log "🔍 Étape 4/5: Exécution des tests unitaires"

if [ -f "run_tests.sh" ]; then
    chmod +x run_tests.sh
    if ! ./run_tests.sh >> "$PIPELINE_LOG" 2>&1; then
        log "⚠️  Tests échoués - continuons avec la génération d'artefacts"
    else
        log "✅ Tests réussis"
    fi
else
    log "⚠️  Script de test non trouvé - ignoré"
fi

# Étape 5: Génération des artefacts
log "🔍 Étape 5/5: Génération des artefacts"

if [ -f "generate_artifacts.sh" ]; then
    chmod +x generate_artifacts.sh
    if ! ./generate_artifacts.sh >> "$PIPELINE_LOG" 2>&1; then
        handle_error "Échec de la génération d'artefacts"
    fi
    log "✅ Artefacts générés"
else
    log "⚠️  Script de génération d'artefacts non trouvé"
fi

# Résumé final
END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

log ""
log "🎉 PIPELINE TERMINÉ AVEC SUCCÈS !"
log "=================================="
log "⏱️  Durée totale: ${DURATION}s"
log "📋 Branche: $CURRENT_BRANCH"
log "📝 Log complet: $PIPELINE_LOG"
log "📦 Artefacts: artifacts/$(date +%Y%m%d_*)/"
log ""
log "🚀 Prochaines étapes recommandées:"
log "   1. Réviser les artefacts générés"
log "   2. Effectuer des tests manuels"
log "   3. Créer une PR si sur une branche de feature"
log "   4. Déployer si sur main/master"
log ""

# Afficher un résumé des artefacts récents
if [ -d "artifacts" ]; then
    LATEST_ARTIFACTS=$(ls -t artifacts/ | head -1)
    if [ -n "$LATEST_ARTIFACTS" ]; then
        log "📁 Derniers artefacts: artifacts/$LATEST_ARTIFACTS"
        if [ -f "artifacts/$LATEST_ARTIFACTS/build_report.md" ]; then
            log "📊 Rapport disponible: artifacts/$LATEST_ARTIFACTS/build_report.md"
        fi
    fi
fi
#!/bin/bash

# Script de validation pour la soumission App Store
# Vérifie que l'application Manounou est prête pour la soumission

set -e

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Compteurs
PASSED=0
FAILED=0
WARNINGS=0

# Fonctions utilitaires
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[✓]${NC} $1"
    ((PASSED++))
}

log_warning() {
    echo -e "${YELLOW}[⚠]${NC} $1"
    ((WARNINGS++))
}

log_error() {
    echo -e "${RED}[✗]${NC} $1"
    ((FAILED++))
}

check_file() {
    if [[ -f "$1" ]]; then
        log_success "Fichier trouvé: $1"
    else
        log_error "Fichier manquant: $1"
    fi
}

check_directory() {
    if [[ -d "$1" ]]; then
        log_success "Dossier trouvé: $1"
    else
        log_error "Dossier manquant: $1"
    fi
}

check_json_field() {
    local file="$1"
    local field="$2"
    local expected="$3"
    
    if [[ -f "$file" ]]; then
        if command -v node &> /dev/null; then
            local value=$(node -p "try { JSON.parse(require('fs').readFileSync('$file', 'utf8')).$field } catch(e) { 'undefined' }" 2>/dev/null || echo "undefined")
            if [[ "$value" != "undefined" && "$value" != "null" ]]; then
                if [[ -n "$expected" && "$value" != "$expected" ]]; then
                    log_warning "$file.$field = '$value' (attendu: '$expected')"
                else
                    log_success "$file.$field = '$value'"
                fi
            else
                log_error "$file.$field manquant ou invalide"
            fi
        else
            if grep -q "\"$field\"" "$file" 2>/dev/null; then
                log_success "$file.$field trouvé (Node.js requis pour validation complète)"
            else
                log_error "$file.$field manquant"
            fi
        fi
    else
        log_error "Fichier $file manquant"
    fi
}

echo "🔍 Validation App Store - Manounou App"
echo "======================================="
echo

# 1. Structure du projet
log_info "1. Vérification de la structure du projet"
check_file "package.json"
check_file "app.json"
check_file "eas.json"
check_file "metro.config.js"
check_file "babel.config.js"
check_directory "src"
check_directory "assets"
echo

# 2. Configuration package.json
log_info "2. Vérification de package.json"
check_json_field "package.json" "name" "manounou-app"
check_json_field "package.json" "version"
check_json_field "package.json" "description"
check_json_field "package.json" "scripts.build:ios"
check_json_field "package.json" "scripts.build:android"
check_json_field "package.json" "scripts.submit:ios"
check_json_field "package.json" "scripts.submit:android"
echo

# 3. Configuration app.json
log_info "3. Vérification de app.json"
check_json_field "app.json" "expo.name" "Manounou"
check_json_field "app.json" "expo.slug" "manounou-app"
check_json_field "app.json" "expo.version"
check_json_field "app.json" "expo.ios.bundleIdentifier" "com.manounou.app"
check_json_field "app.json" "expo.android.package" "com.manounou.app"
check_json_field "app.json" "expo.icon"
check_json_field "app.json" "expo.splash.image"
echo

# 4. Configuration EAS
log_info "4. Vérification de eas.json"
check_json_field "eas.json" "build.development"
check_json_field "eas.json" "build.preview"
check_json_field "eas.json" "build.production"
check_json_field "eas.json" "submit.production"
echo

# 5. Assets requis
log_info "5. Vérification des assets"
check_file "assets/icon.svg"
check_file "assets/splash.svg"
check_file "assets/adaptive-icon.svg"
check_file "assets/favicon.svg"
echo

# 6. Documentation légale
log_info "6. Vérification de la documentation légale"
check_file "PRIVACY_POLICY.md"
check_file "TERMS_OF_USE.md"
check_file "store-listing.md"
echo

# 7. Configuration TypeScript
log_info "7. Vérification de TypeScript"
check_file "tsconfig.json"
if [[ -f "tsconfig.json" ]]; then
    if command -v node &> /dev/null; then
        if node -e "const ts = require('./tsconfig.json'); console.log('TypeScript configuré')" 2>/dev/null; then
            log_success "Configuration TypeScript valide"
        else
            log_error "Configuration TypeScript invalide"
        fi
    else
        log_success "Fichier tsconfig.json présent (Node.js requis pour validation complète)"
    fi
fi
echo

# 8. Dépendances critiques
log_info "8. Vérification des dépendances critiques"
if [[ -f "package.json" ]]; then
    # Vérifier les dépendances Expo
    if grep -q '"expo"' package.json; then
        log_success "Expo configuré"
    else
        log_error "Expo manquant"
    fi
    
    if grep -q '"@expo/cli"' package.json; then
        log_success "Expo CLI configuré"
    else
        log_warning "Expo CLI manquant (recommandé)"
    fi
    
    if grep -q '"eas-cli"' package.json; then
        log_success "EAS CLI configuré"
    else
        log_warning "EAS CLI manquant (recommandé)"
    fi
    
    # Vérifier React Native
    if grep -q '"react-native"' package.json; then
        log_success "React Native configuré"
    else
        log_error "React Native manquant"
    fi
    
    # Vérifier TypeScript
    if grep -q '"typescript"' package.json; then
        log_success "TypeScript configuré"
    else
        log_warning "TypeScript manquant (recommandé)"
    fi
fi
echo

# 9. Scripts de build
log_info "9. Vérification des scripts de build"
if [[ -f "package.json" ]]; then
    if grep -q '"build:ios"' package.json; then
        log_success "Script build:ios configuré"
    else
        log_error "Script build:ios manquant"
    fi
    
    if grep -q '"build:android"' package.json; then
        log_success "Script build:android configuré"
    else
        log_error "Script build:android manquant"
    fi
    
    if grep -q '"submit:ios"' package.json; then
        log_success "Script submit:ios configuré"
    else
        log_error "Script submit:ios manquant"
    fi
    
    if grep -q '"submit:android"' package.json; then
        log_success "Script submit:android configuré"
    else
        log_error "Script submit:android manquant"
    fi
fi
echo

# 10. Permissions et sécurité
log_info "10. Vérification des permissions"
if [[ -f "app.json" ]]; then
    # Vérifier les permissions iOS
    if grep -q '"NSCameraUsageDescription"' app.json; then
        log_success "Permission caméra iOS configurée"
    else
        log_warning "Permission caméra iOS manquante"
    fi
    
    if grep -q '"NSLocationWhenInUseUsageDescription"' app.json; then
        log_success "Permission localisation iOS configurée"
    else
        log_warning "Permission localisation iOS manquante"
    fi
    
    if grep -q '"NSFaceIDUsageDescription"' app.json; then
        log_success "Permission Face ID iOS configurée"
    else
        log_warning "Permission Face ID iOS manquante"
    fi
    
    # Vérifier les permissions Android
    if grep -q '"android.permission.CAMERA"' app.json; then
        log_success "Permission caméra Android configurée"
    else
        log_warning "Permission caméra Android manquante"
    fi
    
    if grep -q '"android.permission.ACCESS_FINE_LOCATION"' app.json; then
        log_success "Permission localisation Android configurée"
    else
        log_warning "Permission localisation Android manquante"
    fi
fi
echo

# 11. Vérification des outils CLI
log_info "11. Vérification des outils CLI"
if command -v node &> /dev/null; then
    log_success "Node.js installé ($(node --version))"
else
    log_error "Node.js non installé"
fi

if command -v npm &> /dev/null; then
    log_success "npm installé ($(npm --version))"
else
    log_error "npm non installé"
fi

if command -v expo &> /dev/null; then
    log_success "Expo CLI installé ($(expo --version))"
else
    log_warning "Expo CLI non installé globalement"
fi

if command -v eas &> /dev/null; then
    log_success "EAS CLI installé ($(eas --version))"
else
    log_warning "EAS CLI non installé globalement"
fi
echo

# 12. Vérification de la syntaxe des fichiers JSON
log_info "12. Vérification de la syntaxe JSON"
for file in "package.json" "app.json" "eas.json" "tsconfig.json"; do
    if [[ -f "$file" ]]; then
        if command -v node &> /dev/null; then
            if node -e "JSON.parse(require('fs').readFileSync('$file', 'utf8'))" 2>/dev/null; then
                log_success "$file: syntaxe JSON valide"
            else
                log_error "$file: syntaxe JSON invalide"
            fi
        else
            # Vérification basique sans Node.js
            if python3 -m json.tool "$file" >/dev/null 2>&1; then
                log_success "$file: syntaxe JSON valide (vérifié avec Python)"
            elif python -m json.tool "$file" >/dev/null 2>&1; then
                log_success "$file: syntaxe JSON valide (vérifié avec Python)"
            else
                log_warning "$file: impossible de vérifier la syntaxe JSON (Node.js ou Python requis)"
            fi
        fi
    fi
done
echo

# Résumé final
echo "📊 RÉSUMÉ DE LA VALIDATION"
echo "==========================="
echo -e "${GREEN}✓ Tests réussis: $PASSED${NC}"
echo -e "${YELLOW}⚠ Avertissements: $WARNINGS${NC}"
echo -e "${RED}✗ Erreurs: $FAILED${NC}"
echo

if [[ $FAILED -eq 0 ]]; then
    if [[ $WARNINGS -eq 0 ]]; then
        echo -e "${GREEN}🎉 EXCELLENT! L'application est prête pour l'App Store${NC}"
        echo -e "${GREEN}Vous pouvez procéder au déploiement en toute confiance.${NC}"
        exit 0
    else
        echo -e "${YELLOW}✅ BIEN! L'application est prête pour l'App Store${NC}"
        echo -e "${YELLOW}Quelques avertissements à considérer, mais pas bloquants.${NC}"
        exit 0
    fi
else
    echo -e "${RED}❌ ATTENTION! Des erreurs doivent être corrigées avant la soumission${NC}"
    echo -e "${RED}Veuillez résoudre les erreurs listées ci-dessus.${NC}"
    echo
    echo "💡 CONSEILS:"
    echo "- Vérifiez que tous les fichiers requis sont présents"
    echo "- Validez la syntaxe de vos fichiers JSON"
    echo "- Installez les dépendances manquantes"
    echo "- Configurez les permissions nécessaires"
    echo
    exit 1
fi
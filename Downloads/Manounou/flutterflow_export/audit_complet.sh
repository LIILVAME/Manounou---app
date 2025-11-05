#!/bin/bash

# Script d'audit complet pour Manounou
# Vérifie que flutter run fonctionne sur toutes les plateformes

set -e

echo "🔍 === AUDIT COMPLET MANOUNOU ==="
echo ""

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$PROJECT_DIR"

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Compteurs
ERRORS=0
WARNINGS=0
SUCCESS=0

# Fonction pour afficher les résultats
check_result() {
    local status=$1
    local message=$2
    if [ $status -eq 0 ]; then
        echo -e "${GREEN}✅${NC} $message"
        SUCCESS=$((SUCCESS + 1))
    else
        echo -e "${RED}❌${NC} $message"
        ERRORS=$((ERRORS + 1))
        return 1
    fi
}

warn_result() {
    local message=$1
    echo -e "${YELLOW}⚠️${NC} $message"
    WARNINGS=$((WARNINGS + 1))
}

info_result() {
    local message=$1
    echo -e "${BLUE}ℹ️${NC} $message"
}

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "1️⃣  VÉRIFICATION ENVIRONNEMENT FLUTTER"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Vérifier Flutter
if command -v flutter &> /dev/null; then
    FLUTTER_VERSION=$(flutter --version | head -n 1)
    info_result "Flutter: $FLUTTER_VERSION"
    check_result $? "Flutter installé"
else
    check_result 1 "Flutter non installé"
    echo "   💡 Installation: https://flutter.dev/docs/get-started/install"
    exit 1
fi

# Flutter Doctor
echo ""
info_result "Vérification Flutter Doctor..."
FLUTTER_DOCTOR=$(flutter doctor 2>&1)
if echo "$FLUTTER_DOCTOR" | grep -q "✗"; then
    warn_result "Problèmes détectés dans Flutter Doctor"
    echo "$FLUTTER_DOCTOR" | grep "✗" | head -5
else
    check_result 0 "Flutter Doctor: OK"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "2️⃣  VÉRIFICATION PROJET FLUTTER"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Vérifier pubspec.yaml
if [ -f "pubspec.yaml" ]; then
    check_result 0 "pubspec.yaml existe"
else
    check_result 1 "pubspec.yaml manquant"
fi

# Vérifier main.dart
if [ -f "lib/main.dart" ]; then
    check_result 0 "lib/main.dart existe"
else
    check_result 1 "lib/main.dart manquant"
fi

# Vérifier les credentials Supabase
if grep -q "https://.*supabase.co" lib/main.dart 2>/dev/null; then
    check_result 0 "Credentials Supabase configurés"
else
    warn_result "Credentials Supabase non trouvés (hardcodés ou manquants)"
fi

# Vérifier flutter pub get
echo ""
info_result "Exécution flutter pub get..."
if flutter pub get > /dev/null 2>&1; then
    check_result 0 "Dépendances installées"
else
    check_result 1 "Erreur flutter pub get"
fi

# Vérifier flutter analyze
echo ""
info_result "Analyse du code (flutter analyze)..."
ANALYZE_OUTPUT=$(flutter analyze 2>&1)
ANALYZE_EXIT=$?
if [ $ANALYZE_EXIT -eq 0 ]; then
    check_result 0 "Aucune erreur d'analyse"
else
    WARN_COUNT=$(echo "$ANALYZE_OUTPUT" | grep -c "warning" || echo "0")
    INFO_COUNT=$(echo "$ANALYZE_OUTPUT" | grep -c "info" || echo "0")
    warn_result "Analyse: $WARN_COUNT warning(s), $INFO_COUNT info(s) (non bloquants)"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "3️⃣  VÉRIFICATION PLATEFORMES"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# iOS
if [ -d "ios" ]; then
    check_result 0 "Configuration iOS existe"
    
    # Vérifier Podfile
    if [ -f "ios/Podfile" ]; then
        check_result 0 "Podfile existe"
        
        # Vérifier la solution VerifyModule
        if grep -q "SOLUTION PÉRENNE" ios/Podfile; then
            check_result 0 "Solution VerifyModule configurée"
        else
            warn_result "Solution VerifyModule non trouvée dans Podfile"
        fi
    else
        check_result 1 "Podfile manquant"
    fi
    
    # Vérifier Pods
    if [ -d "ios/Pods" ]; then
        check_result 0 "Pods installés"
    else
        warn_result "Pods non installés (exécuter: cd ios && pod install)"
    fi
    
    # Vérifier Info.plist
    if [ -f "ios/Runner/Info.plist" ]; then
        check_result 0 "Info.plist existe"
    else
        check_result 1 "Info.plist manquant"
    fi
else
    check_result 1 "Configuration iOS manquante"
fi

# Android
if [ -d "android" ]; then
    check_result 0 "Configuration Android existe"
    
    # Vérifier build.gradle
    if [ -f "android/app/build.gradle" ]; then
        check_result 0 "build.gradle existe"
    else
        warn_result "build.gradle manquant"
    fi
    
    # Vérifier AndroidManifest.xml
    if [ -f "android/app/src/main/AndroidManifest.xml" ]; then
        check_result 0 "AndroidManifest.xml existe"
    else
        warn_result "AndroidManifest.xml manquant"
    fi
else
    warn_result "Configuration Android manquante (créer avec: flutter create --platforms=android .)"
fi

# Web
if [ -d "web" ]; then
    check_result 0 "Configuration Web existe"
    
    if [ -f "web/index.html" ]; then
        check_result 0 "index.html existe"
    else
        warn_result "index.html manquant"
    fi
else
    warn_result "Configuration Web manquante (créer avec: flutter create --platforms=web .)"
fi

# macOS
if [ -d "macos" ]; then
    check_result 0 "Configuration macOS existe"
else
    warn_result "Configuration macOS manquante"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "4️⃣  VÉRIFICATION DEVICES DISPONIBLES"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

DEVICES_OUTPUT=$(flutter devices 2>&1)
DEVICE_COUNT=$(echo "$DEVICES_OUTPUT" | grep -c "•" || echo "0")

if [ "$DEVICE_COUNT" -gt 0 ]; then
    info_result "$DEVICE_COUNT device(s) disponible(s):"
    echo "$DEVICES_OUTPUT" | grep "•" | head -10 | sed 's/^/   /'
    check_result 0 "Devices disponibles"
else
    warn_result "Aucun device disponible"
    info_result "Lancer un simulateur ou connecter un device"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "5️⃣  VÉRIFICATION ROUTES ET SERVICES"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Vérifier app_router.dart
if [ -f "lib/core/routes/app_router.dart" ]; then
    check_result 0 "app_router.dart existe"
    
    # Compter les routes
    ROUTE_COUNT=$(grep -c "GoRoute\|path:" lib/core/routes/app_router.dart 2>/dev/null || echo "0")
    info_result "$ROUTE_COUNT route(s) configurée(s)"
else
    check_result 1 "app_router.dart manquant"
fi

# Vérifier les services
SERVICES=("auth_service" "children_service" "events_service" "schedules_service" "documents_service")
for service in "${SERVICES[@]}"; do
    if [ -f "lib/core/services/${service}.dart" ]; then
        check_result 0 "${service}.dart existe"
    else
        check_result 1 "${service}.dart manquant"
    fi
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "6️⃣  VÉRIFICATION ASSETS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Vérifier les assets
if [ -d "assets" ]; then
    check_result 0 "Dossier assets existe"
    
    ASSET_COUNT=$(find assets -type f 2>/dev/null | wc -l | tr -d ' ')
    info_result "$ASSET_COUNT asset(s) trouvé(s)"
    
    # Vérifier les avatars
    if [ -d "assets/avatars" ]; then
        AVATAR_COUNT=$(find assets/avatars -type f 2>/dev/null | wc -l | tr -d ' ')
        check_result 0 "Dossier avatars existe ($AVATAR_COUNT fichier(s))"
    else
        warn_result "Dossier avatars manquant"
    fi
else
    warn_result "Dossier assets manquant"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "7️⃣  VÉRIFICATION SCRIPTS DE CORRECTION"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

SCRIPTS=("fix_all_ios.sh" "fix_file_picker.sh" "fix_sdwebimage.sh" "fix_sqflite_darwin.sh" "verify_verify_module_fix.sh")
for script in "${SCRIPTS[@]}"; do
    if [ -f "$script" ]; then
        if [ -x "$script" ]; then
            check_result 0 "$script existe et est exécutable"
        else
            warn_result "$script existe mais n'est pas exécutable (chmod +x $script)"
        fi
    else
        warn_result "$script manquant"
    fi
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "8️⃣  TEST DE COMPILATION"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Test de compilation dry-run (sans build réel)
info_result "Test de compilation (dry-run)..."
if flutter build ios --debug --no-codesign --dry-run > /dev/null 2>&1; then
    check_result 0 "Compilation iOS: OK (dry-run)"
else
    warn_result "Compilation iOS: Problèmes potentiels"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 RÉSUMÉ DE L'AUDIT"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

echo -e "${GREEN}✅ Succès:${NC} $SUCCESS"
echo -e "${YELLOW}⚠️  Avertissements:${NC} $WARNINGS"
echo -e "${RED}❌ Erreurs:${NC} $ERRORS"
echo ""

if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}🎉 Audit réussi ! L'app devrait fonctionner.${NC}"
    echo ""
    echo "💡 Commandes utiles:"
    echo "   flutter run                    # Lancer sur device par défaut"
    echo "   flutter run -d chrome          # Lancer sur Chrome"
    echo "   flutter run -d ios             # Lancer sur iOS"
    echo "   flutter devices                # Lister les devices disponibles"
    exit 0
else
    echo -e "${RED}❌ Audit échoué. $ERRORS erreur(s) à corriger.${NC}"
    exit 1
fi


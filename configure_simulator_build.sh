#!/bin/bash

# Script de configuration pour compilation simulateur uniquement
# Résout les problèmes de comptes développeur et profils de provisioning

set -e

echo "🔧 Configuration du projet Manounou pour simulateur uniquement..."

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_FILE="$PROJECT_DIR/Manounou.xcodeproj/project.pbxproj"

# Backup du fichier de projet
echo "📋 Sauvegarde du fichier de projet..."
cp "$PROJECT_FILE" "$PROJECT_FILE.backup"

# Fonction pour modifier les paramètres de build
configure_build_settings() {
    echo "⚙️ Configuration des paramètres de build..."
    
    # Utiliser sed pour modifier les paramètres de signature
    sed -i '' 's/CODE_SIGN_IDENTITY = "Apple Development";/CODE_SIGN_IDENTITY = "";/g' "$PROJECT_FILE"
    sed -i '' 's/CODE_SIGN_STYLE = Automatic;/CODE_SIGN_STYLE = Manual;/g' "$PROJECT_FILE"
    sed -i '' 's/DEVELOPMENT_TEAM = 3WV6654695;/DEVELOPMENT_TEAM = "";/g' "$PROJECT_FILE"
    sed -i '' 's/PROVISIONING_PROFILE_SPECIFIER = "";/PROVISIONING_PROFILE_SPECIFIER = "";/g' "$PROJECT_FILE"
    
    # Ajouter la configuration pour simulateur uniquement
    sed -i '' 's/TARGETED_DEVICE_FAMILY = "1,2";/TARGETED_DEVICE_FAMILY = "1,2";\
				ONLY_ACTIVE_ARCH = YES;\
				SUPPORTS_MACCATALYST = NO;/g' "$PROJECT_FILE"
    
    echo "✅ Paramètres de build configurés"
}

# Fonction pour nettoyer le cache Xcode
clean_xcode_cache() {
    echo "🧹 Nettoyage du cache Xcode..."
    
    # Nettoyer les données dérivées
    rm -rf ~/Library/Developer/Xcode/DerivedData/Manounou-*
    
    # Nettoyer le cache des modules
    rm -rf ~/Library/Developer/Xcode/UserData/IDEFindNavigatorScopes.plist
    
    echo "✅ Cache nettoyé"
}

# Fonction pour tester la compilation
test_build() {
    echo "🔨 Test de compilation sur simulateur..."
    
    cd "$PROJECT_DIR"
    
    # Lister les simulateurs disponibles
    echo "📱 Simulateurs disponibles :"
    xcrun simctl list devices available | grep iPhone | head -5
    
    # Tenter une compilation pour simulateur
    xcodebuild clean -project Manounou.xcodeproj -scheme Manounou -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest' > /dev/null 2>&1 || true
    
    echo "🔨 Compilation de test..."
    if xcodebuild build -project Manounou.xcodeproj -scheme Manounou -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest' -quiet; then
        echo "✅ Compilation réussie sur simulateur !"
        return 0
    else
        echo "❌ Échec de compilation, tentative de résolution..."
        return 1
    fi
}

# Fonction pour restaurer la sauvegarde
restore_backup() {
    echo "🔄 Restauration de la sauvegarde..."
    cp "$PROJECT_FILE.backup" "$PROJECT_FILE"
    echo "✅ Sauvegarde restaurée"
}

# Exécution principale
main() {
    echo "🚀 Début de la configuration..."
    
    # Vérifier que le projet existe
    if [ ! -f "$PROJECT_FILE" ]; then
        echo "❌ Fichier de projet non trouvé : $PROJECT_FILE"
        exit 1
    fi
    
    # Nettoyer le cache
    clean_xcode_cache
    
    # Configurer les paramètres de build
    configure_build_settings
    
    # Tester la compilation
    if test_build; then
        echo "🎉 Configuration réussie ! Le projet peut maintenant être compilé sur simulateur."
        echo "📝 Pour lancer l'application :"
        echo "   ./test_modern_app.sh"
    else
        echo "⚠️ Problème de compilation détecté, restauration de la sauvegarde..."
        restore_backup
        echo "❌ Configuration échouée. Vérifiez les erreurs ci-dessus."
        exit 1
    fi
    
    echo "✅ Configuration terminée avec succès !"
}

# Gestion des erreurs
trap 'echo "❌ Erreur détectée, restauration de la sauvegarde..."; restore_backup; exit 1' ERR

# Lancer le script principal
main "$@"
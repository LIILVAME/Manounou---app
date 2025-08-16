# 🎯 Guide d'Étapes Précises - Manounou App

## ✅ Étapes Testées et Fonctionnelles

### 1. **Vérification de l'État Actuel**

```bash
# Vérifier que vous êtes dans le bon répertoire
pwd
# Doit afficher: /Users/vametoure/Library/Mobile Documents/com~apple~CloudDocs/VAM/PROJETS - STARTUP/Manounou - app

# Vérifier que les dépendances sont installées
ls node_modules | wc -l
# Doit afficher un nombre > 500
```

### 2. **Configuration des Variables d'Environnement (OBLIGATOIRE)**

```bash
# Copier le fichier d'exemple
cp .env.example .env

# Éditer le fichier .env avec vos vraies valeurs
nano .env
```

**Variables MINIMALES à configurer :**
```bash
# Dans .env, remplacez ces valeurs:
EXPO_PROJECT_ID=votre-vrai-project-id
EXPO_PUBLIC_SUPABASE_URL=https://votre-projet.supabase.co
EXPO_PUBLIC_SUPABASE_ANON_KEY=votre-vraie-cle-anon
```

### 3. **Correction des Erreurs de Code (ÉTAPES PRÉCISES)**

#### 3.1 Corriger l'erreur JSX dans SettingsScreen
```bash
# Ouvrir le fichier problématique
nano src/screens/main/SettingsScreen.tsx

# Aller à la ligne 145 et corriger la balise Title non fermée
# Remplacer:
<Title
# Par:
<Title>Paramètres</Title>
```

#### 3.2 Corriger les erreurs de formatage automatiquement
```bash
# Corriger automatiquement ce qui peut l'être
npm run lint:fix

# Si des erreurs persistent, les corriger manuellement:
# - Remplacer les guillemets doubles par des simples
# - Ajouter les virgules manquantes
# - Supprimer les espaces en fin de ligne
```

### 4. **Tests de Validation (DANS L'ORDRE)**

#### 4.1 Test TypeScript
```bash
npm run type-check
# ✅ Doit passer sans erreur
```

#### 4.2 Test de Build
```bash
npm run web
# ✅ Doit démarrer le serveur sur http://localhost:8081
```

#### 4.3 Test de l'Application
```bash
# Ouvrir http://localhost:8081 dans votre navigateur
# ✅ Doit afficher l'interface de l'app
```

### 5. **Configuration EAS (Pour le Déploiement)**

#### 5.1 Installation et Login
```bash
# Installer EAS CLI globalement
npm install -g eas-cli

# Se connecter à Expo
eas login
# Entrez vos identifiants Expo
```

#### 5.2 Configuration du Projet
```bash
# Configurer EAS pour votre projet
eas build:configure

# Suivre les instructions à l'écran:
# - Choisir 'Y' pour créer un nouveau projet
# - Sélectionner les plateformes (iOS/Android)
```

#### 5.3 Premier Build de Test
```bash
# Build de développement (plus rapide)
eas build --profile development --platform ios

# OU pour Android
eas build --profile development --platform android
```

### 6. **Configuration App Store (iOS)**

#### 6.1 Prérequis Apple
```bash
# Vous devez avoir:
# - Un compte Apple Developer (99$/an)
# - Xcode installé sur Mac
# - Certificats de développement configurés
```

#### 6.2 Configuration dans .env
```bash
# Ajouter dans .env:
APPLE_ID=votre-apple-id@example.com
ASC_APP_ID=votre-app-store-connect-id
APPLE_TEAM_ID=votre-team-id
```

#### 6.3 Build de Production iOS
```bash
# Build pour l'App Store
eas build --profile production --platform ios

# Attendre la fin du build (15-30 minutes)
# Télécharger le fichier .ipa généré
```

#### 6.4 Soumission à l'App Store
```bash
# Soumettre automatiquement
eas submit --platform ios

# OU manuellement via App Store Connect
# Uploader le fichier .ipa via Transporter ou Xcode
```

### 7. **Configuration Google Play (Android)**

#### 7.1 Prérequis Google
```bash
# Vous devez avoir:
# - Un compte Google Play Developer (25$ une fois)
# - Un fichier de clé de service Google
```

#### 7.2 Configuration du Service Account
```bash
# Télécharger le fichier JSON depuis Google Cloud Console
# Le placer dans le répertoire du projet
mv ~/Downloads/google-service-account.json .

# Ajouter dans .env:
GOOGLE_SERVICE_ACCOUNT_KEY_PATH=./google-service-account.json
```

#### 7.3 Build et Soumission Android
```bash
# Build pour Google Play
eas build --profile production --platform android

# Soumettre au Play Store
eas submit --platform android
```

### 8. **Vérifications Finales**

#### 8.1 Checklist Technique
```bash
# Vérifier tous les tests
npm run type-check && echo "✅ TypeScript OK"
npm test && echo "✅ Tests OK"
npm run web && echo "✅ Web OK"
```

#### 8.2 Checklist App Store
```bash
# Vérifier le script de validation
chmod +x scripts/validate-app-store.sh
./scripts/validate-app-store.sh
```

## 🚨 Problèmes Courants et Solutions

### Erreur: "Expo project not found"
```bash
# Solution:
eas init
# Suivre les instructions pour créer un nouveau projet
```

### Erreur: "Invalid bundle identifier"
```bash
# Solution: Vérifier dans app.json
# "bundleIdentifier": "com.manounou.app" (iOS)
# "package": "com.manounou.app" (Android)
```

### Erreur: "Supabase connection failed"
```bash
# Solution: Vérifier les variables d'environnement
echo $EXPO_PUBLIC_SUPABASE_URL
echo $EXPO_PUBLIC_SUPABASE_ANON_KEY
```

### Erreur: "Metro bundler failed"
```bash
# Solution: Nettoyer le cache
npx expo start --clear
# OU
rm -rf node_modules && npm install
```

## 📞 Support

Si vous rencontrez des problèmes avec ces étapes :

1. **Vérifiez d'abord** que vous avez suivi EXACTEMENT les étapes dans l'ordre
2. **Copiez l'erreur complète** et cherchez dans la documentation Expo
3. **Consultez** les logs détaillés avec `eas build --platform ios --verbose`

## ✅ Validation Finale

Une fois toutes les étapes terminées, vous devriez avoir :

- ✅ Application qui se lance sans erreur
- ✅ Build EAS fonctionnel
- ✅ Configuration App Store/Play Store
- ✅ Variables d'environnement configurées
- ✅ Tests qui passent

**Temps estimé total : 2-4 heures (selon l'expérience)**
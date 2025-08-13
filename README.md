# 🍼 Manounou App

> Application mobile pour la gestion de garde d'enfants développée avec React Native et Expo.

[![React Native](https://img.shields.io/badge/React%20Native-0.73.6-blue.svg)](https://reactnative.dev/)
[![Expo](https://img.shields.io/badge/Expo-50.0.21-black.svg)](https://expo.dev/)
[![TypeScript](https://img.shields.io/badge/TypeScript-5.3.0-blue.svg)](https://www.typescriptlang.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Fonctionnalités Principales

### 🏠 Tableau de Bord
- Vue d'ensemble des activités du jour
- Statistiques rapides
- Notifications importantes
- Accès rapide aux fonctionnalités principales

### 👶 Gestion des Enfants
- Profils détaillés des enfants
- Informations médicales et allergies
- Contacts d'urgence
- Historique des activités

### 📅 Planification
- Planification des activités quotidiennes
- Gestion des horaires
- Suivi des repas et siestes
- Activités éducatives et récréatives

### 📄 Documents
- Stockage sécurisé des documents
- Rapports d'activités
- Certificats médicaux
- Photos et vidéos

### 🏖️ Vacances
- Planification des congés
- Gestion des absences
- Calendrier des vacances

### 👤 Profil Utilisateur
- Gestion du compte
- Paramètres de l'application
- Préférences de notification
- Support et aide

## Architecture Technique

### Technologies Utilisées
- **React Native** - Framework mobile cross-platform
- **TypeScript** - Typage statique pour JavaScript
- **React Navigation** - Navigation entre écrans
- **React Native Paper** - Composants UI Material Design
- **React Context** - Gestion d'état globale
- **AsyncStorage** - Stockage local persistant

### Structure du Projet
```
src/
├── components/          # Composants réutilisables
├── screens/            # Écrans de l'application
│   ├── auth/          # Écrans d'authentification
│   ├── main/          # Écrans principaux
│   └── onboarding/    # Écran d'accueil
├── navigation/         # Configuration de navigation
├── contexts/          # Contextes React (Auth, I18n)
├── constants/         # Constantes (thème, traductions)
├── types/            # Définitions TypeScript
└── utils/            # Fonctions utilitaires
```

### Fonctionnalités Techniques
- **Authentification** - Système de connexion sécurisé
- **Internationalisation** - Support multilingue (FR/EN)
- **Thème adaptatif** - Mode sombre/clair
- **Navigation intuitive** - Onglets et pile de navigation
- **Gestion d'état** - Contextes React pour l'état global
- **Stockage local** - Persistance des données utilisateur

## Installation et Développement

### Prérequis
- Node.js (v16 ou supérieur)
- React Native CLI
- Android Studio (pour Android)
- Xcode (pour iOS)

### Développement Local

1. Clonez le repository
```bash
git clone [repository-url]
cd manounou-app
```

2. Installez les dépendances
```bash
npm install
# ou
yarn install
```

3. Configurez l'environnement
```bash
# Copiez le fichier d'environnement
cp .env.example .env
# Configurez vos variables d'environnement
```

4. Lancez l'application
```bash
# Pour iOS
npm run ios
# ou
yarn ios

# Pour Android
npm run android
# ou
yarn android
```

### Build pour App Store

#### Prérequis
- Compte développeur Apple (iOS)
- Compte développeur Google Play (Android)
- Expo CLI installé globalement
- EAS CLI installé globalement

```bash
# Installation des outils Expo
npm install -g @expo/cli eas-cli

# Connexion à votre compte Expo
eas login
```

#### Build iOS pour App Store
```bash
# Build de production pour iOS
eas build --platform ios --profile production

# Soumission à l'App Store
eas submit --platform ios
```

#### Build Android pour Google Play
```bash
# Build de production pour Android
eas build --platform android --profile production

# Soumission au Google Play Store
eas submit --platform android
```

#### Build pour les deux plateformes
```bash
# Build simultané iOS et Android
eas build --platform all --profile production
```

### Scripts Disponibles
```bash
npm start          # Démarrer Metro bundler
npm run android    # Lancer sur Android
npm run ios        # Lancer sur iOS
npm run lint       # Vérifier le code
npm run test       # Lancer les tests
```

## Contribution

1. Fork le projet
2. Créer une branche feature (`git checkout -b feature/nouvelle-fonctionnalite`)
3. Commit les changements (`git commit -am 'Ajouter nouvelle fonctionnalité'`)
4. Push vers la branche (`git push origin feature/nouvelle-fonctionnalite`)
5. Créer une Pull Request

## Licence

Ce projet est sous licence MIT. Voir le fichier `LICENSE` pour plus de détails.

## App Store et Distribution

### Informations App Store

- **Nom de l'app** : Manounou
- **Bundle ID iOS** : com.manounou.app
- **Package Android** : com.manounou.app
- **Catégorie** : Lifestyle / Parenting
- **Classification** : 4+ (Tout public)

### Fonctionnalités App Store

- ✅ **Prêt pour l'App Store** : Configuration complète pour iOS et Android
- 🔒 **Sécurité** : Chiffrement de bout en bout, authentification biométrique
- 🌍 **Localisation** : Support français avec internationalisation
- 📱 **Responsive** : Optimisé pour tous les appareils iOS et Android
- 🔄 **Mises à jour OTA** : Système de mise à jour over-the-air avec Expo
- 💳 **Achats intégrés** : Système d'abonnement avec Stripe
- 📊 **Analytics** : Suivi d'utilisation respectueux de la vie privée
- 🔔 **Notifications** : Push notifications intelligentes

### Conformité et Légal

- **RGPD** : Conforme au Règlement Général sur la Protection des Données
- **Politique de confidentialité** : Voir `PRIVACY_POLICY.md`
- **Conditions d'utilisation** : Voir `TERMS_OF_USE.md`
- **Stockage des données** : Serveurs français sécurisés

### Assets App Store

- **Icônes** : Générées en SVG pour toutes les tailles requises
- **Screenshots** : Templates prêts pour iOS et Android
- **Descriptions** : Textes optimisés pour l'App Store et Google Play
- **Métadonnées** : Mots-clés et catégories optimisés

### Processus de Soumission

1. **Préparation**
   - Vérification des assets (icônes, screenshots)
   - Test sur appareils physiques
   - Validation des politiques de confidentialité

2. **Build de Production**
   ```bash
   eas build --platform all --profile production
   ```

3. **Tests de Validation**
   - Test des fonctionnalités critiques
   - Vérification des achats intégrés
   - Test de l'authentification

4. **Soumission**
   ```bash
   eas submit --platform ios
   eas submit --platform android
   ```

5. **Suivi**
   - Monitoring des reviews
   - Réponse aux commentaires utilisateurs
   - Mises à jour régulières

## Support

Pour toute question ou problème :
- Email : support@manounou.app
- Documentation : [Lien vers la documentation]
- Issues GitHub : [Lien vers les issues]
- App Store : Évaluations et commentaires

---

**Manounou** - Simplifiez la gestion de garde de vos enfants ! 👶✨

*Application mobile disponible sur l'App Store et Google Play Store*
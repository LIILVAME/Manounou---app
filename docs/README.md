# 🍼 Manounou - Application Familiale

**Version :** 1.0.0  
**Plateforme :** iOS (SwiftUI)  
**Backend :** Supabase  
**Architecture :** MVVM + Combine

---

## 📱 Description

**Manounou** est une application familiale moderne conçue pour simplifier la gestion quotidienne des enfants. Elle permet aux parents de centraliser toutes les informations importantes : profils des enfants, événements familiaux, documents importants et bien plus.

### ✨ **Fonctionnalités Principales**

- 🏠 **Dashboard Familial** : Vue d'ensemble personnalisée avec compteurs dynamiques
- 👶 **Gestion des Enfants** : Profils complets avec informations essentielles
- 📅 **Calendrier Familial** : Planification et suivi des événements
- 📄 **Documents** : Stockage sécurisé des documents importants
- 👤 **Profil Utilisateur** : Gestion des informations personnelles

---

## 🚀 Installation et Configuration

### **Prérequis**
- Xcode 15.0+
- iOS 16.0+
- Compte Supabase
- Swift 5.9+

### **1. Cloner le Repository**
```bash
git clone https://github.com/[USERNAME]/manounou-app.git
cd manounou-app/ManounouSwiftUI
```

### **2. Configuration Supabase**

#### **A. Créer les Tables**
1. Aller sur [Supabase Dashboard](https://app.supabase.com/project/emgrtgencepzainsknsb/sql)
2. Exécuter le script `create_documents_table.sql`
3. Vérifier que toutes les tables sont créées :
   - ✅ `profiles`
   - ✅ `children` 
   - ✅ `events`
   - ✅ `documents`

#### **B. Configuration des Clés**
Les clés Supabase sont déjà configurées dans `Config.swift` :
```swift
static let url = "https://emgrtgencepzainsknsb.supabase.co"
static let anonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

### **3. Lancer l'Application**
```bash
# Ouvrir le projet Xcode
open Manounou.xcodeproj

# Ou via ligne de commande
xcodebuild -project Manounou.xcodeproj -scheme Manounou -destination 'platform=iOS Simulator,name=iPhone 15' build
```

---

## 🏗️ Architecture

### **Structure du Projet**
```
ManounouSwiftUI/
├── Manounou/
│   ├── ManounouApp.swift          # Point d'entrée
│   ├── Config.swift               # Configuration Supabase
│   ├── AuthManager.swift          # Gestion authentification
│   ├── AuthenticationView.swift   # Interface connexion
│   └── MainTabView.swift          # Interface principale
├── create_documents_table.sql     # Script création table
├── supabase_setup.sql            # Configuration complète DB
└── AUDIT_REPORT_360.md           # Rapport d'audit complet
```

### **Modèles de Données**

#### **Child (Enfant)**
```swift
struct Child: Identifiable, Codable {
    let id: UUID
    let parentId: UUID
    let firstName: String
    let lastName: String
    let dateOfBirth: Date
    let gender: String?
    let createdAt: Date
    let updatedAt: Date
}
```

#### **Event (Événement)**
```swift
struct Event: Identifiable, Codable {
    let id: UUID
    let parentId: UUID
    let title: String
    let description: String?
    let eventType: EventType
    let startDate: Date
    let endDate: Date?
    let childId: UUID?
}
```

#### **Document**
```swift
struct Document: Identifiable, Codable {
    let id: UUID
    let parentId: UUID
    let title: String
    let description: String?
    let documentType: DocumentType
    let fileName: String?
    let fileUrl: String?
    let childId: UUID?
}
```

---

## 📊 État du Projet

### ✅ **Fonctionnalités Implémentées**
- [x] Interface SwiftUI complète (5 écrans)
- [x] Authentification Supabase
- [x] Gestion des enfants (CRUD)
- [x] Gestion des événements (CRUD)
- [x] Interface documents (prête)
- [x] Profil utilisateur
- [x] Navigation TabView
- [x] Gestion d'erreur gracieuse

### ⚠️ **En Cours**
- [ ] Table documents (script prêt)
- [ ] Correction erreurs HTTP 400
- [ ] Tests automatisés

### 📋 **À Faire**
- [ ] Optimisations performance
- [ ] Cache local
- [ ] Push notifications
- [ ] Mode hors ligne

---

## 🧪 Tests

### **Tests Manuels**
1. **Lancer l'application** dans le simulateur
2. **Tester la navigation** entre les 5 onglets
3. **Vérifier les données** : 3 enfants existants visibles
4. **Tester l'interface** : responsive et moderne
5. **Vérifier les erreurs** : messages explicites

---

## 🔒 Sécurité

### **Mesures Implémentées**
- ✅ **Row Level Security** (RLS) Supabase
- ✅ **Authentification JWT**
- ✅ **Politiques d'accès** par utilisateur
- ✅ **Validation côté client**

---

## 📚 Documentation

### **Fichiers de Documentation**
- 📊 `AUDIT_REPORT_360.md` : Audit complet 360°
- 🗄️ `create_documents_table.sql` : Script création table
- 📋 `supabase_setup.sql` : Configuration complète DB

---

## 📞 Support

- **Email** : support@manounou.app
- **Issues** : GitHub Issues
- **Documentation** : Ce README + fichiers de doc

---

## 🎯 Roadmap

### **Version 1.1** (Prochaine)
- [ ] Finaliser la gestion des documents
- [ ] Corriger les erreurs de connexion
- [ ] Ajouter tests automatisés

### **Version 1.2** (Future)
- [ ] Mode hors ligne
- [ ] Push notifications
- [ ] Partage familial
- [ ] Export de données

---

**🍼 Manounou - Simplifier la vie familiale, une fonctionnalité à la fois.**

*Dernière mise à jour : 14 Août 2025*

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
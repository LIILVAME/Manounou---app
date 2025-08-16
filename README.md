# 🍼 Manounou - Application SwiftUI

**Version :** 1.0.0  
**Plateforme :** iOS 16.0+  
**Framework :** SwiftUI  
**Backend :** Supabase

---

## 📱 Description

Ce dossier contient l'application iOS native **Manounou** développée en SwiftUI. L'application permet aux parents de gérer efficacement leurs enfants, événements familiaux et documents importants.

## 🏗️ Structure du Projet

```
ManounouSwiftUI/
├── Manounou/                    # Code source principal
│   ├── ManounouApp.swift       # Point d'entrée de l'app
│   ├── MainTabView.swift       # Interface principale avec onglets
│   ├── AuthManager.swift       # Gestion de l'authentification
│   ├── AuthenticationView.swift # Interface de connexion
│   ├── Config.swift           # Configuration de l'app
│   ├── Package.swift          # Dépendances Swift Package Manager
│   └── Info.plist            # Configuration iOS
├── Manounou.xcodeproj/         # Projet Xcode
├── supabase/                   # Configuration base de données
│   └── migrations/            # Migrations SQL
├── create_documents_table.sql  # Script de création table documents
└── supabase_setup.sql         # Configuration initiale Supabase
```

## 🚀 Fonctionnalités Implémentées

### ✅ **Core Features**
- 🔐 **Authentification** : Connexion/inscription avec Supabase Auth
- 🏠 **Dashboard** : Vue d'ensemble avec compteurs dynamiques
- 👶 **Gestion Enfants** : Profils complets avec informations essentielles
- 📅 **Calendrier** : 4 vues (Mois, Semaine, Jour, Agenda) avec détection de conflits
- 📄 **Documents** : Stockage et gestion sécurisés
- 👤 **Profil** : Gestion des informations utilisateur

### 🎯 **Fonctionnalités Avancées**
- ⚠️ **Détection de conflits** : Alertes visuelles pour événements qui se chevauchent
- 🔄 **Navigation fluide** : Bouton "Aujourd'hui" et transitions animées
- 🎨 **Design moderne** : Interface SwiftUI native avec thème cohérent
- 📱 **Responsive** : Adaptation automatique aux différentes tailles d'écran

## 🛠️ Technologies Utilisées

- **SwiftUI** : Framework UI déclaratif d'Apple
- **Combine** : Framework de programmation réactive
- **Supabase Swift** : SDK pour base de données et authentification
- **Swift Package Manager** : Gestionnaire de dépendances

## 📦 Dépendances

```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/supabase/supabase-swift.git", from: "2.31.2")
]
```

## 🔧 Configuration

### Prérequis
- Xcode 15.0+
- iOS 16.0+
- Compte Supabase configuré

### Variables d'environnement
Configurer dans `Config.swift` :
- `SUPABASE_URL` : URL de votre projet Supabase
- `SUPABASE_ANON_KEY` : Clé anonyme Supabase

## 🚀 Lancement

1. **Ouvrir le projet**
   ```bash
   open Manounou.xcodeproj
   ```

2. **Configurer les dépendances**
   - Xcode résoudra automatiquement les packages Swift

3. **Configurer Supabase**
   - Exécuter `supabase_setup.sql` dans votre projet Supabase
   - Mettre à jour `Config.swift` avec vos clés

4. **Compiler et lancer**
   - Sélectionner un simulateur iOS
   - Appuyer sur ⌘+R pour compiler et lancer

## 📊 Architecture

### Pattern MVVM
- **Models** : Structures de données (Event, Child, Document, etc.)
- **Views** : Interfaces SwiftUI (MainTabView, AuthenticationView, etc.)
- **ViewModels** : Logique métier et état de l'application
- **Managers** : Services (AuthManager, etc.)

### Navigation
- **TabView** : Navigation principale avec 5 onglets
- **NavigationStack** : Navigation hiérarchique dans chaque onglet
- **Sheets** : Modales pour création/édition

## 🎨 Design System

- **Couleurs** : Palette cohérente avec couleurs système iOS
- **Typography** : Utilisation des styles de texte natifs
- **Spacing** : Système d'espacement basé sur des multiples de 8pt
- **Icons** : SF Symbols pour cohérence avec l'écosystème Apple

## 🧪 Tests

```bash
# Compiler pour vérifier les erreurs
xcodebuild -project Manounou.xcodeproj -scheme Manounou build

# Lancer sur simulateur
xcodebuild -project Manounou.xcodeproj -scheme Manounou -destination 'platform=iOS Simulator,name=iPhone 15' build
```

## 📝 Notes de Développement

- **Performance** : Utilisation de `LazyVStack` et `LazyVGrid` pour les listes
- **Accessibilité** : Support VoiceOver et Dynamic Type
- **Localisation** : Prêt pour l'internationalisation
- **Sécurité** : Authentification sécurisée avec Supabase

---

**Développé avec ❤️ en SwiftUI pour iOS**

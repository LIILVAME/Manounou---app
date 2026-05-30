# 🍼 Manounou - Application SwiftUI

**Version :** 1.0.0  
**Plateforme :** iOS 16.0+  
**Framework :** SwiftUI  
**Backend :** Supabase

---

## 📱 Description

Ce dossier contient l'application iOS native **Manounou** développée en SwiftUI. L'application permet aux parents de gérer efficacement leurs enfants, événements familiaux et documents importants.

## 🚀 Démarrage Rapide

### Prérequis
- Xcode 15.0+
- iOS 16.0+
- Git
- Compte développeur Apple (pour tests sur appareil)

### Installation
```bash
# Cloner le dépôt
git clone https://github.com/LIILVAME/Manounou---app.git
cd Manounou---app

# Initialiser le workflow Git
./git_workflow.sh init

# Lancer le build complet
./full_pipeline.sh
```

## 🏗️ Pipeline de Build Automatisé

Le projet utilise un pipeline de build complet qui s'exécute automatiquement à chaque modification :

### Scripts Disponibles

| Script | Description | Usage |
|--------|-------------|-------|
| `build_simulator_only.sh` | Build pour simulateur uniquement | `./build_simulator_only.sh` |
| `run_tests.sh` | Exécution des tests unitaires | `./run_tests.sh` |
| `generate_artifacts.sh` | Génération des artefacts de build | `./generate_artifacts.sh` |
| `full_pipeline.sh` | Pipeline complet (build + tests + artefacts) | `./full_pipeline.sh` |

### Étapes du Pipeline

1. **🔍 Vérification des dépendances**
   - Validation de Xcode et Git
   - Vérification de la structure du projet

2. **🔨 Compilation**
   - Build pour simulateur iOS
   - Détection automatique du simulateur disponible
   - Configuration de signature automatique

3. **🧪 Tests unitaires**
   - Exécution des tests sur simulateur
   - Génération de rapports de test
   - Métriques de couverture

4. **📦 Génération d'artefacts**
   - Archive de distribution
   - Rapport de build détaillé
   - Checksums de sécurité

### Exemple d'utilisation
```bash
# Pipeline complet
./full_pipeline.sh

# Build uniquement
./build_simulator_only.sh

# Tests uniquement
./run_tests.sh
```

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

## 🔄 Workflow Git Standardisé

Le projet utilise un workflow Git standardisé avec des hooks automatiques pour garantir la qualité du code.

### Stratégie de Branchement

```
main (production)
├── develop (intégration)
│   ├── feature/nom-feature
│   ├── bugfix/nom-bug
│   └── refactor/nom-refactor
└── hotfix/nom-hotfix (depuis main)
```

### Commandes du Workflow

| Commande | Description | Exemple |
|----------|-------------|---------|
| `./git_workflow.sh init` | Initialise le workflow (crée develop) | - |
| `./git_workflow.sh feature <nom>` | Crée une branche feature | `./git_workflow.sh feature auth-improvements` |
| `./git_workflow.sh bugfix <nom>` | Crée une branche bugfix | `./git_workflow.sh bugfix login-error` |
| `./git_workflow.sh hotfix <nom>` | Crée une branche hotfix | `./git_workflow.sh hotfix security-patch` |
| `./git_workflow.sh commit` | Commit interactif avec validation | - |
| `./git_workflow.sh finish` | Termine et merge la branche courante | - |
| `./git_workflow.sh status` | Statut détaillé du dépôt | - |
| `./git_workflow.sh sync` | Synchronise avec le dépôt distant | - |
| `./git_workflow.sh cleanup` | Nettoie les branches mergées | - |

### Hooks Git Automatiques

#### Pre-commit Hook
- ✅ Vérification de la syntaxe Swift
- ✅ Validation des standards de code
- ✅ Détection des TODO/FIXME

## 🚀 Déploiement GitHub Actions

Le projet est configuré avec un pipeline de déploiement automatique complet utilisant GitHub Actions.

### 🔄 Workflows Automatiques

| Workflow | Déclencheur | Description |
|----------|-------------|-------------|
| **CI** (`ci.yml`) | Push sur `main`/`develop`, PR | Tests, validation, sécurité |
| **Deploy** (`deploy.yml`) | Release GitHub, manuel | Déploiement TestFlight/App Store |
| **PR Validation** (`pr-validation.yml`) | Pull Requests | Validation automatique des PR |

### 📱 Processus de Déploiement

#### TestFlight (Staging)
```bash
# Créer une release beta
git tag v1.0.0-beta.1
git push origin v1.0.0-beta.1
```

#### App Store (Production)
```bash
# Créer une release de production
git tag v1.0.0
git push origin v1.0.0
```

### 🔐 Configuration des Secrets

Pour configurer le déploiement automatique, suivez le guide détaillé :
📖 **[Guide de Configuration des Secrets](.github/SECRETS_SETUP.md)**

Secrets requis :
- `APPLE_ID` - Identifiant Apple Developer
- `APPLE_APP_SPECIFIC_PASSWORD` - Mot de passe spécifique
- `APPLE_TEAM_ID` - ID de l'équipe Apple Developer
- `BUILD_CERTIFICATE_BASE64` - Certificat de distribution
- `P12_PASSWORD` - Mot de passe du certificat
- `BUILD_PROVISION_PROFILE_BASE64` - Profil de provisioning
- `KEYCHAIN_PASSWORD` - Mot de passe du keychain temporaire

### 📚 Documentation Complète

- 🚀 **[Guide de Déploiement](.github/DEPLOYMENT.md)** - Processus complet
- 🔐 **[Configuration des Secrets](.github/SECRETS_SETUP.md)** - Setup détaillé
- 🔧 **[Dépannage](.github/DEPLOYMENT.md#-dépannage)** - Solutions aux problèmes courants
- ✅ Vérification de sécurité (pas de secrets)
- ✅ Test de compilation rapide

#### Commit-msg Hook
- ✅ Validation du format des messages
- ✅ Respect des conventions (feat:, fix:, docs:, etc.)
- ✅ Longueur appropriée (≤ 72 caractères)
- ✅ Format multi-ligne correct

### Format des Messages de Commit

```
<type>(<scope>): <description>

<body>

<footer>
```

**Types disponibles :**
- `feat`: Nouvelle fonctionnalité
- `fix`: Correction de bug
- `docs`: Documentation
- `style`: Formatage, style
- `refactor`: Refactoring
- `test`: Tests
- `chore`: Maintenance
- `build`: Système de build
- `ci`: Intégration continue
- `perf`: Performance

**Exemples :**
```bash
feat(auth): add biometric authentication
fix(ui): resolve button alignment on iPad
docs: update README with Git workflow
refactor(core): simplify data manager architecture
```

### Workflow Recommandé

1. **Démarrer une nouvelle feature**
   ```bash
   ./git_workflow.sh feature ma-nouvelle-feature
   ```

2. **Développer et commiter régulièrement**
   ```bash
   # Développement...
   ./git_workflow.sh commit
   ```

3. **Synchroniser avec develop**
   ```bash
   ./git_workflow.sh sync
   ```

4. **Terminer la feature**
   ```bash
   ./git_workflow.sh finish
   ```

5. **Nettoyer les branches**
   ```bash
   ./git_workflow.sh cleanup
   ```

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

## 👥 Adoption par l'Équipe

### Onboarding des Nouveaux Développeurs

1. **Configuration initiale**
   ```bash
   # Cloner le projet
   git clone <repository-url>
   cd Manounou-app
   
   # Initialiser le workflow Git
   ./git_workflow.sh init
   
   # Tester le pipeline de build
   ./full_pipeline.sh
   ```

2. **Vérification de l'environnement**
   - Xcode 15.0+ installé
   - Simulateurs iOS configurés
   - Hooks Git activés automatiquement

### Règles d'Équipe Obligatoires

#### ✅ **À FAIRE**
- Utiliser `./git_workflow.sh` pour toutes les opérations Git
- Respecter le format des messages de commit
- Lancer `./full_pipeline.sh` avant chaque push
- Créer des branches pour chaque feature/bugfix
- Faire des commits atomiques et descriptifs
- Synchroniser régulièrement avec `develop`

#### ❌ **À ÉVITER**
- Commits directs sur `main` ou `develop`
- Messages de commit non conformes
- Push sans tests préalables
- Branches de longue durée non synchronisées
- Code non testé ou non compilé

### Processus de Code Review

1. **Avant la Pull Request**
   ```bash
   # Vérifier que tout fonctionne
   ./full_pipeline.sh
   
   # Synchroniser avec develop
   ./git_workflow.sh sync
   
   # Terminer la branche
   ./git_workflow.sh finish
   ```

2. **Critères d'Acceptation**
   - ✅ Pipeline de build réussi
   - ✅ Tests unitaires passants
   - ✅ Code review approuvé
   - ✅ Pas de conflits de merge
   - ✅ Documentation mise à jour si nécessaire

### Résolution de Problèmes

#### Build qui échoue
```bash
# Nettoyer et rebuilder
./build_simulator_only.sh

# Vérifier les dépendances
xcodebuild -list
```

#### Hooks Git non fonctionnels
```bash
# Réinstaller les hooks
chmod +x .git/hooks/*
```

#### Conflits de merge
```bash
# Utiliser le workflow standardisé
./git_workflow.sh sync
# Résoudre manuellement les conflits
# Puis terminer avec
./git_workflow.sh finish
```

### Métriques de Qualité

Le projet maintient les standards suivants :
- **Couverture de tests** : > 80%
- **Temps de build** : < 2 minutes
- **Zéro warning** de compilation
- **Respect des conventions** Swift

### Support et Formation

- **Documentation** : Ce README (toujours à jour)
- **Scripts d'aide** : Tous les scripts sont documentés avec `--help`
- **Exemples** : Voir les branches `example/*` pour des cas d'usage

## 📝 Notes de Développement

- **Performance** : Utilisation de `LazyVStack` et `LazyVGrid` pour les listes
- **Accessibilité** : Support VoiceOver et Dynamic Type
- **Localisation** : Prêt pour l'internationalisation
- **Sécurité** : Authentification sécurisée avec Supabase

---

**Développé avec ❤️ en SwiftUI pour iOS**

> 📋 **Note importante** : Ce README est un document vivant. Toute modification des processus doit être reflétée ici pour maintenir l'alignement de l'équipe.

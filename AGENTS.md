# AGENTS.md — Mémoire projet Manounou

Fichier de contexte persistant pour les agents IA travaillant sur **Manounou**
(app iOS SwiftUI + backend Supabase). Il complète, sans les remplacer :

- **`CLAUDE.md`** — règles d'exécution (checklist pré-commit/pré-push, sécurité, format de rapport).
- **`CONTRIBUTING.md`** — workflow git (branches, Conventional Commits, cibles de PR).

En cas de conflit, `CLAUDE.md` fait foi pour les contrôles qualité.

---

## 1. Vue d'ensemble

- **Client** : iOS SwiftUI (cible iOS 16+), un seul module applicatif `Manounou`.
- **Backend** : Supabase (Postgres + Auth + Storage), accédé via `supabase-swift` (SPM, `>= 2.0.0`).
- **Domaine** : suivi du quotidien d'un·e assistant·e maternel·le (enfants, événements/planning, documents, foyer, déclaration Pajemploi).

## 2. Architecture

```
Manounou/
├── Core/        AppContainer (DI singleton + 6 ViewModels), Theme, ErrorHandling
├── Models/      Child, Document, Event, User, PajemploiDeclaration, FilterTypes…
├── Services/    *Service + *ServiceProtocol + Mock* (Children, Events, Documents,
│                Auth, Cache, Profiles, Household, Planning, Plans, Pagination)
├── Utils/       DateFormatters, Logger, ImageCompressionManager, SecureConfig, Pagination
├── Components/  vues réutilisables
└── Views/       écrans SwiftUI par feature (Home, Calendar, Children, Documents…)
```

Conventions clés :

- **Injection de dépendances** via `AppContainer` (`createForTesting()` / `createForProduction()`).
- Les ViewModels sont `@MainActor`, `ObservableObject`, et exposent `isLoading` / `errorMessage`.
- Chaque service applicatif possède un **protocole** (`*ServiceProtocol`) et un **mock embarqué**
  (`Mock*Service`, pré-rempli, conforme au protocole) — destinés aux tests unitaires.
- Les DTO Swift (`*DTO` dans `Services/`) doivent toujours correspondre au schéma SQL
  (`supabase/migrations/*.sql`). Toute migration appliquée a son fichier versionné.
- Logging via `Utils/Logger.swift` (pas de `print(`). La clé Supabase `anon` est publique
  (RLS) et peut rester dans `Config.swift` ; `service_role` ne doit JAMAIS être committée.

## 3. Build & tests

| Action | Commande | Remarque |
|---|---|---|
| Résolution SPM | `xcodebuild -resolvePackageDependencies -project Manounou.xcodeproj` | |
| Build simulateur | `./build_simulator_only.sh` | garde-fou réel |
| Tests | `./run_tests.sh` | scheme `Manounou`, simulateur iPhone |

> ⚠️ **Environnements Linux / web (sans Xcode)** : `xcodebuild` n'est pas disponible.
> Le build et les tests ne peuvent **pas** être exécutés localement ; la CI
> (`.github/workflows/ci.yml`) est alors la source de vérité. Dans ce cas, garder
> les changements mécaniquement sûrs (relus, pas de spéculation non compilable) et
> signaler explicitement que la vérification build/tests revient à la CI.

## 4. État de la couverture de tests (au 2026-06)

**Constat initial** : sur 10 fichiers dans `ManounouTests/`, **seul `SmokeTests.swift`**
était câblé dans la cible Xcode (4 assertions sur `Document`). Les 9 autres étaient
orphelins : ils visaient l'ancien module `ManounouApp` et une API de ViewModel
(search/filter/sort, `documentsByType`…) qui n'existe plus.

**Travail engagé (étape 1 du plan de couverture)** :

- Refactor : `ChildrenViewModel` et `EventsViewModel` acceptent désormais leur
  **protocole** (`ChildrenServiceProtocol` / `EventsServiceProtocol`) au lieu du type
  concret → injection des mocks embarqués possible.
- Tests ajoutés à la cible `ManounouTests` :
  - `ChildModelTests` — âge, catégorie, validation (logique pure).
  - `PajemploiDeclarationTests` — crédit d'impôt 50 %, reste à charge, formatage.
  - `EventModelTests` — durée et statuts temporels.
  - `ChildrenViewModelTests` (modernisé) / `EventsViewModelTests` — chargement,
    création, erreurs, `todayEvents`, nettoyage, via `Mock*Service`.

**Dette / suite du plan** :

1. `DocumentsViewModel` : non encore injectable par protocole (il appelle
   `signedURL(path:)`, absent de `DocumentsServiceProtocol`). À ajouter au protocole
   + mock avant de réactiver `DocumentsViewModelTests`.
2. Fichiers de test toujours orphelins (hors cible, à moderniser ou supprimer) :
   `DocumentsViewModelTests`, `NavigationTests`, `PerformanceTests`,
   `ModernMainTabViewTests`, `SettingsOptimizationTests`, `CacheManagerTests`,
   `OptimizedViewsTests`, et l'ancien `MockServices.swift` (doublons de mocks).
3. Tests de round-trip Codable des DTO ⇄ schéma SQL (contrat `CLAUDE.md §2`).
4. `CacheService`, utilitaires (`DateFormatters`, `PaginationManager`).
5. CI backend : brancher `get_advisors` (sécurité) sur les migrations.

## 5. Décisions

- **Nommage des tests** : un fichier par type testé (`<Type>Tests.swift`). Les tests de
  ViewModel utilisent les mocks **embarqués dans l'app** (pas de mocks dupliqués côté tests).
- **Mocks** : source unique = `Mock*Service` dans `Manounou/Services/*`. Ne pas recréer
  de mocks dans la cible de test (risque de redéfinition de symboles).
- Ne jamais désactiver/skipper un test pour faire passer le CI (`CLAUDE.md §4`).

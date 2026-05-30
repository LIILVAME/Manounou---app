# CLAUDE.md — Règles d'exécution pour Claude

Ce fichier définit les contrôles que Claude **doit** exécuter avant tout commit et tout push sur le projet **Manounou** (app iOS SwiftUI + backend Supabase). Il complète `CONTRIBUTING.md` (workflow git) en se focalisant sur la qualité de code.

---

## 1. Checklist pré-commit obligatoire

Avant chaque `git commit`, Claude exécute **dans cet ordre**. Aucun commit si une étape échoue.

| # | Étape | Commande |
|---|---|---|
| 1 | Résolution des dépendances SPM | `xcodebuild -resolvePackageDependencies -project Manounou.xcodeproj` |
| 2 | Build simulateur | `./build_simulator_only.sh` |
| 3 | Tests | `./run_tests.sh` |
| 4 | Lint (si SwiftLint installé) | `swiftlint --strict` |
| 5 | Format (si swift-format configuré) | `swift-format lint --recursive Manounou` |

Le build (2) et les tests (3) sont les garde-fous réels : ils doivent passer. Le lint/format (4–5) ne sont pas encore branchés dans le repo — voir §7.

Les migrations SQL (`supabase/migrations/*.sql`) ne sont pas lint'ées localement ; elles sont validées via `mcp get_advisors` (type `security`) après application sur le projet Supabase. Toute migration appliquée doit avoir **0 finding `security` de niveau ERROR**, et les WARN doivent être justifiés.

---

## 2. Scope d'exécution

- **Modifié `Manounou/` ou `ManounouTests/`** → checks Swift (cf. §1, étapes 1–3 au minimum).
- **Modifié `supabase/migrations/`** → vérifier via les advisors Supabase après `apply_migration`. Aucune migration ne doit être appliquée sans son fichier équivalent versionné dans `supabase/migrations/`. Le schéma de la base doit toujours correspondre aux DTO Swift (`*DTO` dans `Manounou/Services/`).
- **Modifié `.github/`, `*.md`, `.gitignore`, scripts `*.sh`, fichiers de config racine** → aucun check de code, mais `git diff --check` pour repérer espaces parasites et marqueurs de conflit.

---

## 3. Checks de sécurité (toujours, quel que soit le scope)

Avant `git add`, Claude vérifie :

- ❌ Aucun fichier `.env`, `.env.local`, `*.xcconfig` de secrets, `*.p12`, `*.mobileprovision`, `*.pem`, `*.key`, `credentials*`, `secrets*`, `GoogleService-Info.plist` n'est staged.
- ❌ Aucun **vrai secret** en clair dans le code : clé Supabase `service_role`, `sk_live`/`sk_test` Stripe, mot de passe, token d'API privé, `JWT_SECRET`, clé de chiffrement.
  - `git diff --staged | grep -iE 'service_role|sb_secret|sk_live|sk_test|secret|password|bearer|private[_-]?key'`
  - ⚠️ La clé Supabase **`anon`** (`eyJhbGci…`, rôle `anon`) est PUBLIQUE par conception : embarquée dans le client, protégée par RLS. Elle peut rester dans `Config.swift`. C'est `service_role` qui ne doit JAMAIS être committée.
- ❌ Aucun fichier > 1 Mo n'est staged (sauf assets explicitement attendus dans `Assets.xcassets/` ou `Resources/`).
- ❌ Aucun `print(` laissé dans du code applicatif (utiliser le `Logger` structuré de `Manounou/Utils/Logger.swift`).
- ❌ Aucun force-unwrap (`!`) ajouté sans justification (préférer `guard let` / `if let`).
- ❌ Aucun bloc de code commenté (« code mort »).
- ❌ Aucun `TODO` / `FIXME` sans contexte (ticket, date ou explication).

---

## 4. Comportement en cas d'échec

| Échec | Action |
|---|---|
| Lint / format | Tenter le fix automatique (`swiftlint --fix`, `swift-format format -i`) puis re-vérifier. Si toujours rouge, **ne pas commiter** : reporter l'erreur. |
| Build | Ne pas commiter un build cassé. Diagnostiquer et corriger (le projet doit compiler pour le simulateur). |
| Tests | Ne **jamais** désactiver/skipper un test pour passer le CI. Identifier la cause, corriger le code ou ajuster le test si la spec a changé. |
| Migration (advisor ERROR) | Ne pas considérer la migration comme appliquée. Corriger le SQL (RLS, search_path, policies) et ré-appliquer. |
| Hook git refusé | **Jamais `--no-verify`**. Lire le message du hook, corriger, recommiter. |

---

## 5. Checklist pré-push

Avant chaque `git push` :

1. La branche **n'est pas** `main` (cf. `CONTRIBUTING.md` §1 — modèle trunk-based).
2. Le nom de branche respecte `prefix/kebab-case` (cf. §2 du CONTRIBUTING).
3. Tous les commits de la branche respectent le format Conventional Commits (validé aussi par `pr-validation.yml`).
4. La PR cible **`main`** (tronc unique).
5. Re-rouler build + tests si plusieurs commits ont été ajoutés depuis le dernier check.

---

## 6. Rapport de fin

Après push réussi, Claude rapporte **dans ce format exact** :

```
✅ Branche [prefix/nom] poussée
   Checks : build ✓ · tests ✓ · secrets ✓
   PR à créer : [prefix/nom] → main
```

Si un check a été skip pour cause de scope (ex : changement doc-only), le préciser :

```
✅ Branche docs/readme-cleanup poussée
   Checks : doc-only (git diff --check ✓)
   PR à créer : docs/readme-cleanup → main
```

---

## 7. Setup recommandé du projet (à mettre en place une fois)

Pour rendre ces règles applicables côté CI/CD sans dépendre de Claude :

- **SwiftLint + swift-format** : ajouter un `.swiftlint.yml` à la racine et une phase de build (ou un hook pre-commit) qui les exécute sur les fichiers Swift staged.
- **Séparation multi-environnement (optionnel)** : si besoin de cibler dev/staging/prod avec des projets Supabase distincts, externaliser URL + clé `anon` dans des `.xcconfig` par configuration, lus via `SecureConfig`. Non requis pour la sécurité (la clé `anon` est publique) — seule la séparation d'environnement le justifie.
- **GitHub Actions** : les workflows `ci.yml` et `pr-validation.yml` exécutent build + tests + scan de secrets sur chaque PR vers `main`. Aucun merge possible si rouge.
- **Branch protection** sur `main` : require status checks + require PR review.
- **Secret scanning + push protection** activés côté GitHub.

Quand ces garde-fous sont en place, ils deviennent la source de vérité ; Claude continue de tourner les checks localement pour rapport immédiat, mais le CI tranche.

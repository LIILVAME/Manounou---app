# Contribuer à Manounou

Ce document définit le workflow git, les conventions de nommage et le processus de revue pour tout changement apporté au projet (app iOS SwiftUI + backend Supabase). Il s'applique à toute personne (humaine ou agent) qui touche au code.

## 1. Modèle de branches

Deux branches longue durée :

| Branche | Rôle | Protection |
|---|---|---|
| `main` | **Production**. Reflète l'état de référence (ce qui est soumis à TestFlight & App Store). | Aucun commit direct. Merge uniquement depuis `dev` via PR de release validée. |
| `dev` | **Intégration**. Code en cours de stabilisation, prêt pour la prochaine release. | Aucun commit direct. Merge uniquement depuis branches de chantier via PR. |

Toute autre branche est éphémère : créée pour un chantier, mergée dans `dev` puis supprimée.

## 2. Préfixes de branche

Une branche = un chantier atomique. Le préfixe doit refléter la **nature** du travail :

| Préfixe | Usage | Exemple |
|---|---|---|
| `feat/` | Nouvelle fonctionnalité visible utilisateur | `feat/child-medical-fields` |
| `fix/` | Correction de bug | `fix/ios-build-compile` |
| `chore/` | Tooling, configuration, refactor non fonctionnel | `chore/swiftlint-setup` |
| `docs/` | Documentation seule | `docs/contributing-update` |
| `hotfix/` | Correctif **urgent** en production (part de `main`, pas de `dev`) | `hotfix/auth-crash` |

Nommage : `prefix/kebab-case-court-et-descriptif`. Pas d'accents, pas d'espaces, pas de majuscules.

## 3. Workflow standard (toute contribution non-urgente)

```
1. git checkout dev
2. git pull origin dev               # toujours à jour avant de brancher
3. git checkout -b feat/ma-feature   # nouvelle branche depuis dev
4. # ... commits atomiques ...
5. git push -u origin feat/ma-feature
6. Ouvrir une PR  feat/ma-feature  →  dev
7. Revue + validation utilisateur (CI verte : build + tests + checks)
8. Squash and merge dans dev
9. Suppression de la branche distante
```

Quand `dev` accumule plusieurs chantiers validés et qu'on veut livrer :

```
10. Ouvrir une PR  dev  →  main  (PR de release)
11. Validation utilisateur explicite
12. Merge dans main → build de déploiement (TestFlight / App Store via deploy.yml)
```

## 4. Workflow hotfix (production en panne)

```
1. git checkout main
2. git pull origin main
3. git checkout -b hotfix/description
4. # fix + commit
5. git push -u origin hotfix/description
6. PR  hotfix/description  →  main   (validation rapide)
7. Après merge, back-merge dans dev :
   git checkout dev && git merge main && git push origin dev
```

## 5. Commits

Format **Conventional Commits** (également imposé par `pr-validation.yml`) :

```
<type>(<scope optionnel>): <résumé impératif en minuscules>

[corps optionnel : pourquoi, pas quoi]
```

Types autorisés : `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`, `perf`, `ci`, `build`.

Règles :
- **Un commit = une idée vérifiable**. Si tu utilises « et » dans ton message, c'est probablement deux commits.
- Résumé < 72 caractères, à l'impératif présent (« add », pas « added » ni « adds »).
- Le scope reflète le domaine touché : `feat(children):`, `fix(auth):`, `chore(ci):`.
- Pas de référence à des tickets internes ou des sessions dans le message — ces infos vont dans la description de PR.

Exemples valides :
```
feat(children): add allergies and emergency contact fields
fix(auth): resolve AuthViewModel bindings on sign-up
chore(ci): repair pipeline so PR checks run
docs: clarify hotfix workflow in CONTRIBUTING
```

## 6. Pull Requests

Chaque PR doit :
1. Cibler la bonne branche (`dev` par défaut, `main` uniquement pour release ou hotfix).
2. Avoir un titre clair au format Conventional Commits (mêmes règles que les commits).
3. Avoir une description structurée :

```
## Pourquoi
Contexte et motivation du changement.

## Quoi
Liste à puces des changements concrets.

## Comment tester
Étapes reproductibles (build simulateur, scénario à vérifier dans l'app).

## Notes
Risques, dépendances, impact base de données / migrations, points d'attention.
```

4. Être **petite et focalisée**. Si la PR dépasse ~400 lignes de diff hors doc, demande-toi si elle peut être découpée. `pr-validation.yml` alerte au-delà de 50 fichiers.
5. Ne **jamais** mélanger un refactor et une feature dans la même PR.
6. Toute PR touchant `supabase/migrations/` décrit l'impact schéma et confirme que les advisors `security` sont au vert.

## 7. Revue et merge

- Aucune PR ne se merge sans validation utilisateur explicite.
- L'auteur ne merge pas sa propre PR avant validation.
- Stratégie de merge par défaut : **squash and merge** pour les branches de chantier, **merge commit** pour `dev → main` (préserve l'historique des chantiers).
- Après merge, supprimer la branche distante.

## 8. Anti-patterns interdits

- ❌ Commits directs sur `main` ou `dev`
- ❌ Force push sur `main`, `dev`, ou une branche partagée
- ❌ `--no-verify` pour contourner les hooks
- ❌ Clés Supabase `service_role` / secrets en dur dans le code
- ❌ Migration appliquée à Supabase sans fichier versionné correspondant
- ❌ Commits « WIP », « fix typo », « oops » mergés tels quels — rebase/squash avant PR
- ❌ Branches longue durée autres que `main` et `dev`
- ❌ Mélanger plusieurs préoccupations dans une PR

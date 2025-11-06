# 🚀 Guide d'Implémentation CI/CD - Manounou

**Basé sur** : [Stratégie CI/CD](./CICD_STRATEGY.md)  
**Date** : 2025-01-28

---

## 📋 Vue d'ensemble

Ce guide décrit l'implémentation pratique de la stratégie CI/CD pour Manounou.

---

## ✅ État Actuel

### Workflows Configurés

| Workflow | Fichier | Status | Optimisations |
|:---------|:--------|:-------|:--------------|
| **CI - Tests & Analyse** | `ci.yml` | ✅ Optimisé | Cache, Security Scan, Quality Gate |
| **CD - iOS Production** | `cd-ios.yml` | ✅ Optimisé | Cache activé |
| **CD - Android Production** | `cd-android.yml` | ✅ Optimisé | Cache activé |
| **CD - Staging** | `cd-staging.yml` | ✅ Nouveau | Environnement staging |
| **CD - FlutterFlow** | `cd-flutterflow.yml` | ✅ Existant | Synchronisation |

---

## 🔧 Optimisations Appliquées

### 1. Cache Flutter

**Avant** :
```yaml
- name: 🐦 Setup Flutter
  uses: subosito/flutter-action@v2
  with:
    flutter-version: '3.35.7'
```

**Après** :
```yaml
- name: 🐦 Setup Flutter
  uses: subosito/flutter-action@v2
  with:
    flutter-version: '3.35.7'
    cache: true  # ✅ Cache activé
```

**Gain** : ~30-40% de réduction du temps de build

### 2. Variables d'Environnement

**Avant** : Version Flutter hardcodée  
**Après** : Variables centralisées

```yaml
env:
  FLUTTER_VERSION: '3.35.7'
  WORKING_DIRECTORY: ./flutterflow_export
```

**Gain** : Maintenance simplifiée, cohérence

### 3. Security Scan

**Nouveau** : Scan automatique des secrets

```yaml
- name: 🔐 Scan for secrets
  uses: trufflesecurity/trufflehog@main
```

**Gain** : Détection précoce des fuites de secrets

### 4. Quality Gate

**Nouveau** : Validation finale avant merge

```yaml
quality-gate:
  needs: [analyze, test, build-check, security-scan]
  if: always()
```

**Gain** : Blocage automatique si qualité insuffisante

### 5. Parallélisation

**Amélioré** : Jobs en parallèle avec `fail-fast: false`

```yaml
strategy:
  fail-fast: false
  matrix:
    platform: [ios, android, web]
```

**Gain** : Tous les builds testés même si un échoue

---

## 🚀 Prochaines Étapes

### 1. Configurer les Secrets Staging

```bash
# Ajouter les secrets Supabase Staging (optionnel)
gh secret set SUPABASE_URL_STAGING
gh secret set SUPABASE_ANON_KEY_STAGING
```

**Note** : Si non configurés, les secrets production seront utilisés.

### 2. Créer la Branche `develop`

```bash
# Créer la branche develop
git checkout -b develop
git push -u origin develop

# Configurer la protection de branche sur GitHub
gh api repos/:owner/:repo/branches/develop/protection \
  --method PUT \
  --field required_status_checks='{"strict":true,"contexts":["✅ Quality Gate"]}' \
  --field enforce_admins=true \
  --field required_pull_request_reviews='{"required_approving_review_count":1}'
```

### 3. Configurer les Environnements Supabase

1. **Créer un projet Supabase Staging**
   - Aller sur https://supabase.com
   - Créer un nouveau projet : `manounou-staging`
   - Copier l'URL et la clé anonyme

2. **Configurer les secrets**
   ```bash
   gh secret set SUPABASE_URL_STAGING
   gh secret set SUPABASE_ANON_KEY_STAGING
   ```

3. **Synchroniser le schéma**
   ```bash
   # Appliquer les migrations sur staging
   supabase db push --project-ref staging-project-ref
   ```

### 4. Tester les Workflows

#### Test CI
```bash
# Faire un push sur une feature branch
git checkout -b feature/test-ci
git commit --allow-empty -m "test: CI workflow"
git push origin feature/test-ci

# Vérifier les workflows
gh run list
```

#### Test CD Staging
```bash
# Merge vers develop
git checkout develop
git merge feature/test-ci
git push origin develop

# Vérifier le déploiement staging
gh run list --workflow="🚀 CD - Déploiement Staging"
```

#### Test CD Production
```bash
# Créer un tag
git checkout main
git tag v1.0.1
git push origin main --tags

# Vérifier le déploiement production
gh run list --workflow="🚀 CD - Déploiement iOS"
```

---

## 📊 Monitoring

### Métriques à Surveiller

1. **Durée des Pipelines**
   - CI : < 10 min (objectif)
   - CD Staging : < 20 min (objectif)
   - CD Production : < 25 min (objectif)

2. **Taux de Succès**
   - CI : > 95%
   - CD : > 90%

3. **Temps de Feedback**
   - Push → Résultat CI : < 10 min
   - Merge → Déploiement Staging : < 20 min

### Dashboard GitHub Actions

```bash
# Voir les métriques
gh run list --limit 20

# Voir les détails d'un run
gh run view <run-id>

# Voir les logs
gh run view <run-id> --log
```

---

## 🔐 Sécurité

### Secrets Gérés

| Secret | Environnement | Usage |
|:-------|:--------------|:------|
| `SUPABASE_URL` | Production | CD Production |
| `SUPABASE_ANON_KEY` | Production | CD Production |
| `SUPABASE_URL_STAGING` | Staging | CD Staging (optionnel) |
| `SUPABASE_ANON_KEY_STAGING` | Staging | CD Staging (optionnel) |

### Bonnes Pratiques

1. ✅ **Jamais de secrets dans le code**
2. ✅ **Rotation régulière des secrets**
3. ✅ **Accès limité aux secrets**
4. ✅ **Scan automatique des secrets**

---

## 🐛 Dépannage

### Workflow CI échoue

**Problème** : Quality Gate échoue  
**Solution** :
```bash
# Vérifier les résultats individuels
gh run view <run-id>

# Relancer les tests locaux
cd flutterflow_export
flutter analyze
flutter test
```

### Workflow CD échoue

**Problème** : Build échoue  
**Solution** :
```bash
# Vérifier les logs
gh run view <run-id> --log

# Vérifier les secrets
gh secret list

# Tester localement
cd flutterflow_export
flutter build ios --release --no-codesign
```

### Cache invalide

**Problème** : Cache corrompu  
**Solution** :
```bash
# Forcer le rebuild sans cache
# Dans le workflow, désactiver temporairement cache: true
```

---

## 📚 Ressources

- [Stratégie CI/CD](./CICD_STRATEGY.md)
- [Rapport de Statut](./CICD_STATUS_REPORT.md)
- [Quick Start](./CICD_QUICK_START.md)
- [Documentation GitHub Actions](https://docs.github.com/en/actions)

---

## ✅ Checklist d'Implémentation

- [x] Stratégie CI/CD documentée
- [x] Workflows optimisés (cache, parallélisation)
- [x] Security scan intégré
- [x] Quality gate configuré
- [x] Workflow staging créé
- [ ] Branche `develop` créée et protégée
- [ ] Secrets staging configurés (optionnel)
- [ ] Environnements Supabase configurés
- [ ] Tests des workflows effectués
- [ ] Monitoring configuré

---

**🎯 Prochaine étape** : Créer la branche `develop` et tester les workflows


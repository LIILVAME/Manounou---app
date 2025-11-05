# 🚀 CI/CD Setup - Manounou

## 📋 Vue d'ensemble

Le système CI/CD de Manounou automatise les tests, l'analyse du code et les déploiements pour garantir la qualité et la stabilité de l'application.

---

## 🔧 Workflows GitHub Actions

### 1. **CI - Tests & Analyse** (`.github/workflows/ci.yml`)

**Déclencheurs** :
- Push sur `main` ou `develop`
- Pull requests vers `main` ou `develop`

**Jobs** :
- ✅ **Analyse** : Vérification statique du code (`flutter analyze`)
- ✅ **Tests** : Exécution des tests unitaires avec couverture
- ✅ **Build Check** : Vérification que le code compile sur iOS, Android et Web

**Durée estimée** : ~5-10 minutes

---

### 2. **CD - Déploiement iOS** (`.github/workflows/cd-ios.yml`)

**Déclencheurs** :
- Push sur `main` avec tag `v*.*.*`
- Workflow manuel (workflow_dispatch)

**Actions** :
1. Build iOS (release, sans signature)
2. Création d'un IPA
3. Upload en artifact GitHub
4. Création d'une release GitHub (si tag)

**Secrets requis** :
- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`

---

### 3. **CD - Déploiement Android** (`.github/workflows/cd-android.yml`)

**Déclencheurs** :
- Push sur `main` avec tag `v*.*.*`
- Workflow manuel (workflow_dispatch)

**Actions** :
1. Build APK (release)
2. Build App Bundle (release)
3. Upload en artifacts GitHub
4. Création d'une release GitHub (si tag)

**Secrets requis** :
- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`

---

### 4. **CD - Synchronisation FlutterFlow** (`.github/workflows/cd-flutterflow.yml`)

**Déclencheurs** :
- Push sur `main` avec changements dans `flutterflow_export/`
- Workflow manuel

**Actions** :
- Détection des changements dans le code exporté
- Création d'une issue/commentaire pour rappeler la synchronisation manuelle

**Note** : FlutterFlow nécessite une synchronisation manuelle car l'export est unidirectionnel.

---

## 🛠️ Scripts Utilitaires

### Pré-commit (`ops/pre-commit.sh`)

Validation automatique avant chaque commit :
- Vérification des dépendances
- Analyse statique
- Formatage
- Tests unitaires

**Usage** :
```bash
chmod +x ops/pre-commit.sh
./ops/pre-commit.sh
```

**Intégration Git Hook** :
```bash
ln -s ../../ops/pre-commit.sh .git/hooks/pre-commit
```

---

### Version Bump (`ops/version-bump.sh`)

Mise à jour automatique de la version dans `pubspec.yaml`.

**Usage** :
```bash
chmod +x ops/version-bump.sh

# Patch version (1.0.0 -> 1.0.1)
./ops/version-bump.sh patch

# Minor version (1.0.0 -> 1.1.0)
./ops/version-bump.sh minor

# Major version (1.0.0 -> 2.0.0)
./ops/version-bump.sh major

# Build number (1.0.0+1 -> 1.0.0+2)
./ops/version-bump.sh build
```

---

## 🔐 Configuration des Secrets GitHub

### Secrets Requis

Dans GitHub → Settings → Secrets and variables → Actions :

| Secret | Description | Exemple |
|:-------|:------------|:--------|
| `SUPABASE_URL` | URL de l'instance Supabase | `https://xxxxx.supabase.co` |
| `SUPABASE_ANON_KEY` | Clé anonyme Supabase | `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...` |

### Comment Ajouter un Secret

1. Aller sur GitHub → Repository → Settings
2. Secrets and variables → Actions
3. New repository secret
4. Nom : `SUPABASE_URL`
5. Valeur : `https://xxxxx.supabase.co`
6. Add secret

---

## 📦 Processus de Release

### 1. Mise à jour de la version

```bash
# Patch release (ex: 1.0.0 -> 1.0.1)
./ops/version-bump.sh patch

git add flutterflow_export/pubspec.yaml
git commit -m "chore: bump version to 1.0.1+1"
```

### 2. Créer un tag

```bash
git tag v1.0.1
git push origin main --tags
```

### 3. Déclenchement automatique

Le workflow `cd-ios.yml` et `cd-android.yml` se déclenchent automatiquement et :
- ✅ Buildent les applications
- ✅ Créent les artifacts
- ✅ Créent une release GitHub avec les fichiers

### 4. Téléchargement

Les artifacts sont disponibles dans :
- GitHub → Actions → Workflow run → Artifacts

---

## 🧪 Tests Locaux

### Tester les workflows localement

**Act** (simulation GitHub Actions) :
```bash
# Installer act
brew install act

# Tester le workflow CI
act push

# Tester avec un événement spécifique
act workflow_dispatch -W .github/workflows/cd-ios.yml
```

### Tester les scripts

```bash
# Pré-commit
./ops/pre-commit.sh

# Version bump
./ops/version-bump.sh patch
```

---

## 📊 Monitoring & Notifications

### Badges de statut

Ajouter dans `README.md` :
```markdown
![CI](https://github.com/USER/Manounou/workflows/🧪%20CI%20-%20Tests%20&%20Analyse/badge.svg)
![CD iOS](https://github.com/USER/Manounou/workflows/🚀%20CD%20-%20Déploiement%20iOS/badge.svg)
![CD Android](https://github.com/USER/Manounou/workflows/🚀%20CD%20-%20Déploiement%20Android/badge.svg)
```

### Notifications

Configurer dans GitHub → Settings → Notifications :
- ✅ Email pour les échecs de workflow
- ✅ Slack/Discord via webhooks (optionnel)

---

## 🐛 Dépannage

### Workflow CI échoue

**Problème** : Tests échouent  
**Solution** :
```bash
cd flutterflow_export
flutter test --verbose
```

**Problème** : Analyse échoue  
**Solution** :
```bash
cd flutterflow_export
flutter analyze
flutter fix --apply
```

### Workflow CD échoue

**Problème** : Build iOS échoue  
**Solution** :
- Vérifier que les secrets sont configurés
- Vérifier les permissions GitHub Actions
- Vérifier les logs du workflow

**Problème** : Build Android échoue  
**Solution** :
- Vérifier que Java 17 est disponible
- Vérifier les permissions de build

---

## 📚 Ressources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Flutter CI/CD Best Practices](https://docs.flutter.dev/deployment/cd)
- [FlutterFlow Export](https://docs.flutterflow.io/export-and-deploy)

---

## ✅ Checklist de Setup

- [ ] Workflows GitHub Actions créés
- [ ] Secrets GitHub configurés (`SUPABASE_URL`, `SUPABASE_ANON_KEY`)
- [ ] Scripts utilitaires rendus exécutables (`chmod +x`)
- [ ] Git hook pré-commit configuré (optionnel)
- [ ] Badges ajoutés au README
- [ ] Tests locaux effectués
- [ ] Documentation à jour

---

**🎉 Une fois configuré, le CI/CD fonctionnera automatiquement à chaque push !**


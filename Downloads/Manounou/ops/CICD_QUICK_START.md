# 🚀 CI/CD Quick Start - Manounou

## ✅ Configuration Actuelle

**Status** : ✅ **Configuration complète et prête**

- ✅ Remote Git corrigé : `https://github.com/LIILVAME/Manounou---app.git`
- ✅ 4 workflows GitHub Actions configurés
- ✅ Secrets Supabase configurés
- ✅ Scripts utilitaires prêts

---

## 🎯 Commandes Rapides

### Vérifier la configuration
```bash
./ops/verify-cicd.sh
```

### Voir les workflows actifs
```bash
gh workflow list
```

### Voir les runs récents
```bash
gh run list
```

### Déclencher un build manuel

**iOS** :
```bash
gh workflow run "🚀 CD - Déploiement iOS" -f version=1.0.0
```

**Android** :
```bash
gh workflow run "🚀 CD - Déploiement Android" -f version=1.0.0
```

### Créer une release
```bash
# 1. Mettre à jour la version
./ops/version-bump.sh patch

# 2. Commit et push
git add flutterflow_export/pubspec.yaml
git commit -m "chore: bump version to 1.0.1"
git push origin main

# 3. Créer un tag
git tag v1.0.1
git push origin main --tags

# Les workflows se déclenchent automatiquement !
```

---

## 📋 Workflows Disponibles

| Workflow | Fichier | Déclencheurs |
|:---------|:--------|:-------------|
| 🧪 CI - Tests & Analyse | `ci.yml` | Push/PR sur `main` ou `develop` |
| 🚀 CD - iOS | `cd-ios.yml` | Tag `v*.*.*` ou manuel |
| 🚀 CD - Android | `cd-android.yml` | Tag `v*.*.*` ou manuel |
| 🔄 CD - FlutterFlow | `cd-flutterflow.yml` | Push avec changements `flutterflow_export/` |

---

## 🔐 Secrets Configurés

- ✅ `SUPABASE_URL`
- ✅ `SUPABASE_ANON_KEY`

---

## 📚 Documentation Complète

- [Rapport de statut CI/CD](./CICD_STATUS_REPORT.md)
- [Guide de setup CI/CD](./CI_CD_SETUP.md)
- [Rapport GitHub](./GITHUB_STATUS_REPORT.md)

---

**🎉 Tout est prêt ! Vous pouvez maintenant push et les workflows s'exécuteront automatiquement.**


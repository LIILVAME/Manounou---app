# 🚀 Ops - Manounou

## 📋 Contenu

Ce dossier contient les scripts et la documentation pour les opérations CI/CD de Manounou.

### Scripts

- **`pre-commit.sh`** : Validation automatique avant chaque commit
- **`version-bump.sh`** : Mise à jour automatique de la version

### Documentation

- **`CI_CD_SETUP.md`** : Guide complet de configuration CI/CD

---

## 🚀 Utilisation Rapide

### Validation Pré-commit

```bash
./ops/pre-commit.sh
```

### Mise à jour de Version

```bash
# Patch (1.0.0 -> 1.0.1)
./ops/version-bump.sh patch

# Minor (1.0.0 -> 1.1.0)
./ops/version-bump.sh minor

# Major (1.0.0 -> 2.0.0)
./ops/version-bump.sh major

# Build (1.0.0+1 -> 1.0.0+2)
./ops/version-bump.sh build
```

---

## 📚 Documentation Complète

Voir [`CI_CD_SETUP.md`](./CI_CD_SETUP.md) pour la configuration complète du CI/CD.


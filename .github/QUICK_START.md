# 🚀 Démarrage Rapide - Déploiement Manounou

Ce guide vous permet de configurer rapidement le déploiement automatique pour l'application Manounou.

## ⚡ Configuration Express (5 minutes)

### 1. 🔐 Configurer les Secrets GitHub

1. **Allez dans votre repository GitHub**
   ```
   Settings > Secrets and variables > Actions > New repository secret
   ```

2. **Ajoutez ces 7 secrets** (voir [SECRETS_SETUP.md](SECRETS_SETUP.md) pour les détails) :
   ```
   APPLE_ID                      # votre.email@developer.apple.com
   APPLE_APP_SPECIFIC_PASSWORD   # xxxx-xxxx-xxxx-xxxx
   APPLE_TEAM_ID                 # XXXXXXXXXX
   BUILD_CERTIFICATE_BASE64      # [Base64 du certificat .p12]
   P12_PASSWORD                  # [Mot de passe du certificat]
   BUILD_PROVISION_PROFILE_BASE64 # [Base64 du profil .mobileprovision]
   KEYCHAIN_PASSWORD             # [Mot de passe sécurisé]
   ```

### 2. ✅ Valider la Configuration

```bash
# Cloner et aller dans le projet
git clone https://github.com/LIILVAME/Manounou---app.git
cd Manounou---app

# Valider la configuration
./DeploymentScripts/deploy_helper.sh validate
```

### 3. 🚀 Premier Déploiement

```bash
# Créer une release beta pour TestFlight
./DeploymentScripts/deploy_helper.sh prepare -v 1.0.0-beta.1

# Ou créer une release de production
./DeploymentScripts/deploy_helper.sh prepare -v 1.0.0
```

## 🎯 Workflows Automatiques

Une fois configuré, ces actions se déclenchent automatiquement :

| Action | Déclencheur | Résultat |
|--------|-------------|----------|
| **Tests & Validation** | Push sur `main`/`develop` | ✅ Tests automatiques |
| **Déploiement TestFlight** | Tag `v1.0.0-beta.X` | 📱 App sur TestFlight |
| **Déploiement App Store** | Tag `v1.0.0` | 🏪 Soumission App Store |
| **Validation PR** | Pull Request | 🔍 Review automatique |

## 🛠️ Commandes Utiles

```bash
# Afficher le statut du projet
./DeploymentScripts/deploy_helper.sh status

# Préparer une nouvelle version
./DeploymentScripts/deploy_helper.sh prepare -v 1.2.0

# Valider la configuration
./DeploymentScripts/deploy_helper.sh validate

# Pipeline de build local
./full_pipeline.sh
```

## 🔄 Workflow de Développement

### Développement de Fonctionnalité
```bash
# Créer une branche feature
./git_workflow.sh feature nouvelle-fonctionnalite

# Développer...
# Commiter avec validation automatique
./git_workflow.sh commit

# Terminer et merger
./git_workflow.sh finish
```

### Release
```bash
# Depuis develop, créer une release
git checkout develop
git pull origin develop

# Préparer la release
./DeploymentScripts/deploy_helper.sh prepare -v 1.1.0-beta.1

# Le déploiement TestFlight se lance automatiquement
# Après validation, créer la release finale
./DeploymentScripts/deploy_helper.sh prepare -v 1.1.0
```

## 🆘 Dépannage Express

### ❌ Erreur "Invalid credentials"
```bash
# Vérifiez ces secrets :
APPLE_ID
APPLE_APP_SPECIFIC_PASSWORD
```

### ❌ Erreur "Certificate not found"
```bash
# Vérifiez ces secrets :
BUILD_CERTIFICATE_BASE64
P12_PASSWORD
```

### ❌ Erreur "Provisioning profile invalid"
```bash
# Vérifiez ce secret :
BUILD_PROVISION_PROFILE_BASE64
```

### 🔍 Debug
```bash
# Voir les logs GitHub Actions
# GitHub > Actions > Cliquer sur le workflow qui a échoué

# Tester localement
./full_pipeline.sh

# Valider la configuration
./DeploymentScripts/deploy_helper.sh validate
```

## 📚 Documentation Complète

- 🚀 **[Guide de Déploiement](DEPLOYMENT.md)** - Processus détaillé
- 🔐 **[Configuration des Secrets](SECRETS_SETUP.md)** - Setup complet
- 📖 **[README Principal](../README.md)** - Vue d'ensemble du projet

## ✨ Fonctionnalités Avancées

### Déploiement Manuel (si nécessaire)
```bash
# Déploiement staging manuel
./DeploymentScripts/deploy_helper.sh deploy -v 1.0.0 -e staging

# Déploiement production manuel
./DeploymentScripts/deploy_helper.sh deploy -v 1.0.0 -e production
```

### Monitoring
- 📊 **GitHub Actions** : Logs détaillés de chaque build
- 📱 **App Store Connect** : Statut des soumissions
- 🔔 **Notifications** : Emails automatiques en cas d'échec

### Sécurité
- 🔒 **Secrets chiffrés** : Stockage sécurisé dans GitHub
- 🔑 **Rotation automatique** : Renouvellement des certificats
- 🛡️ **Scan de sécurité** : Détection automatique des vulnérabilités

---

**🎉 Félicitations !** Votre pipeline de déploiement Manounou est prêt !

**⏱️ Temps de configuration :** ~5 minutes  
**🚀 Déploiements :** Automatiques  
**🔧 Maintenance :** Minimale  

Pour toute question, consultez la [documentation complète](DEPLOYMENT.md) ou contactez l'équipe DevOps.
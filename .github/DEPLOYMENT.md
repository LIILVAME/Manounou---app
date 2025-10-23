# 🚀 Guide de Déploiement - Manounou

Ce document décrit le processus de déploiement automatique de l'application Manounou via GitHub Actions.

## 📋 Vue d'Ensemble

Le système de déploiement automatique comprend :

- ✅ **Intégration Continue (CI)** : Tests et validation automatiques
- 🚀 **Déploiement Continu (CD)** : Déploiement automatique vers TestFlight/App Store
- 🔍 **Validation des PR** : Vérification automatique des pull requests
- 📊 **Rapports de qualité** : Métriques et analyses de code

## 🔄 Workflows GitHub Actions

### 1. 🧪 CI - Intégration Continue (`ci.yml`)

**Déclencheurs :**
- Push sur `main` et `develop`
- Pull requests vers `main`

**Jobs :**
- **Code Validation** : Syntaxe Swift, build simulateur, tests
- **Security Scanning** : Scan des secrets, vérification des dépendances
- **Code Quality** : Métriques de qualité, standards de code

### 2. 🚀 Deploy - Déploiement (`deploy.yml`)

**Déclencheurs :**
- Release GitHub (automatique)
- Déclenchement manuel (`workflow_dispatch`)

**Environnements :**
- **Staging** : Déploiement vers TestFlight
- **Production** : Déploiement vers App Store

### 3. 🔍 PR Validation (`pr-validation.yml`)

**Déclencheurs :**
- Ouverture/mise à jour de pull requests

**Validations :**
- Titre et description de la PR
- Messages de commit
- Analyse des changements
- Review automatique du code

## 🎯 Processus de Déploiement

### 📱 Déploiement TestFlight (Staging)

1. **Déclenchement**
   ```bash
   # Via release GitHub
   git tag v1.0.0-beta.1
   git push origin v1.0.0-beta.1
   
   # Ou déclenchement manuel dans GitHub Actions
   ```

2. **Processus automatique**
   - ✅ Checkout du code
   - 🔧 Configuration Xcode
   - 📦 Résolution des dépendances
   - 🏗️ Build Release
   - 📱 Export IPA
   - ☁️ Upload vers TestFlight

3. **Notification**
   - 📧 Email de confirmation
   - 💬 Notification Slack (si configuré)

### 🏪 Déploiement App Store (Production)

1. **Déclenchement**
   ```bash
   # Release de production
   git tag v1.0.0
   git push origin v1.0.0
   ```

2. **Processus automatique**
   - Tous les steps du TestFlight
   - ➕ Soumission pour review Apple
   - 📋 Métadonnées App Store

## 🔧 Configuration Initiale

### 1. 📋 Prérequis

- [x] Compte Apple Developer actif
- [x] App créée dans App Store Connect
- [x] Certificats de distribution valides
- [x] Profils de provisioning configurés

### 2. 🔐 Configuration des Secrets

Suivez le guide détaillé : [SECRETS_SETUP.md](.github/SECRETS_SETUP.md)

**Secrets requis :**
```
APPLE_ID
APPLE_APP_SPECIFIC_PASSWORD
APPLE_TEAM_ID
BUILD_CERTIFICATE_BASE64
P12_PASSWORD
BUILD_PROVISION_PROFILE_BASE64
KEYCHAIN_PASSWORD
```

### 3. ⚙️ Configuration App Store Connect

1. **Informations de l'app**
   - Bundle ID : `com.manounou.app`
   - Version initiale : `1.0.0`
   - Catégorie : Lifestyle/Family

2. **Métadonnées**
   - Description
   - Mots-clés
   - Screenshots
   - Icône de l'app

## 🚦 Stratégie de Branching

### GitFlow Adapté

```
main (production)
├── develop (développement)
├── feature/* (fonctionnalités)
├── release/* (préparation release)
└── hotfix/* (corrections urgentes)
```

### Règles de Déploiement

| Branche | Déploiement | Automatique |
|---------|-------------|-------------|
| `main` | App Store | ✅ (via release) |
| `develop` | TestFlight | ✅ (via tag beta) |
| `feature/*` | - | ❌ |
| `release/*` | TestFlight | ✅ |
| `hotfix/*` | TestFlight | ✅ |

## 📊 Monitoring et Logs

### 🔍 Surveillance des Builds

1. **GitHub Actions**
   - Logs détaillés de chaque étape
   - Artifacts de build disponibles
   - Notifications en cas d'échec

2. **App Store Connect**
   - Statut de traitement
   - Rapports de validation
   - Métriques de téléchargement

### 📈 Métriques de Qualité

- **Couverture de tests** : Objectif 80%+
- **Temps de build** : < 10 minutes
- **Taille de l'app** : Surveillance continue
- **Crash rate** : < 1%

## 🐛 Dépannage

### Erreurs Communes

#### 🔐 Erreurs d'Authentification

```
Error: Invalid credentials
```

**Solution :**
1. Vérifiez `APPLE_ID` et `APPLE_APP_SPECIFIC_PASSWORD`
2. Régénérez l'App-Specific Password si nécessaire

#### 📱 Erreurs de Certificat

```
Error: No signing certificate found
```

**Solution :**
1. Vérifiez `BUILD_CERTIFICATE_BASE64`
2. Confirmez que le certificat n'est pas expiré
3. Vérifiez `P12_PASSWORD`

#### 📦 Erreurs de Provisioning

```
Error: Provisioning profile not found
```

**Solution :**
1. Vérifiez `BUILD_PROVISION_PROFILE_BASE64`
2. Confirmez que le profil correspond au Bundle ID
3. Vérifiez que le profil n'est pas expiré

### 🔧 Commandes de Debug

```bash
# Test local de build
./BuildScripts/build_release.sh

# Vérification des certificats
security find-identity -v -p codesigning

# Test de l'authentification Apple
xcrun altool --list-providers \
             --username "$APPLE_ID" \
             --password "$APPLE_APP_SPECIFIC_PASSWORD"
```

## 📅 Maintenance

### 🔄 Tâches Régulières

#### Hebdomadaire
- [ ] Vérification des builds automatiques
- [ ] Review des métriques de qualité
- [ ] Mise à jour des dépendances

#### Mensuel
- [ ] Vérification des certificats (expiration)
- [ ] Audit des secrets GitHub
- [ ] Review des performances de déploiement

#### Trimestriel
- [ ] Mise à jour des workflows GitHub Actions
- [ ] Review de la stratégie de déploiement
- [ ] Formation de l'équipe sur les nouveaux processus

### 📋 Checklist de Release

#### Avant la Release
- [ ] Tests passent sur `develop`
- [ ] Code review terminé
- [ ] Documentation mise à jour
- [ ] Changelog préparé
- [ ] Version bump effectué

#### Pendant la Release
- [ ] Tag créé avec la bonne version
- [ ] Build automatique réussi
- [ ] Upload TestFlight confirmé
- [ ] Tests internes effectués

#### Après la Release
- [ ] Soumission App Store (si production)
- [ ] Communication équipe
- [ ] Monitoring post-déploiement
- [ ] Feedback utilisateurs collecté

## 🎯 Bonnes Pratiques

### ✅ Développement

- **Tests** : Écrivez des tests pour chaque nouvelle fonctionnalité
- **Code Review** : Toujours faire reviewer le code
- **Commits** : Messages clairs et descriptifs
- **Branches** : Utilisez des noms explicites

### 🚀 Déploiement

- **Staging First** : Toujours tester en staging avant production
- **Rollback Plan** : Ayez un plan de retour en arrière
- **Monitoring** : Surveillez les métriques post-déploiement
- **Communication** : Informez l'équipe des déploiements

### 🔒 Sécurité

- **Secrets** : Ne jamais commiter de secrets
- **Accès** : Limitez l'accès aux environnements de production
- **Audit** : Loggez tous les déploiements
- **Rotation** : Renouvelez régulièrement les secrets

## 📞 Support et Contacts

### 🆘 En cas de problème

1. **Vérifiez les logs GitHub Actions**
2. **Consultez ce guide de dépannage**
3. **Contactez l'équipe DevOps**
4. **Escaladez si nécessaire**

### 📚 Ressources Utiles

- [Documentation GitHub Actions](https://docs.github.com/en/actions)
- [Guide Apple Developer](https://developer.apple.com/documentation/)
- [App Store Connect Help](https://help.apple.com/app-store-connect/)
- [Xcode Documentation](https://developer.apple.com/documentation/xcode)

---

**🎉 Félicitations !** Votre pipeline de déploiement est maintenant configuré et prêt à automatiser vos releases Manounou !
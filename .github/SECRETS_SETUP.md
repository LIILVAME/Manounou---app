# 🔐 Configuration des Secrets GitHub - Manounou

Ce document décrit la configuration des secrets nécessaires pour le déploiement automatique de l'application Manounou.

## 📋 Secrets Requis

### 🍎 Secrets Apple Developer

| Secret | Description | Obtention |
|--------|-------------|-----------|
| `APPLE_ID` | Identifiant Apple Developer | Votre email Apple Developer |
| `APPLE_APP_SPECIFIC_PASSWORD` | Mot de passe spécifique à l'app | [App-Specific Passwords](https://appleid.apple.com/account/manage) |
| `APPLE_TEAM_ID` | ID de l'équipe Apple Developer | [Developer Portal](https://developer.apple.com/account/) |

### 🔑 Certificats et Provisioning

| Secret | Description | Format |
|--------|-------------|--------|
| `BUILD_CERTIFICATE_BASE64` | Certificat de distribution | Base64 du fichier .p12 |
| `P12_PASSWORD` | Mot de passe du certificat | Texte |
| `BUILD_PROVISION_PROFILE_BASE64` | Profil de provisioning | Base64 du fichier .mobileprovision |
| `KEYCHAIN_PASSWORD` | Mot de passe du keychain temporaire | Texte sécurisé |

## 🛠️ Configuration Étape par Étape

### 1. 🍎 Configuration Apple Developer

1. **Apple ID**
   ```bash
   # Utilisez votre email Apple Developer
   APPLE_ID="votre.email@example.com"
   ```

2. **App-Specific Password**
   - Allez sur [appleid.apple.com](https://appleid.apple.com/account/manage)
   - Section "Sign-In and Security" > "App-Specific Passwords"
   - Générez un nouveau mot de passe pour "GitHub Actions"
   - Copiez le mot de passe généré

3. **Team ID**
   - Connectez-vous au [Developer Portal](https://developer.apple.com/account/)
   - Section "Membership" > Team ID
   - Copiez l'ID de l'équipe (format: XXXXXXXXXX)

### 2. 🔑 Préparation des Certificats

#### Certificat de Distribution

1. **Export du certificat depuis Keychain**
   ```bash
   # Ouvrez Keychain Access
   # Trouvez votre certificat "Apple Distribution"
   # Clic droit > Export > Format .p12
   # Définissez un mot de passe sécurisé
   ```

2. **Conversion en Base64**
   ```bash
   base64 -i /path/to/certificate.p12 | pbcopy
   ```

#### Profil de Provisioning

1. **Téléchargement depuis Developer Portal**
   - Allez sur [developer.apple.com](https://developer.apple.com/account/resources/profiles/list)
   - Téléchargez le profil de distribution pour votre app

2. **Conversion en Base64**
   ```bash
   base64 -i /path/to/profile.mobileprovision | pbcopy
   ```

### 3. ⚙️ Configuration dans GitHub

1. **Accès aux Settings**
   - Allez dans votre repository GitHub
   - Settings > Secrets and variables > Actions

2. **Ajout des Secrets**
   
   Cliquez sur "New repository secret" pour chaque secret :

   ```
   Name: APPLE_ID
   Secret: votre.email@example.com
   ```

   ```
   Name: APPLE_APP_SPECIFIC_PASSWORD
   Secret: xxxx-xxxx-xxxx-xxxx
   ```

   ```
   Name: APPLE_TEAM_ID
   Secret: XXXXXXXXXX
   ```

   ```
   Name: BUILD_CERTIFICATE_BASE64
   Secret: [Contenu Base64 du certificat]
   ```

   ```
   Name: P12_PASSWORD
   Secret: [Mot de passe du certificat]
   ```

   ```
   Name: BUILD_PROVISION_PROFILE_BASE64
   Secret: [Contenu Base64 du profil]
   ```

   ```
   Name: KEYCHAIN_PASSWORD
   Secret: [Mot de passe sécurisé pour le keychain temporaire]
   ```

## 🔒 Sécurité et Bonnes Pratiques

### ✅ À Faire

- ✅ Utilisez des mots de passe forts et uniques
- ✅ Renouvelez les certificats avant expiration
- ✅ Limitez l'accès aux secrets aux personnes autorisées
- ✅ Utilisez des App-Specific Passwords plutôt que votre mot de passe principal
- ✅ Documentez les dates d'expiration des certificats

### ❌ À Éviter

- ❌ Ne jamais commiter les secrets dans le code
- ❌ Ne pas partager les secrets par email ou chat
- ❌ Ne pas utiliser des mots de passe faibles
- ❌ Ne pas oublier de renouveler les certificats

## 📅 Maintenance

### Renouvellement des Certificats

1. **Vérification de l'expiration**
   ```bash
   # Vérifiez la date d'expiration dans Keychain Access
   # Ou dans le Developer Portal
   ```

2. **Mise à jour des secrets**
   - Générez de nouveaux certificats
   - Mettez à jour les secrets GitHub
   - Testez le déploiement

### Rotation des Mots de Passe

- **App-Specific Password** : Renouvelez tous les 6 mois
- **Keychain Password** : Changez à chaque mise à jour de certificat
- **P12 Password** : Utilisez un nouveau mot de passe pour chaque certificat

## 🧪 Test de Configuration

### Validation des Secrets

1. **Test manuel**
   - Déclenchez un workflow de déploiement
   - Vérifiez les logs pour les erreurs d'authentification

2. **Commandes de test**
   ```bash
   # Test de l'authentification Apple
   xcrun altool --list-providers \
                --username "$APPLE_ID" \
                --password "$APPLE_APP_SPECIFIC_PASSWORD"
   ```

### Dépannage

| Erreur | Solution |
|--------|----------|
| "Invalid credentials" | Vérifiez APPLE_ID et APPLE_APP_SPECIFIC_PASSWORD |
| "Certificate not found" | Vérifiez BUILD_CERTIFICATE_BASE64 et P12_PASSWORD |
| "Provisioning profile invalid" | Vérifiez BUILD_PROVISION_PROFILE_BASE64 |
| "Team not found" | Vérifiez APPLE_TEAM_ID |

## 📞 Support

En cas de problème :

1. Vérifiez les logs GitHub Actions
2. Consultez la documentation Apple Developer
3. Vérifiez les dates d'expiration des certificats
4. Contactez l'équipe de développement

---

**⚠️ Important** : Ces secrets donnent accès à votre compte Apple Developer. Traitez-les avec le même niveau de sécurité que vos mots de passe personnels.
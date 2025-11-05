# 🔐 Configuration Supabase Auth — Manounou

**Problème :** Erreur 400 lors de l'inscription/connexion  
**Solution :** Activer le provider Email/Password dans Supabase

---

## 🚨 Problème Identifié

L'erreur `400 Bad Request` sur `/auth/v1/token` indique que :
- Le provider **Email/Password** n'est probablement pas activé dans Supabase Auth
- Ou les paramètres Auth ne sont pas correctement configurés

---

## ✅ Solution : Activer Email/Password Auth

### Étape 1 : Accéder aux Settings Auth

1. Aller sur [supabase.com/dashboard](https://supabase.com/dashboard)
2. Sélectionner le projet **"Manounou"**
3. Aller dans **Authentication** (menu de gauche)
4. Cliquer sur **"Providers"** dans le sous-menu

### Étape 2 : Activer Email Provider

1. Chercher **"Email"** dans la liste des providers
2. **Activer** le toggle pour Email
3. Vérifier les options :
   - ✅ **Enable Email Signup** — Activer l'inscription par email
   - ✅ **Confirm email** — Optionnel pour MVP (peut être désactivé pour tests)
   - ✅ **Secure email change** — Activer (recommandé)

### Étape 3 : Configurer les Options

**Pour MVP (développement rapide) :**
- **Confirm email** : **Désactivé** (pour tester sans vérification email)
- **Enable Email Signup** : **Activé**

**Pour Production :**
- **Confirm email** : **Activé** (sécurité)
- **Enable Email Signup** : **Activé**

### Étape 4 : Sauvegarder

1. Cliquer sur **"Save"** en bas de la page
2. Attendre quelques secondes pour que les changements prennent effet

---

## 🔍 Vérification

### Test Rapide

Après avoir activé Email Auth, tu peux tester :

1. **Relancer l'app Flutter** (hot restart : `R` dans le terminal)
2. **Créer un compte** avec email/password
3. **Vérifier** que l'inscription fonctionne

### Si ça ne fonctionne toujours pas

1. **Vérifier les logs** dans le terminal Flutter
2. **Vérifier les logs Supabase** :
   - Dashboard Supabase → Logs → Auth
   - Chercher les erreurs récentes

---

## 📋 Configuration Recommandée pour MVP

### Auth Providers
- ✅ **Email** — Activé
- ⚠️ **Apple** — Optionnel (nécessite configuration Apple Developer)
- ❌ **Google** — Optionnel (peut être ajouté plus tard)

### Auth Settings
- **Site URL** : `http://localhost:3000` (pour développement)
- **Redirect URLs** : 
  - `io.supabase.manounou://login-callback/` (pour mobile)
  - `io.supabase.manounou://reset-password` (pour reset password mobile)
  - `manounou://login-callback` (alternative)
  - `manounou://reset-password` (alternative)
  - `http://localhost:3000/**` (pour web - optionnel)

**⚠️ Important :** Pour le reset password, utiliser plutôt **"Update Password"** dans le Dashboard pour l'instant, car les deep links nécessitent une configuration supplémentaire dans Flutter.

### Email Templates (Optionnel)
- Tu peux personnaliser les emails de confirmation plus tard
- Pour MVP, les templates par défaut suffisent

---

## 🐛 Dépannage

### Erreur : "Email provider not enabled"
**Solution :** Activer Email dans Auth → Providers

### Erreur : "Email already registered"
**Solution :** L'email existe déjà. Utiliser un autre email ou se connecter.

### Erreur : "Invalid login credentials"
**Solution :** Vérifier email/password. Si nouveau compte, vérifier que l'inscription a réussi.

### Erreur : "Email not confirmed"
**Solution :** 
- Option 1 : Activer "Confirm email" dans Auth settings
- Option 2 : Désactiver "Confirm email" pour MVP (développement)

---

## 🔧 Configuration Avancée (Optionnel)

### Password Requirements
Dans Supabase Auth → Settings :
- **Minimum password length** : 6 caractères (par défaut)
- **Password strength** : Peut être configuré

### Rate Limiting
- Par défaut, Supabase limite les tentatives de connexion
- Pour MVP, les limites par défaut sont suffisantes

---

## ✅ Checklist

- [ ] Email provider activé dans Supabase
- [ ] Enable Email Signup activé
- [ ] Confirm email configuré (activé ou désactivé selon besoin)
- [ ] Settings sauvegardés
- [ ] App Flutter relancée (hot restart)
- [ ] Test inscription effectué
- [ ] Test connexion effectué

---

## 📚 Ressources

- **Supabase Auth Docs** : [supabase.com/docs/guides/auth](https://supabase.com/docs/guides/auth)
- **Flutter Supabase Auth** : [supabase.com/docs/guides/getting-started/flutter#authentication](https://supabase.com/docs/guides/getting-started/flutter#authentication)
- **Guide FlutterFlow** : `/docs/FLUTTERFLOW_SETUP_COMPLETE.md`

---

**Document maintenu par :** MultiApp Builder Team  
**Dernière mise à jour :** 2025-01-13


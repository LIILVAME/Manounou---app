# 🔑 Réinitialiser le Mot de Passe — Manounou

**Problème :** Connexion impossible avec `tvaa@duck.com`  
**Solution :** Réinitialiser le mot de passe via Supabase Dashboard

---

## 🎯 Solution Immédiate

### Étape 1 : Accéder au Dashboard Supabase

1. Aller sur [supabase.com/dashboard](https://supabase.com/dashboard)
2. Sélectionner le projet **"Manounou"**
3. Aller dans **Authentication** (menu de gauche)
4. Cliquer sur **"Users"**

### Étape 2 : Trouver l'Utilisateur

1. Chercher `tvaa@duck.com` dans la liste
2. Cliquer sur l'utilisateur pour voir les détails

### Étape 3 : Réinitialiser le Mot de Passe

**Option A : Envoyer un Email de Réinitialisation**

1. Cliquer sur **"..."** (3 points) à droite de l'utilisateur
2. Sélectionner **"Reset Password"**
3. Un email sera envoyé à `tvaa@duck.com`
4. Vérifier la boîte email (spam aussi)
5. Cliquer sur le lien dans l'email
6. Définir un nouveau mot de passe
7. **Noter ce nouveau mot de passe**
8. Tester la connexion dans l'app

**Option B : Modifier le Mot de Passe Directement (Admin)**

1. Cliquer sur **"..."** (3 points) à droite de l'utilisateur
2. Sélectionner **"Send Password Reset"** ou **"Reset Password"**
3. Si l'option existe, tu peux aussi **"Update Password"** directement
4. Définir un nouveau mot de passe
5. **Noter ce mot de passe**
6. Tester la connexion

---

## 🔧 Alternative : Créer un Nouveau Compte Test

Si la réinitialisation ne fonctionne pas :

1. Dans l'app Flutter, créer un **nouveau compte** avec :
   - Email : `test@manounou.com` (ou autre email)
   - Mot de passe : `test123456` (noter exactement)
2. **Noter ces identifiants**
3. Tester la connexion immédiatement avec ces identifiants

---

## 🚀 Test Rapide

### Après Réinitialisation

1. **Ouvrir l'app Flutter**
2. **Page Login**
3. Entrer :
   - Email : `tvaa@duck.com`
   - Mot de passe : Le nouveau mot de passe défini
4. Cliquer sur **"Se connecter"**
5. ✅ Devrait fonctionner maintenant

---

## 📋 Checklist

- [ ] Accéder au Dashboard Supabase
- [ ] Trouver l'utilisateur `tvaa@duck.com`
- [ ] Réinitialiser le mot de passe
- [ ] Vérifier l'email de réinitialisation
- [ ] Définir un nouveau mot de passe
- [ ] Noter le nouveau mot de passe
- [ ] Tester la connexion dans l'app
- [ ] Vérifier que `last_sign_in_at` est mis à jour dans Supabase

---

## 🐛 Si ça ne fonctionne toujours pas

### Vérifier les Settings Auth

1. Dashboard → **Authentication** → **Settings**
2. Vérifier :
   - ✅ **Site URL** : Configuré
   - ✅ **Redirect URLs** : Inclut `io.supabase.manounou://login-callback/`

### Vérifier le Provider Email

1. Dashboard → **Authentication** → **Providers**
2. Vérifier que **Email** est activé
3. Vérifier que **Enable Email Signup** est activé

### Créer un Compte Test

Si rien ne fonctionne, créer un nouveau compte test avec des identifiants simples et tester immédiatement.

---

## 📚 Ressources

- **Supabase Auth Docs** : [supabase.com/docs/guides/auth](https://supabase.com/docs/guides/auth)
- **Guide Troubleshooting** : `/docs/AUTH_TROUBLESHOOTING.md`
- **Fix Immédiat** : `/docs/AUTH_FIX_IMMEDIAT.md`

---

**Document maintenu par :** MultiApp Builder Team  
**Dernière mise à jour :** 2025-01-13


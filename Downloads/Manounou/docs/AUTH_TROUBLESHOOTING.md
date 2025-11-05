# 🔐 Troubleshooting Auth — Manounou

**Problème :** Compte créé mais connexion impossible  
**Erreur :** `Invalid login credentials` (400)

---

## 🚨 Problème Identifié

Tu es inscrit dans Supabase (visible dans Authentication → Users), mais la connexion échoue avec "Invalid login credentials".

**Causes possibles :**
1. **Email non confirmé** — Si "Confirm email" est activé, tu dois confirmer l'email avant de te connecter
2. **Mot de passe incorrect** — Le mot de passe utilisé pour la connexion ne correspond pas
3. **Email avec espaces** — Des espaces peuvent être présents dans l'email
4. **Problème de configuration Auth** — Le provider Email n'est pas correctement configuré

---

## ✅ Solution 1 : Vérifier Email Confirmation

### Option A : Désactiver Email Confirmation (MVP - Développement)

1. Aller sur [supabase.com/dashboard](https://supabase.com/dashboard)
2. Projet "Manounou" → **Authentication** → **Providers**
3. Cliquer sur **"Email"**
4. **Désactiver** "Confirm email"
5. **Sauvegarder**

**Après ça :** Relancer l'app et tester la connexion

### Option B : Confirmer l'Email

Si tu veux garder la confirmation email :
1. Vérifier ta boîte email (spam aussi)
2. Cliquer sur le lien de confirmation
3. Puis te connecter

---

## ✅ Solution 2 : Vérifier le Mot de Passe

### Créer un Nouveau Compte Test

1. **Utiliser un email différent** pour créer un nouveau compte
2. **Noter le mot de passe** exactement comme tu l'as tapé
3. **Tester la connexion** avec ces mêmes identifiants

### Réinitialiser le Mot de Passe

Si le compte existe déjà :
1. Dans Supabase Dashboard → **Authentication** → **Users**
2. Trouver ton utilisateur
3. Cliquer sur **"..."** → **"Reset Password"**
4. Un email de réinitialisation sera envoyé

---

## ✅ Solution 3 : Vérifier la Configuration Auth

### Vérifier les Settings Auth

1. Supabase Dashboard → **Authentication** → **Settings**
2. Vérifier :
   - ✅ **Site URL** : Configuré (peut être `http://localhost:3000` pour dev)
   - ✅ **Redirect URLs** : Inclut `io.supabase.manounou://login-callback/`
   - ✅ **Email Provider** : Activé dans Providers

### Vérifier les Policies RLS

Si RLS bloque l'accès :
1. Vérifier que les policies sont correctes
2. Tester avec un utilisateur authentifié

---

## 🔧 Solution 4 : Créer un Utilisateur Test Directement

### Via Supabase Dashboard

1. **Authentication** → **Users**
2. Cliquer sur **"Add user"** ou **"Invite user"**
3. Entrer email et mot de passe
4. **Cocher** "Auto Confirm User" (pour éviter la confirmation email)
5. **Créer**

**Ensuite :** Tester la connexion avec ces identifiants

### Via SQL (Avancé)

```sql
-- Créer un utilisateur test directement
INSERT INTO auth.users (
  instance_id,
  id,
  aud,
  role,
  email,
  encrypted_password,
  email_confirmed_at,
  created_at,
  updated_at
) VALUES (
  '00000000-0000-0000-0000-000000000000',
  gen_random_uuid(),
  'authenticated',
  'authenticated',
  'test@manounou.com',
  crypt('test123456', gen_salt('bf')),
  now(),
  now(),
  now()
);
```

**⚠️ Note :** Cette méthode nécessite des permissions admin. Utilise plutôt le Dashboard.

---

## 🧪 Test Rapide

### 1. Vérifier l'Utilisateur dans Supabase

1. Dashboard → **Authentication** → **Users**
2. Trouver ton utilisateur
3. Vérifier :
   - ✅ Email correct
   - ✅ `email_confirmed_at` : Date ou NULL
   - ✅ `confirmed_at` : Date ou NULL

### 2. Tester avec un Nouveau Compte

1. **Créer un nouveau compte** avec email différent
2. **Noter précisément** email et mot de passe
3. **Tester la connexion** immédiatement

### 3. Vérifier les Logs

Dans le terminal Flutter, tu devrais voir :
```
Erreur connexion complète: AuthApiException(message: Invalid login credentials...)
Email tenté: [ton email]
```

**Vérifier :** L'email affiché correspond exactement à celui utilisé lors de l'inscription.

---

## 📋 Checklist de Diagnostic

- [ ] Email provider activé dans Supabase
- [ ] "Confirm email" désactivé (pour MVP) ou email confirmé
- [ ] Mot de passe correct (pas d'espaces, même casse)
- [ ] Email correct (pas d'espaces, même format)
- [ ] Utilisateur visible dans Authentication → Users
- [ ] Site URL configuré dans Auth Settings
- [ ] Test avec nouveau compte effectué

---

## 🎯 Solution Recommandée pour MVP

**Pour développement rapide :**

1. **Désactiver Email Confirmation**
   - Authentication → Providers → Email
   - Désactiver "Confirm email"
   - Sauvegarder

2. **Créer un compte test**
   - Utiliser l'app Flutter
   - Créer compte avec email simple (ex: test@test.com)
   - Mot de passe simple (ex: test123456)
   - Noter ces identifiants

3. **Tester la connexion**
   - Relancer l'app (hot restart)
   - Se connecter avec les identifiants notés

4. **Si ça fonctionne**
   - Le problème était la confirmation email
   - Tu peux continuer le développement

---

## 🔍 Debug Avancé

### Vérifier les Logs Supabase

1. Dashboard → **Logs** → **Auth**
2. Chercher les erreurs récentes
3. Vérifier les détails de l'erreur

### Test avec cURL (Optionnel)

```bash
curl -X POST 'https://emgrtgencepzainsknsb.supabase.co/auth/v1/token?grant_type=password' \
  -H "apikey: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVtZ3J0Z2VuY2VwemFpbnNrbnNiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTUxNjU3MzcsImV4cCI6MjA3MDc0MTczN30.2TtED_BEXHf6UqgPPcuOOd5YYTZlyqLSZRMoZtO93yM" \
  -H "Content-Type: application/json" \
  -d '{"email":"test@test.com","password":"test123456"}'
```

**Remplace** `test@test.com` et `test123456` par tes vrais identifiants.

---

## 📚 Ressources

- **Supabase Auth Docs** : [supabase.com/docs/guides/auth](https://supabase.com/docs/guides/auth)
- **Guide Auth Setup** : `/docs/SUPABASE_AUTH_SETUP.md`
- **Flutter Supabase Auth** : [supabase.com/docs/guides/getting-started/flutter#authentication](https://supabase.com/docs/guides/getting-started/flutter#authentication)

---

**Document maintenu par :** MultiApp Builder Team  
**Dernière mise à jour :** 2025-01-13


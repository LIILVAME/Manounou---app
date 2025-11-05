# 🔧 Fix Redirect Password Reset — Manounou

**Problème :** Le lien de réinitialisation pointe vers `localhost:3000` qui ne fonctionne pas  
**Solution :** Configurer les redirect URLs dans Supabase pour l'app mobile

---

## 🚨 Problème Identifié

Quand tu cliques sur le lien de réinitialisation dans l'email, tu arrives sur `localhost:3000` qui ne fonctionne pas car :
- L'app Flutter n'est pas un serveur web
- Pour une app mobile, il faut utiliser un **deep link** ou **URL scheme**

---

## ✅ Solution Immédiate : Réinitialiser depuis le Dashboard

**Le plus simple pour maintenant :**

1. Aller sur [supabase.com/dashboard](https://supabase.com/dashboard)
2. Projet "Manounou" → **Authentication** → **Users**
3. Trouver `tvaa@duck.com`
4. Cliquer sur **"..."** (3 points) à droite
5. **Option 1 :** Cliquer sur **"Update Password"** si disponible
   - Définir un nouveau mot de passe directement
   - **Noter ce mot de passe**
6. **Option 2 :** Cliquer sur **"Send Password Reset"** 
   - Mais cette fois, on va configurer les redirect URLs d'abord (voir ci-dessous)

---

## 🔧 Solution Long Terme : Configurer les Redirect URLs

### Étape 1 : Configurer les Redirect URLs dans Supabase

1. Dashboard Supabase → **Authentication** → **URL Configuration**
2. Dans **"Redirect URLs"**, ajouter :
   ```
   io.supabase.manounou://reset-password
   io.supabase.manounou://login-callback
   manounou://reset-password
   manounou://login-callback
   ```
3. **Site URL** : Peut rester `http://localhost:3000` pour le moment
4. **Sauvegarder**

### Étape 2 : Configurer Deep Links dans Flutter (Plus tard)

Pour que les deep links fonctionnent dans l'app Flutter, il faudra :
- Configurer les URL schemes dans `android/app/src/main/AndroidManifest.xml`
- Configurer les URL schemes dans `ios/Runner/Info.plist`
- Ajouter la gestion des deep links dans le code Flutter

**Mais pour MVP, on peut utiliser la méthode Dashboard pour l'instant.**

---

## 🎯 Solution Alternative : Créer un Compte Test

**Pour tester rapidement l'authentification :**

1. Dans l'app Flutter, créer un **nouveau compte** avec :
   - Email : `test@manounou.com` (ou autre email non utilisé)
   - Mot de passe : `test123456` (noter exactement)
2. **Noter ces identifiants**
3. Tester la connexion immédiatement avec ces identifiants
4. Si ça fonctionne, tu peux continuer avec ce compte test

---

## 🔧 Solution Temporaire : Modifier le Mot de Passe via SQL (Admin)

**⚠️ Attention :** Cette méthode nécessite des permissions admin et est complexe. Préférer la méthode Dashboard.

Si tu veux quand même essayer (avancé) :

1. Dashboard → **SQL Editor**
2. Exécuter (remplacer `NEW_PASSWORD` par ton nouveau mot de passe) :

```sql
-- Cette méthode ne fonctionne pas directement car les mots de passe sont hashés
-- Il faut utiliser la fonction Supabase pour hasher
-- Mieux vaut utiliser le Dashboard → Update Password
```

**Recommandation :** Utiliser plutôt **"Update Password"** dans le Dashboard si disponible.

---

## 📋 Checklist Solution Rapide

- [ ] Aller sur Dashboard Supabase
- [ ] Authentication → Users
- [ ] Trouver `tvaa@duck.com`
- [ ] Cliquer sur "..." → "Update Password" (si disponible)
- [ ] Définir un nouveau mot de passe
- [ ] Noter le nouveau mot de passe
- [ ] Tester la connexion dans l'app
- [ ] ✅ Devrait fonctionner maintenant

---

## 🚀 Pour Plus Tard : Implémenter Forgot Password dans l'App

Quand tu auras le temps, implémenter une page "Forgot Password" dans l'app :

1. Créer une page `ForgotPasswordPage`
2. Formulaire avec champ email
3. Action : `Supabase → Reset Password For Email`
4. Configurer les redirect URLs correctement
5. Gérer le deep link dans l'app

**Mais pour MVP, la méthode Dashboard suffit.**

---

## 📚 Ressources

- **Supabase Auth Redirect URLs** : [supabase.com/docs/guides/auth#redirect-urls](https://supabase.com/docs/guides/auth#redirect-urls)
- **Flutter Deep Links** : [flutter.dev/docs/development/ui/navigation/deep-linking](https://flutter.dev/docs/development/ui/navigation/deep-linking)
- **Guide Reset Password** : `/docs/RESET_PASSWORD_GUIDE.md`

---

**Document maintenu par :** MultiApp Builder Team  
**Dernière mise à jour :** 2025-01-13


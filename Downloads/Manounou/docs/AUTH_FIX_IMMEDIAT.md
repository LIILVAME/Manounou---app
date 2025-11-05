# 🔧 Fix Immédiat Auth — Manounou

**Problème :** Compte créé mais connexion impossible  
**Diagnostic :** Utilisateur confirmé mais jamais connecté (mot de passe probablement incorrect)

---

## 🔍 Diagnostic

D'après la base de données :
- ✅ Utilisateur `vametoure@hotmail.com` existe
- ✅ Email confirmé (`email_confirmed_at` présent)
- ❌ `last_sign_in_at` = NULL (jamais connecté avec succès)

**Conclusion :** Le mot de passe utilisé pour la connexion ne correspond probablement pas à celui utilisé lors de l'inscription.

---

## ✅ Solution Immédiate : Réinitialiser le Mot de Passe

### Méthode 1 : Via Supabase Dashboard (Recommandé)

1. Aller sur [supabase.com/dashboard](https://supabase.com/dashboard)
2. Projet "Manounou" → **Authentication** → **Users**
3. Trouver l'utilisateur `vametoure@hotmail.com`
4. Cliquer sur **"..."** (3 points) à droite
5. Sélectionner **"Reset Password"**
6. Un email de réinitialisation sera envoyé
7. Cliquer sur le lien dans l'email
8. Définir un nouveau mot de passe
9. **Noter ce mot de passe**
10. Tester la connexion dans l'app avec ce nouveau mot de passe

### Méthode 2 : Créer un Nouveau Compte Test

1. Dans l'app Flutter, créer un **nouveau compte** avec :
   - Email : `test@manounou.com` (ou autre)
   - Mot de passe : `test123456` (noter exactement)
2. **Noter ces identifiants**
3. Tester la connexion immédiatement avec ces identifiants

---

## 🔧 Solution Alternative : Réinitialiser via Code (Avancé)

Si tu veux réinitialiser le mot de passe programmatiquement :

```dart
// Dans Flutter, ajouter une fonction de reset password
await Supabase.instance.client.auth.resetPasswordForEmail(
  'vametoure@hotmail.com',
  redirectTo: 'io.supabase.manounou://reset-password',
);
```

Mais c'est plus complexe, la méthode Dashboard est plus simple.

---

## 🎯 Action Immédiate Recommandée

**Option 1 : Réinitialiser le mot de passe** (5 min)
1. Dashboard Supabase → Authentication → Users
2. Reset Password pour `vametoure@hotmail.com`
3. Vérifier email et définir nouveau mot de passe
4. Tester connexion

**Option 2 : Créer compte test** (2 min)
1. Créer nouveau compte dans l'app avec identifiants simples
2. Noter email/mot de passe
3. Tester connexion immédiatement

---

## 📋 Checklist

- [ ] Réinitialiser mot de passe ou créer nouveau compte
- [ ] Noter les identifiants exacts
- [ ] Relancer l'app (hot restart : `R`)
- [ ] Tester la connexion
- [ ] Vérifier que `last_sign_in_at` est mis à jour dans Supabase

---

**Document maintenu par :** MultiApp Builder Team  
**Dernière mise à jour :** 2025-01-13


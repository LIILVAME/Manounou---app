# 🔧 Fix Auth Trigger — Manounou

**Problème :** Erreur 500 "Database error saving new user"  
**Cause :** Trigger `handle_new_user()` essaie d'insérer dans `public.profiles` qui n'existe pas  
**Solution :** Modifier le trigger pour utiliser `public.users`

---

## 🚨 Problème Identifié

L'erreur dans les logs Supabase :
```
ERROR: relation "public.profiles" does not exist (SQLSTATE 42P01)
```

**Cause :**
- Il existe un trigger `on_auth_user_created` sur `auth.users`
- Ce trigger appelle `handle_new_user()` qui essaie d'insérer dans `public.profiles`
- Mais notre schéma utilise `public.users`, pas `public.profiles`

---

## ✅ Solution Appliquée

### Migration créée : `fix_handle_new_user_trigger`

**Ce qui a été fait :**
1. ✅ Suppression de l'ancien trigger
2. ✅ Recréation de la fonction `handle_new_user()` pour utiliser `public.users`
3. ✅ Recréation du trigger `on_auth_user_created`

**La fonction maintenant :**
- Insère dans `public.users` (au lieu de `public.profiles`)
- Utilise `ON CONFLICT DO NOTHING` pour éviter les erreurs si l'utilisateur existe déjà
- Est sécurisée avec `SECURITY DEFINER` et `search_path` fixé

---

## 🧪 Test

**Après application de la migration :**

1. **Relancer l'app Flutter** (hot restart : `R`)
2. **Créer un nouveau compte** avec :
   - Email : `test@manounou.com` (ou autre)
   - Mot de passe : `test123456`
3. **Vérifier** que l'inscription fonctionne
4. **Vérifier** dans Supabase Dashboard → Authentication → Users qu'un utilisateur a été créé
5. **Vérifier** dans Supabase Dashboard → Table Editor → users qu'une entrée a été créée dans `public.users`

---

## 📋 Vérification

### Vérifier que le trigger existe

```sql
SELECT 
  trigger_name,
  event_manipulation,
  event_object_table
FROM information_schema.triggers
WHERE event_object_schema = 'auth'
  AND event_object_table = 'users';
```

**Devrait retourner :** `on_auth_user_created`

### Vérifier la fonction

```sql
SELECT 
  proname,
  pg_get_functiondef(oid) as definition
FROM pg_proc
WHERE proname = 'handle_new_user';
```

**Devrait montrer :** La fonction insère dans `public.users`

---

## 🔍 Si le Problème Persiste

### Vérifier les logs Supabase

1. Dashboard → **Logs** → **Auth**
2. Chercher les erreurs récentes
3. Vérifier si d'autres erreurs apparaissent

### Vérifier les permissions

```sql
-- Vérifier que la fonction a les bonnes permissions
SELECT 
  proname,
  prosecdef,
  proconfig
FROM pg_proc
WHERE proname = 'handle_new_user';
```

### Vérifier la table users

```sql
-- Vérifier que la table users existe et est accessible
SELECT * FROM public.users LIMIT 1;
```

---

## 📚 Documentation

- **Schéma Supabase** : `/data/schema.sql`
- **Fix SQL** : `/data/fix_auth_trigger.sql`
- **Troubleshooting Auth** : `/docs/AUTH_TROUBLESHOOTING.md`

---

**Document maintenu par :** MultiApp Builder Team  
**Dernière mise à jour :** 2025-01-13


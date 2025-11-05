# 🔧 Fix — Autoriser les PDF dans Storage Documents

## 🎯 Problème
Le bucket "documents" n'autorise pas les fichiers PDF (seulement les images fonctionnent).

## ✅ Solution

### Option 1 : Via SQL Editor (Recommandé)

1. **Aller dans Supabase Dashboard** → **SQL Editor**
2. **Copier-coller ce script** :

```sql
-- Supprimer toutes les restrictions MIME types
UPDATE storage.buckets
SET 
  allowed_mime_types = NULL,
  public = true,
  file_size_limit = 52428800
WHERE id = 'documents';
```

3. **Exécuter le script** (bouton "Run" ou `Cmd/Ctrl + Enter`)
4. **Vérifier** : Le message devrait indiquer "Success. No rows returned" ou "Success. 1 row affected"

### Option 2 : Via Dashboard Storage

1. **Aller dans Storage** → **Buckets** → **"documents"**
2. **Cliquer sur "Edit"** (ou "Settings")
3. **Dans "Allowed MIME types"** :
   - **Soit** : Supprimer tous les types listés (laisser vide)
   - **Soit** : Cliquer sur "Clear" ou effacer manuellement
4. **Sauvegarder**

**Note** : Si le champ est vide ou `NULL`, tous les types MIME sont autorisés (PDF, images, etc.)

---

## 🧪 Vérification

Après l'exécution, tester l'upload d'un PDF :
1. Aller dans l'app → **Documents**
2. Cliquer sur **"+"** (FAB)
3. Sélectionner un **PDF**
4. Uploader

**Si ça fonctionne** : ✅ Le problème est résolu !

**Si ça ne fonctionne pas** :
- Vérifier que le script SQL s'est bien exécuté
- Vérifier dans Storage → Buckets → "documents" → Settings que "Allowed MIME types" est vide ou `NULL`
- Vérifier les logs de la console pour d'autres erreurs

---

## 📚 Explication

Dans Supabase Storage, quand `allowed_mime_types` est `NULL` ou vide, **tous les types de fichiers** sont autorisés. C'est la solution la plus simple pour permettre PDF, images, et autres documents.

**Alternative** : Si tu veux spécifier uniquement certains types, tu peux ajouter `'application/pdf'` à la liste, mais mettre `NULL` est plus simple et flexible.


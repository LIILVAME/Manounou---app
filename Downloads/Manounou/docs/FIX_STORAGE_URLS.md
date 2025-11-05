# 🔧 Fix Storage URLs — Manounou

**Date :** 2025-01-13  
**Problème :** 400 Bad Request lors de l'accès aux photos  
**Cause :** Bucket privé avec URL publique

---

## 🐛 Problème

L'erreur `400 (Bad Request)` se produit lors de l'accès aux photos car :
- Le bucket `children-photos` est configuré comme **privé** (`public: false`)
- Le code utilise `getPublicUrl()` qui génère une URL publique
- Les URLs publiques ne fonctionnent pas pour les buckets privés

---

## ✅ Solution

### Option 1 : Rendre le bucket public (simple mais moins sécurisé)

**Migration SQL :**
```sql
UPDATE storage.buckets
SET public = true
WHERE name = 'children-photos';
```

**Avantages :**
- ✅ URLs simples et permanentes
- ✅ Pas besoin de régénérer les URLs

**Inconvénients :**
- ⚠️ Photos accessibles publiquement si l'URL est connue
- ⚠️ Moins sécurisé (mais acceptable si les URLs sont longues et aléatoires)

---

### Option 2 : Utiliser des URLs signées (recommandé)

**Code modifié :**
```dart
// Au lieu de getPublicUrl()
final photoUrl = await _supabase.storage
    .from('children-photos')
    .createSignedUrl(storagePath, 3600); // 1 heure de validité
```

**Avantages :**
- ✅ Plus sécurisé
- ✅ Contrôle d'accès via authentification

**Inconvénients :**
- ⚠️ URLs expirées après la durée de validité
- ⚠️ Nécessite de régénérer les URLs périodiquement

---

## 🎯 Recommandation

Pour **Manounou**, je recommande **Option 1** (bucket public) car :
1. Les URLs sont longues et aléatoires (difficile à deviner)
2. Les photos sont liées à des enfants spécifiques
3. Les policies RLS garantissent que seuls les parents peuvent uploader
4. Plus simple à maintenir (pas de régénération d'URLs)

Si sécurité maximale requise → Option 2 avec système de régénération d'URLs.

---

## 📋 Implémentation

### Option 1 : Rendre le bucket public

1. Exécuter la migration SQL ci-dessus
2. Le code actuel avec `getPublicUrl()` fonctionnera

### Option 2 : URLs signées

1. Modifier `uploadChildPhoto()` pour utiliser `createSignedUrl()`
2. Stocker le `storagePath` dans la DB au lieu de l'URL complète
3. Régénérer les URLs signées lors du chargement
4. Gérer l'expiration des URLs

---

**Document maintenu par :** MultiApp Builder Team  
**Dernière mise à jour :** 2025-01-13


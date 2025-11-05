# ✅ Upload Photos — Manounou (Complet)

**Date :** 2025-01-13  
**Phase :** Phase 1 — Améliorations  
**Status :** ✅ Upload Photos Implémenté

---

## 🎯 Ce qui a été implémenté

### ✅ Base de Données

**Migration :** `add_photo_url_to_children`
- ✅ Colonne `photo_url` ajoutée à la table `children`

**Fichier :** `/data/schema.sql` (à mettre à jour pour inclure photo_url)

---

### ✅ Storage Supabase

**Bucket :** `children-photos`
- ✅ Créé et configuré
- ✅ Privé (non public)
- ✅ Limite : 5MB par photo
- ✅ Types autorisés : JPEG, PNG, HEIC, WebP

**Policies RLS :**
- ✅ Upload : Utilisateurs authentifiés peuvent uploader pour leurs enfants
- ✅ Read : Utilisateurs authentifiés peuvent lire leurs photos
- ✅ Delete : Utilisateurs authentifiés peuvent supprimer leurs photos
- ✅ Update : Utilisateurs authentifiés peuvent mettre à jour leurs photos

**Structure :** `children-photos/{user_id}/{child_id}/{filename}`

**Fichier :** `/data/storage_children_photos.sql`

---

### ✅ Service ChildrenService

**Fonctionnalités ajoutées :**
- ✅ `uploadChildPhoto()` — Upload photo vers Supabase Storage
- ✅ `createChild()` — Support photo lors création
- ✅ `updateChild()` — Support photo lors mise à jour
- ✅ `deletePhoto` — Option pour supprimer photo

**Modèle Child :**
- ✅ Champ `photoUrl` ajouté
- ✅ Sérialisation/désérialisation JSON

---

### ✅ Widget ChildAvatar

**Fichier :** `/flutterflow_export/lib/core/widgets/child_avatar.dart`

**Fonctionnalités :**
- ✅ Affiche photo si disponible
- ✅ Fallback vers initiale du prénom
- ✅ Gestion erreurs de chargement
- ✅ Couleurs pastels automatiques

**Usage :**
```dart
ChildAvatar(
  firstName: 'Emma',
  photoUrl: child.photoUrl,
  radius: 30,
)
```

---

### ✅ Page ChildFormPage

**Fonctionnalités ajoutées :**
- ✅ Sélecteur de photo (camera ou galerie)
- ✅ Aperçu de la photo sélectionnée
- ✅ Bouton "Ajouter/Changer la photo"
- ✅ Option "Supprimer la photo"
- ✅ Upload automatique lors sauvegarde
- ✅ Affichage photo existante en mode édition

**Interface :**
- Avatar cliquable avec icône caméra
- Bottom sheet pour choisir source
- Preview de la photo sélectionnée

---

### ✅ Pages d'Affichage

**ChildrenListPage :**
- ✅ Utilise `ChildAvatar` avec photo
- ✅ Affiche photo si disponible

**ChildDetailPage :**
- ✅ Utilise `ChildAvatar` avec photo
- ✅ Affiche photo si disponible

---

## 📋 Workflow Upload Photo

### Création d'enfant avec photo

1. **Utilisateur** remplit le formulaire
2. **Utilisateur** clique sur avatar → sélectionne photo
3. **Photo** stockée temporairement dans `_selectedPhoto`
4. **Utilisateur** clique sur "Ajouter"
5. **Service** crée l'enfant dans DB
6. **Service** upload photo vers Supabase Storage
7. **Service** met à jour `photo_url` dans DB
8. **Photo** affichée dans liste et détails

### Modification photo

1. **Utilisateur** va sur détails enfant
2. **Utilisateur** clique "Modifier"
3. **Formulaire** affiche photo existante
4. **Utilisateur** peut :
   - Changer la photo (camera/galerie)
   - Supprimer la photo
   - Garder la photo actuelle
5. **Service** met à jour selon action

---

## 🔐 Sécurité

### Storage Policies
- ✅ Isolation par utilisateur (`user_id` dans le path)
- ✅ Isolation par enfant (`child_id` dans le path)
- ✅ Seuls les utilisateurs authentifiés peuvent accéder
- ✅ Chaque utilisateur ne peut accéder qu'à ses propres photos

### Validation
- ✅ Taille max : 5MB
- ✅ Types autorisés : JPEG, PNG, HEIC, WebP
- ✅ Compression : 85% qualité, max 800x800px

---

## 🧪 Tests à effectuer

### Upload
- [ ] Prendre une photo avec camera
- [ ] Choisir photo depuis galerie
- [ ] Vérifier que la photo s'affiche dans la liste
- [ ] Vérifier que la photo s'affiche dans les détails

### Modification
- [ ] Modifier un enfant existant
- [ ] Changer la photo
- [ ] Supprimer la photo
- [ ] Vérifier que les changements sont sauvegardés

### Erreurs
- [ ] Tester avec photo trop grande (>5MB)
- [ ] Tester avec format non supporté
- [ ] Vérifier messages d'erreur clairs

### Sécurité
- [ ] Créer photo avec compte A
- [ ] Se connecter avec compte B
- [ ] Vérifier que la photo A n'est pas visible pour B

---

## 📚 Fichiers Modifiés

### Base de données
- ✅ Migration `add_photo_url_to_children`
- ✅ Migration `create_children_photos_bucket`
- ✅ Migration `create_storage_policies_children_photos_v2`
- ✅ `/data/storage_children_photos.sql`

### Code
- ✅ `/flutterflow_export/lib/core/services/children_service.dart`
- ✅ `/flutterflow_export/lib/core/widgets/child_avatar.dart`
- ✅ `/flutterflow_export/lib/pages/children/child_form_page.dart`
- ✅ `/flutterflow_export/lib/pages/children/children_list_page.dart`
- ✅ `/flutterflow_export/lib/pages/children/child_detail_page.dart`

### Dépendances
- ✅ `cached_network_image` ajouté
- ✅ `image_picker` déjà présent

---

## 🐛 Dépannage

### Photo ne s'affiche pas
**Vérifier :**
1. URL de la photo dans la DB
2. Policies Storage RLS
3. Bucket existe et est accessible
4. Permissions Supabase Storage

### Upload échoue
**Vérifier :**
1. Taille du fichier (<5MB)
2. Format du fichier (JPEG, PNG, HEIC, WebP)
3. Connexion internet
4. Logs Supabase Storage

### Photo ne s'upload pas
**Vérifier :**
1. Utilisateur authentifié
2. Policies Storage correctes
3. Path storage correct (`user_id/child_id/filename`)
4. Logs d'erreur dans console

---

## ✅ Checklist

- [x] Colonne `photo_url` ajoutée à `children`
- [x] Bucket `children-photos` créé
- [x] Policies Storage configurées
- [x] Service `uploadChildPhoto()` implémenté
- [x] Widget `ChildAvatar` créé
- [x] Upload photo dans formulaire
- [x] Affichage photo dans liste
- [x] Affichage photo dans détails
- [ ] Tests fonctionnels (à faire manuellement)

---

**Document maintenu par :** MultiApp Builder Team  
**Dernière mise à jour :** 2025-01-13


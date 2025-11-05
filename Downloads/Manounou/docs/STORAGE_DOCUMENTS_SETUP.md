# 📁 Configuration Storage Documents — Manounou

## 🎯 Objectif
Configurer le bucket Supabase Storage "documents" pour permettre l'upload de fichiers (PDF, images, etc.) liés aux enfants.

---

## 📋 Étapes

### 1. Créer le bucket "documents"

Dans Supabase Dashboard :
1. Aller dans **Storage** → **Buckets**
2. Cliquer sur **"New bucket"**
3. Remplir :
   - **Name:** `documents`
   - **Public bucket:** ✅ Activé (pour accès direct)
   - **File size limit:** 50 MB (optionnel)
4. Cliquer sur **"Create bucket"**

**OU** exécuter le script SQL :

```sql
INSERT INTO storage.buckets (id, name, public)
VALUES ('documents', 'documents', true)
ON CONFLICT (id) DO NOTHING;
```

---

### 2. Appliquer les RLS Policies

Exécuter le script complet `data/storage_documents.sql` dans l'éditeur SQL de Supabase :

1. Ouvrir **SQL Editor** dans Supabase Dashboard
2. Copier le contenu de `data/storage_documents.sql`
3. Exécuter le script

**Structure des chemins :**
- Format : `{child_id}/{timestamp}.{extension}`
- Exemple : `2336fc0a-96ab-4b43-9675-1175c5f8a6a3/1762288268620.png`

**Policies créées :**
- ✅ `Parents can upload documents` — Upload pour les enfants du parent
- ✅ `Parents can view documents` — Lecture (publique car bucket public)
- ✅ `Parents can update documents` — Mise à jour
- ✅ `Parents can delete documents` — Suppression

---

### 3. Vérifier la configuration

Tester l'upload depuis l'application :
1. Aller dans **Documents**
2. Cliquer sur **"+"** (FAB)
3. Sélectionner un enfant, type, et fichier
4. Cliquer sur **"Enregistrer"**

**Si erreur 403 :**
- Vérifier que le bucket "documents" existe
- Vérifier que les policies sont bien créées
- Vérifier que l'utilisateur est authentifié
- Vérifier que l'enfant appartient bien à l'utilisateur

---

## 🔍 Troubleshooting

### Erreur : "new row violates row-level security policy"

**Cause :** Les policies RLS ne sont pas correctement configurées ou le bucket n'existe pas.

**Solution :**
1. Vérifier que le bucket "documents" existe dans Storage
2. Vérifier que les policies sont créées (Storage → Policies)
3. Réexécuter le script `storage_documents.sql`

### Erreur : "400 (Bad Request)"

**Cause :** Le bucket n'existe pas ou le format de chemin est incorrect.

**Solution :**
1. Créer le bucket "documents" dans Storage
2. Vérifier que le format du chemin est `{child_id}/{filename}`

---

## 📚 Structure des fichiers

```
documents/
  └── {child_id}/
      ├── {timestamp}.png
      ├── {timestamp}.jpg
      └── {timestamp}.pdf
```

---

**Voir aussi :**
- `/data/storage_documents.sql` — Script SQL complet
- `/docs/STORAGE_SETUP.md` — Configuration générale Storage


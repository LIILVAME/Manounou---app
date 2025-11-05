# 📦 Data — Manounou

**Dossier :** `/data`  
**Contenu :** Schéma Supabase, migrations, scripts SQL

---

## 📄 Fichiers

- **[schema.sql](./schema.sql)** — Schéma complet de la base de données (tables, index, triggers)
- **[README.md](./README.md)** — Ce fichier

---

## 🗂️ Structure de la Base de Données

### Tables

| Table | Description | Relations |
|:------|:------------|:----------|
| `users` | Utilisateurs parents/nounous | Auth Supabase (`id = auth.uid()`) |
| `children` | Enfants liés à un parent | `parent_id → users.id` |
| `events` | Événements familiaux | `child_id → children.id` |
| `documents` | Fichiers liés à un enfant | `child_id → children.id` |

### Schéma SQL

```sql
-- Users
CREATE TABLE public.users (
  id UUID PRIMARY KEY DEFAULT auth.uid(),
  email TEXT UNIQUE NOT NULL,
  name TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Children
CREATE TABLE public.children (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  parent_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  first_name TEXT NOT NULL,
  birth_date DATE,
  info TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Events
CREATE TABLE public.events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  child_id UUID REFERENCES children(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  start_date TIMESTAMPTZ NOT NULL,
  end_date TIMESTAMPTZ,
  conflict BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Documents
CREATE TABLE public.documents (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  child_id UUID REFERENCES children(id) ON DELETE CASCADE,
  file_name TEXT NOT NULL,
  file_url TEXT,
  type TEXT,
  uploaded_at TIMESTAMPTZ DEFAULT NOW()
);
```

---

## 🔐 Sécurité

- **RLS activé** sur toutes les tables
- **Policies** définies dans `/security/policies.sql`
- **Isolation stricte** : chaque utilisateur ne voit que ses propres données

---

## 📊 Index

- `idx_children_parent_id` — Recherche enfants par parent
- `idx_events_child_id` — Recherche événements par enfant
- `idx_events_start_date` — Tri/filtrage par date
- `idx_documents_child_id` — Recherche documents par enfant

---

## ⚙️ Fonctions & Triggers

### Fonction `update_updated_at_column()`
Mise à jour automatique du champ `updated_at` lors des modifications.

**Triggers associés :**
- `update_users_updated_at` — Table `users`
- `update_children_updated_at` — Table `children`
- `update_events_updated_at` — Table `events`

---

## 🚀 Utilisation

### Appliquer le schéma dans Supabase

1. **Via SQL Editor Supabase :**
   - Ouvrir l'éditeur SQL dans le dashboard Supabase
   - Copier le contenu de `schema.sql`
   - Exécuter le script

2. **Via MCP Supabase :**
   ```bash
   # Migration automatique via MCP
   mcp_supabase_apply_migration create_manounou_schema
   ```

3. **Via Supabase CLI :**
   ```bash
   supabase db reset
   supabase migration up
   ```

---

## 📝 Notes

- **Cascade deletes** : Suppression d'un parent supprime automatiquement ses enfants, événements et documents
- **Timestamps** : `created_at` et `updated_at` gérés automatiquement
- **UUIDs** : Tous les IDs sont des UUIDs pour sécurité et scalabilité

---

**Voir aussi :**
- `/security/policies.sql` — Policies RLS
- `/product/ROADMAP.md` — Roadmap produit


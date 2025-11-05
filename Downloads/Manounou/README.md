
# 🍼 Manounou — Application Familiale (v2.0.0)

**Date de création :** 2025-01-13  
**Stack :** FlutterFlow • Supabase • Firebase Storage (optionnel)  
**Objectif :** Centraliser la vie familiale (enfants, événements, documents) dans une application mobile fluide, sécurisée et bienveillante.  

---

## 🧭 Vision Produit

**Manounou** est un carnet numérique familial qui aide les parents à :
- 👶 Gérer les profils de leurs enfants (âge, santé, infos essentielles)
- 📅 Planifier les événements familiaux dans un calendrier multi-vue (jour, semaine, mois, agenda)
- 🗂️ Stocker et partager des documents importants (autorisations, certificats…)
- 🤝 Coordonner la famille et les proches via un espace unique et sécurisé  

---

## ⚙️ Stack Technique

| Composant | Technologie | Rôle |
|------------|--------------|------|
| **Frontend** | [FlutterFlow](https://flutterflow.io) | Interface mobile iOS/Android sans code |
| **Backend** | [Supabase](https://supabase.com) | Auth, API, base de données PostgreSQL |
| **Auth** | Supabase Auth (Apple, Email, Google) | Gestion sécurisée des utilisateurs |
| **Storage** | Supabase Storage | Stockage des documents familiaux |
| **Realtime** | Supabase Realtime | Synchronisation instantanée des événements |
| **Versioning** | Git (local) | Gestion du code exporté Flutter |

---

## 🗂️ Structure du projet

```

~/Downloads/Manounou/
├── flutterflow_export/           # Code exporté depuis FlutterFlow
│   ├── lib/
│   ├── assets/
│   ├── pubspec.yaml
│   └── README.md
├── /design                       # Maquettes et wireframes
├── /data                         # Schéma Supabase + policies SQL
├── /docs                         # Documentation produit
└── README.md                     # (ce fichier)

````

---

## 🧩 Base de données Supabase

### Tables principales
| Table | Description | Clé / Relation |
|:------|:-------------|:----------------|
| `users` | Utilisateurs (parents, nounous) | Auth Supabase |
| `children` | Enfants liés à un utilisateur | `parent_id → users.id` |
| `events` | Événements familiaux | `child_id → children.id` |
| `documents` | Documents (PDF, images, certificats) | `child_id → children.id` |

---

### Exemple de schéma SQL

```sql
-- USERS
create table users (
  id uuid primary key default auth.uid(),
  email text unique,
  name text,
  created_at timestamp default now()
);

-- CHILDREN
create table children (
  id uuid primary key default gen_random_uuid(),
  parent_id uuid references users(id) on delete cascade,
  first_name text,
  birth_date date,
  info text,
  created_at timestamp default now()
);

-- EVENTS
create table events (
  id uuid primary key default gen_random_uuid(),
  child_id uuid references children(id) on delete cascade,
  title text,
  start_date timestamptz,
  end_date timestamptz,
  conflict boolean default false,
  created_at timestamp default now()
);

-- DOCUMENTS
create table documents (
  id uuid primary key default gen_random_uuid(),
  child_id uuid references children(id) on delete cascade,
  file_name text,
  file_url text,
  type text,
  uploaded_at timestamp default now()
);
````

---

## 🔐 Sécurité (RLS & Policies)

```sql
-- Activer la Row Level Security
alter table users enable row level security;
alter table children enable row level security;
alter table events enable row level security;
alter table documents enable row level security;

-- USERS : accès à ses propres données
create policy "Users can access their own profile"
on users for all using (auth.uid() = id);

-- CHILDREN : accès restreint aux parents
create policy "Parent can access their children"
on children for all using (auth.uid() = parent_id);

-- EVENTS : accès restreint via l’enfant
create policy "Parent can access their events"
on events for all
using (auth.uid() in (select parent_id from children where id = events.child_id));

-- DOCUMENTS : accès restreint via l’enfant
create policy "Parent can access their documents"
on documents for all
using (auth.uid() in (select parent_id from children where id = documents.child_id));
```

---

## 🧱 Pages principales (FlutterFlow)

| Page               | Fonction                                        | Type          |
| :----------------- | :---------------------------------------------- | :------------ |
| 🏠 `DashboardPage` | Vue d’ensemble : compteurs enfants + événements | Accueil       |
| 👶 `ChildrenPage`  | Liste et fiches enfants                         | Gestion       |
| 📅 `EventsPage`    | Calendrier multi-vue                            | Planification |
| 📁 `DocumentsPage` | Upload et gestion de documents                  | Organisation  |
| 👤 `ProfilePage`   | Informations utilisateur, préférences           | Profil        |

---

## 🎨 Design Guideline

* **Palette** : tons pastels (beige, bleu clair, lavande)
* **Typo** : SF Rounded / Nunito
* **Style** : rassurant, fluide, familial
* **Composants UI** : cartes arrondies, icônes lisibles, boutons clairs

---

## 🚀 Déploiement

### 🔧 Étapes FlutterFlow

1. Créer un projet “**Manounou**” sur [flutterflow.io](https://flutterflow.io)
2. Connecter l’instance **Supabase** (URL + clé anonyme)
3. Importer les tables `users`, `children`, `events`, `documents`
4. Configurer l’auth Apple/Email
5. Lancer le mode “Run” ou exporter le projet Flutter

### 🧑‍💻 Étapes Supabase

1. Créer une nouvelle instance sur [supabase.com](https://supabase.com)
2. Exécuter le script SQL ci-dessus
3. Activer RLS et les policies
4. Créer un bucket “documents” dans **Storage**
5. Tester les règles d’accès utilisateur

---

## 🧠 Auteurs & Crédits

**MultiApp Builder Team**
*Produit, Design, Data & Sécurité IA – orchestrés pour Manounou*

© 2025 – Tous droits réservés à **Manounou App** 🍼

```

---


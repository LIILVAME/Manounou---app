# 🚀 Guide FlutterFlow — Manounou (Complet)

**Date :** 2025-01-13  
**Phase :** Phase 1 — Semaine 1  
**Status :** Prêt pour configuration FlutterFlow

---

## 📋 Prérequis Vérifiés ✅

- ✅ Instance Supabase créée et configurée
- ✅ Schéma de base de données créé (4 tables)
- ✅ RLS activé et policies configurées
- ✅ Bucket Storage "documents" créé
- ✅ Credentials Supabase récupérés

---

## 🔑 Credentials Supabase

### Pour FlutterFlow
**URL Supabase :**
```
https://emgrtgencepzainsknsb.supabase.co
```

**Anon Key :**
```
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVtZ3J0Z2VuY2VwemFpbnNrbnNiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTUxNjU3MzcsImV4cCI6MjA3MDc0MTczN30.2TtED_BEXHf6UqgPPcuOOd5YYTZlyqLSZRMoZtO93yM
```

---

## 🎯 Étape 1 : Créer le Projet FlutterFlow

### 1.1 Créer un compte
1. Aller sur [flutterflow.io](https://flutterflow.io)
2. Cliquer sur **"Sign Up"** ou **"Get Started"**
3. Créer un compte (Google, Apple, ou Email)

### 1.2 Créer le projet
1. Dans le dashboard, cliquer sur **"Create New Project"**
2. **Nom du projet :** `Manounou`
3. **Type :** Mobile App (iOS + Android)
4. **Template :** "Blank App" (recommandé pour commencer proprement)
5. Cliquer sur **"Create"**

**✅ Résultat attendu :** Projet FlutterFlow créé avec une page vide

---

## 🎯 Étape 2 : Connecter Supabase

### 2.1 Accéder aux intégrations
1. Dans FlutterFlow, cliquer sur **Settings** (icône engrenage en bas à gauche)
2. Aller dans l'onglet **"Integrations"**
3. Chercher **"Supabase"** dans la liste des intégrations disponibles

### 2.2 Configurer Supabase
1. Cliquer sur **"Connect"** ou **"Add Integration"** à côté de Supabase
2. Remplir les champs :
   - **Supabase URL** : 
     ```
     https://emgrtgencepzainsknsb.supabase.co
     ```
   - **Supabase Anon Key** : 
     ```
     eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVtZ3J0Z2VuY2VwemFpbnNrbnNiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTUxNjU3MzcsImV4cCI6MjA3MDc0MTczN30.2TtED_BEXHf6UqgPPcuOOd5YYTZlyqLSZRMoZtO93yM
     ```
3. Cliquer sur **"Test Connection"**
4. Si succès (message vert) → Cliquer sur **"Save"**

**✅ Résultat attendu :** Supabase connecté, message de confirmation vert

**⚠️ Si erreur :**
- Vérifier que l'URL et la clé sont correctement copiées
- Vérifier que le projet Supabase est actif
- Réessayer après quelques secondes

---

## 🎯 Étape 3 : Importer les Tables Supabase

### 3.1 Accéder aux données Supabase
1. Dans FlutterFlow, cliquer sur **"Data"** dans le menu de gauche
2. Cliquer sur l'onglet **"Supabase"**
3. Tu devrais voir un bouton **"Import Tables"** ou **"Sync Tables"**

### 3.2 Importer les tables
1. Cliquer sur **"Import Tables"** ou **"Sync Tables"**
2. FlutterFlow va scanner ta base Supabase
3. Sélectionner les 4 tables suivantes :
   - ✅ `users`
   - ✅ `children`
   - ✅ `events`
   - ✅ `documents`
4. Cliquer sur **"Import"** ou **"Sync"**

**✅ Résultat attendu :** Les 4 tables apparaissent dans **Data → Supabase Tables**

### 3.3 Vérifier les colonnes
Pour chaque table, vérifier que les colonnes sont correctement mappées :

**Table `users` :**
- `id` (UUID, Primary Key)
- `email` (Text, Unique)
- `name` (Text, Nullable)
- `created_at` (Timestamp)
- `updated_at` (Timestamp)

**Table `children` :**
- `id` (UUID, Primary Key)
- `parent_id` (UUID, Foreign Key → users.id)
- `first_name` (Text)
- `birth_date` (Date, Nullable)
- `info` (Text, Nullable)
- `created_at` (Timestamp)
- `updated_at` (Timestamp)

**Table `events` :**
- `id` (UUID, Primary Key)
- `child_id` (UUID, Foreign Key → children.id, Nullable)
- `title` (Text)
- `start_date` (Timestamp)
- `end_date` (Timestamp, Nullable)
- `conflict` (Boolean, Default: false)
- `created_at` (Timestamp)
- `updated_at` (Timestamp)

**Table `documents` :**
- `id` (UUID, Primary Key)
- `child_id` (UUID, Foreign Key → children.id)
- `file_name` (Text)
- `file_url` (Text, Nullable)
- `type` (Text, Nullable)
- `uploaded_at` (Timestamp)

---

## 🎯 Étape 4 : Configurer Authentication

### 4.1 Activer Supabase Auth
1. Dans FlutterFlow, aller dans **Settings → Authentication**
2. Activer **"Supabase Auth"**
3. Les méthodes d'authentification disponibles apparaissent

### 4.2 Configurer Email/Password
1. Activer **"Email/Password"**
2. Vérifier les options :
   - ✅ Allow Sign Up
   - ✅ Email Verification (optionnel pour MVP)

### 4.3 Configurer Apple Sign In (si disponible)
1. Activer **"Apple Sign In"**
2. Si configuration requise, suivre les instructions FlutterFlow
3. **Note :** Pour iOS, Apple Sign In nécessite une configuration Apple Developer

---

## 🎯 Étape 5 : Créer les Pages de Base

### 5.1 Structure des pages

Créer les pages suivantes dans FlutterFlow :

1. **LoginPage** (Page d'authentification)
2. **RegisterPage** (Page d'inscription)
3. **OnboardingPage** (Page de bienvenue)
4. **DashboardPage** (Tableau de bord)
5. **ChildrenListPage** (Liste des enfants)
6. **ChildFormPage** (Formulaire enfant)
7. **ChildDetailPage** (Détails enfant)
8. **EventsPage** (Calendrier)
9. **DocumentsPage** (Documents)
10. **ProfilePage** (Profil utilisateur)

### 5.2 Créer une page

1. Dans FlutterFlow, cliquer sur **"Pages"** dans le menu de gauche
2. Cliquer sur **"+"** pour créer une nouvelle page
3. **Nom de la page :** `LoginPage`
4. **Type :** Full Page
5. Cliquer sur **"Create"**

**Répéter pour toutes les pages listées ci-dessus.**

---

## 🎯 Étape 6 : Configurer la Navigation

### 6.1 Navigation Bottom Bar

1. Créer ou modifier la page principale (ex: `DashboardPage`)
2. Ajouter un **Bottom Navigation Bar** :
   - Dans les composants, chercher **"Bottom Navigation Bar"**
   - Glisser-déposer sur la page
3. Configurer les 5 onglets :
   - **Dashboard** → `DashboardPage`
   - **Enfants** → `ChildrenListPage`
   - **Calendrier** → `EventsPage`
   - **Documents** → `DocumentsPage`
   - **Profil** → `ProfilePage`

### 6.2 Navigation entre pages

Pour créer des liens entre pages :
1. Sélectionner un bouton ou un élément cliquable
2. Dans les propriétés, trouver **"Actions"**
3. Ajouter une action **"Navigate to Page"**
4. Sélectionner la page de destination

---

## 🎯 Étape 7 : Créer les Workflows Authentication

### 7.1 Workflow "Sign Up"

**Page :** `RegisterPage`  
**Trigger :** Bouton "S'inscrire"

1. Sélectionner le bouton "S'inscrire"
2. Dans **Actions**, ajouter :
   - **Action :** "Supabase → Create Account"
   - **Email :** Variable depuis champ email
   - **Password :** Variable depuis champ password
3. **Si succès :** Navigate to `OnboardingPage`
4. **Si erreur :** Afficher message d'erreur

### 7.2 Workflow "Sign In"

**Page :** `LoginPage`  
**Trigger :** Bouton "Se connecter"

1. Sélectionner le bouton "Se connecter"
2. Dans **Actions**, ajouter :
   - **Action :** "Supabase → Sign In"
   - **Email :** Variable depuis champ email
   - **Password :** Variable depuis champ password
3. **Si succès :** Navigate to `DashboardPage`
4. **Si erreur :** Afficher message d'erreur

### 7.3 Workflow "Sign Out"

**Page :** `ProfilePage`  
**Trigger :** Bouton "Déconnexion"

1. Sélectionner le bouton "Déconnexion"
2. Dans **Actions**, ajouter :
   - **Action :** "Supabase → Sign Out"
3. **Après action :** Navigate to `LoginPage`

---

## 🎯 Étape 8 : Créer les Workflows CRUD Children

### 8.1 Workflow "Create Child"

**Page :** `ChildFormPage`  
**Trigger :** Bouton "Enregistrer"

1. Sélectionner le bouton "Enregistrer"
2. Dans **Actions**, ajouter :
   - **Action :** "Supabase → Insert Row"
   - **Table :** `children`
   - **Fields :**
     - `parent_id` : `auth.uid()` (ID utilisateur connecté)
     - `first_name` : Variable depuis champ
     - `birth_date` : Variable depuis champ
     - `info` : Variable depuis champ (optionnel)
3. **Si succès :** Navigate to `ChildrenListPage`
4. **Si erreur :** Afficher message d'erreur

### 8.2 Workflow "Read Children"

**Page :** `ChildrenListPage`  
**Trigger :** Page Load

1. Dans **Page Settings → Page Load Actions**
2. Ajouter :
   - **Action :** "Supabase → Query Rows"
   - **Table :** `children`
   - **Filter :** `parent_id = auth.uid()`
3. **Store result in :** Variable `childrenList`

### 8.3 Workflow "Update Child"

**Page :** `ChildFormPage` (mode édition)  
**Trigger :** Bouton "Enregistrer"

1. Sélectionner le bouton "Enregistrer"
2. Dans **Actions**, ajouter :
   - **Action :** "Supabase → Update Row"
   - **Table :** `children`
   - **Filter :** `id = [child_id]` (ID depuis paramètre page)
   - **Fields :** Mettre à jour les champs modifiés
3. **Si succès :** Navigate back ou to `ChildDetailPage`

### 8.4 Workflow "Delete Child"

**Page :** `ChildDetailPage`  
**Trigger :** Bouton "Supprimer"

1. Sélectionner le bouton "Supprimer"
2. Ajouter confirmation dialog
3. Dans **Actions**, ajouter :
   - **Action :** "Supabase → Delete Row"
   - **Table :** `children`
   - **Filter :** `id = [child_id]`
4. **Si succès :** Navigate to `ChildrenListPage`

---

## ✅ Checklist FlutterFlow

### Setup
- [ ] Projet FlutterFlow créé
- [ ] Supabase connecté (URL + Anon Key)
- [ ] Connexion testée avec succès
- [ ] 4 tables importées (users, children, events, documents)
- [ ] Colonnes vérifiées pour chaque table

### Authentication
- [ ] Supabase Auth activé
- [ ] Email/Password activé
- [ ] Apple Sign In activé (si disponible)
- [ ] Workflow Sign Up créé
- [ ] Workflow Sign In créé
- [ ] Workflow Sign Out créé

### Pages
- [ ] LoginPage créée
- [ ] RegisterPage créée
- [ ] OnboardingPage créée
- [ ] DashboardPage créée
- [ ] ChildrenListPage créée
- [ ] ChildFormPage créée
- [ ] ChildDetailPage créée
- [ ] EventsPage créée
- [ ] DocumentsPage créée
- [ ] ProfilePage créée

### Navigation
- [ ] Bottom Navigation Bar configurée
- [ ] 5 onglets configurés
- [ ] Navigation entre pages fonctionnelle

### Workflows CRUD
- [ ] Create Child workflow
- [ ] Read Children workflow
- [ ] Update Child workflow
- [ ] Delete Child workflow

---

## 🐛 Dépannage

### Problème : Connexion Supabase échoue
- **Vérifier** : URL et Anon Key correctement copiés (sans espaces)
- **Vérifier** : Projet Supabase actif dans le dashboard
- **Solution** : Réessayer après quelques secondes

### Problème : Tables non importées
- **Vérifier** : Tables existent dans Supabase
- **Vérifier** : RLS activé (peut bloquer l'import)
- **Solution** : Importer manuellement table par table

### Problème : Relations non détectées
- **Vérifier** : Foreign keys définies dans Supabase
- **Solution** : Créer relations manuellement dans FlutterFlow

### Problème : Workflows ne fonctionnent pas
- **Vérifier** : Variables correctement définies
- **Vérifier** : Types de données correspondent
- **Solution** : Tester chaque action individuellement

---

## 📚 Ressources

- **FlutterFlow Docs** : [docs.flutterflow.io](https://docs.flutterflow.io)
- **Supabase FlutterFlow** : [docs.flutterflow.io/integrations/supabase](https://docs.flutterflow.io/integrations/supabase)
- **Roadmap** : `/product/ROADMAP.md`
- **Checklist Phase 1** : `/product/CHECKLIST_PHASE1.md`
- **Code Flutter de référence** : `/flutterflow_export/`

---

## 🚀 Prochaine Étape

Après avoir complété ce setup :
1. Tester l'authentification (Sign Up, Sign In, Sign Out)
2. Tester la création d'un enfant
3. Vérifier que les données sont isolées par utilisateur (RLS)
4. Continuer avec Semaine 2 de la roadmap

---

**Document maintenu par :** MultiApp Builder Team  
**Dernière mise à jour :** 2025-01-13


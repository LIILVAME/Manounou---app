# 🚀 Setup FlutterFlow — Manounou

**Date :** 2025-01-13  
**Phase :** Phase 1 — Semaine 1  
**Objectif :** Connecter FlutterFlow à Supabase et importer les tables

---

## 📋 Prérequis

- ✅ Instance Supabase créée et configurée
- ✅ Schéma de base de données créé (4 tables)
- ✅ RLS activé et policies configurées
- ✅ Bucket Storage "documents" créé

---

## 🔗 Informations Supabase

### Récupérer les credentials

1. **Aller sur [supabase.com/dashboard](https://supabase.com/dashboard)**
2. **Sélectionner le projet "Manounou"**
3. **Aller dans Settings → API**
4. **Copier les informations suivantes :**
   - **Project URL** : `https://xxxxx.supabase.co`
   - **Anon Key** : `eyJhbGc...` (clé publique)

---

## 🎯 Étapes FlutterFlow

### 1. Créer le projet FlutterFlow

1. Aller sur [flutterflow.io](https://flutterflow.io)
2. Se connecter ou créer un compte
3. Cliquer sur **"Create New Project"**
4. **Nom du projet :** `Manounou`
5. **Type :** Mobile App (iOS + Android)
6. **Sélectionner un template** : "Blank App" (ou template de base)

---

### 2. Connecter Supabase

1. Dans FlutterFlow, aller dans **Settings → Integrations**
2. Chercher **"Supabase"** dans la liste
3. Cliquer sur **"Connect"** ou **"Add Integration"**
4. Remplir les champs :
   - **Supabase URL** : Coller le Project URL
   - **Supabase Anon Key** : Coller l'Anon Key
5. Cliquer sur **"Test Connection"**
6. Si succès → **"Save"**

---

### 3. Importer les tables Supabase

1. Dans FlutterFlow, aller dans **Data → Supabase**
2. Cliquer sur **"Import Tables"** ou **"Sync Tables"**
3. Sélectionner les 4 tables :
   - ✅ `users`
   - ✅ `children`
   - ✅ `events`
   - ✅ `documents`
4. Cliquer sur **"Import"**
5. Vérifier que les tables apparaissent dans **Data → Supabase Tables**

---

### 4. Vérifier les relations

1. Dans **Data → Supabase Tables**
2. Vérifier que les relations sont détectées :
   - `children.parent_id` → `users.id`
   - `events.child_id` → `children.id`
   - `documents.child_id` → `children.id`
3. Si relations manquantes, les créer manuellement dans FlutterFlow

---

### 5. Configurer Authentication

1. Dans FlutterFlow, aller dans **Settings → Authentication**
2. **Activer Supabase Auth**
3. **Méthodes d'authentification :**
   - ✅ Email/Password
   - ✅ Apple Sign In (si disponible)
4. **Configurer les écrans :**
   - Login Screen
   - Register Screen
   - Reset Password Screen (optionnel)

---

## 📱 Structure de Pages (à créer)

### Pages principales (selon roadmap)

1. **LoginPage** — Authentification
2. **RegisterPage** — Inscription
3. **OnboardingPage** — Bienvenue (première connexion)
4. **DashboardPage** — Vue d'ensemble
5. **ChildrenListPage** — Liste des enfants
6. **ChildFormPage** — Création/Modification enfant
7. **ChildDetailPage** — Détails enfant
8. **ProfilePage** — Profil utilisateur

---

## 🔧 Workflows à créer (Phase 1)

### Authentication Workflows

1. **Sign Up** (Email/Password)
   - Action : `Supabase → Create Account`
   - Redirection : `OnboardingPage` ou `DashboardPage`

2. **Sign In** (Email/Password)
   - Action : `Supabase → Sign In`
   - Redirection : `DashboardPage` (si succès)

3. **Sign In with Apple**
   - Action : `Supabase → Sign In with Apple`
   - Redirection : `DashboardPage` (si succès)

4. **Sign Out**
   - Action : `Supabase → Sign Out`
   - Redirection : `LoginPage`

### CRUD Children Workflows

1. **Create Child**
   - Action : `Supabase → Insert Row` (table: `children`)
   - Champs : `parent_id` (auth.uid()), `first_name`, `birth_date`, `info`

2. **Read Children**
   - Action : `Supabase → Query Rows` (table: `children`)
   - Filter : `parent_id = auth.uid()`

3. **Update Child**
   - Action : `Supabase → Update Row` (table: `children`)
   - Filter : `id = [child_id]`

4. **Delete Child**
   - Action : `Supabase → Delete Row` (table: `children`)
   - Filter : `id = [child_id]`

---

## 🎨 Design System (à configurer)

### Couleurs
- **Primaire** : Pastel (ex: #FFB6C1, #B0E0E6)
- **Secondaire** : Complémentaire
- **Accent** : Couleur vive pour CTA

### Typographie
- **Police principale** : SF Rounded (iOS) / Nunito (Android)
- **Tailles** : H1, H2, Body, Caption

### Composants
- Cards arrondies
- Buttons avec ombres douces
- Inputs avec bordures arrondies

---

## ✅ Checklist FlutterFlow Setup

- [ ] Projet FlutterFlow créé
- [ ] Supabase connecté (URL + Anon Key)
- [ ] Connexion testée avec succès
- [ ] 4 tables importées (users, children, events, documents)
- [ ] Relations vérifiées
- [ ] Authentication configurée
- [ ] Email/Password activé
- [ ] Apple Sign In activé (si disponible)
- [ ] Pages principales créées (squelettes)
- [ ] Navigation Bottom Bar configurée

---

## 🐛 Dépannage

### Problème : Connexion Supabase échoue
- **Vérifier** : URL et Anon Key corrects
- **Vérifier** : Projet Supabase actif
- **Vérifier** : Pas de restrictions réseau/firewall

### Problème : Tables non importées
- **Vérifier** : Tables existent dans Supabase
- **Vérifier** : RLS activé (peut bloquer l'import)
- **Solution** : Importer manuellement table par table

### Problème : Relations non détectées
- **Vérifier** : Foreign keys définies dans Supabase
- **Solution** : Créer relations manuellement dans FlutterFlow

---

## 📚 Ressources

- **FlutterFlow Docs** : [docs.flutterflow.io](https://docs.flutterflow.io)
- **Supabase FlutterFlow** : [docs.flutterflow.io/integrations/supabase](https://docs.flutterflow.io/integrations/supabase)
- **Roadmap** : `/product/ROADMAP.md`
- **Checklist Phase 1** : `/product/CHECKLIST_PHASE1.md`

---

## 🚀 Prochaine Étape

Après setup FlutterFlow :
- Créer page `LoginPage` avec formulaire
- Créer workflow "Sign Up" et "Sign In"
- Tester l'authentification

---

**Document maintenu par :** MultiApp Builder Team  
**Dernière mise à jour :** 2025-01-13


# ✅ Checklist Phase 1 — Fondations & MVP Core

**Période :** Semaines 1-4  
**Objectif :** Infrastructure + Auth + Gestion Enfants

---

## 📅 Semaine 1 : Setup & Architecture

### Supabase
- [x] Créer compte Supabase
- [x] Créer projet "manounou-prod"
- [x] Exécuter script SQL complet (`/data/schema.sql`)
  - [x] Table `users`
  - [x] Table `children`
  - [x] Table `events`
  - [x] Table `documents`
- [x] Activer RLS sur toutes les tables
- [x] Créer policies RLS (voir `/security/policies.sql`)
- [ ] Tester policies (isolation données) — À faire manuellement
- [x] Créer bucket Storage "documents"
- [x] Configurer policies Storage (accès authentifié uniquement)
- [x] Récupérer URL API + clé anonyme — ✅ Récupérés via MCP et configurés

### FlutterFlow
- [ ] Créer compte FlutterFlow
- [ ] Créer projet "Manounou"
- [ ] Configurer connexion Supabase
  - [ ] URL API
  - [ ] Clé anonyme
  - [ ] Tester connexion
- [ ] Importer tables Supabase dans FlutterFlow
- [ ] Vérifier mapping colonnes

### Documentation
- [x] Documenter credentials Supabase — ✅ `/docs/SUPABASE_CREDENTIALS.md`
- [ ] Créer fichier `/docs/architecture.md`

---

## 📅 Semaine 2 : Authentification & Onboarding

### Pages FlutterFlow
- [ ] Page `LoginPage`
  - [ ] Champ email
  - [ ] Champ mot de passe
  - [ ] Bouton "Se connecter"
  - [ ] Lien "Créer un compte"
  - [ ] Bouton "Connexion Apple"
- [ ] Page `RegisterPage`
  - [ ] Champ email
  - [ ] Champ mot de passe
  - [ ] Champ confirmation mot de passe
  - [ ] Validation formulaire
  - [ ] Bouton "S'inscrire"
- [ ] Page `OnboardingPage`
  - [ ] Message bienvenue
  - [ ] Illustration/icône
  - [ ] Texte explication app
  - [ ] Bouton "Commencer"

### Workflows Auth
- [ ] Workflow "Sign Up" (email/password)
  - [ ] Création compte Supabase Auth
  - [ ] Gestion erreurs (email existant, mot de passe faible)
  - [ ] Redirection après inscription
- [ ] Workflow "Sign In" (email/password)
  - [ ] Connexion Supabase Auth
  - [ ] Gestion erreurs (mauvais credentials)
  - [ ] Redirection après connexion
- [ ] Workflow "Sign In with Apple"
  - [ ] Configuration Apple (FlutterFlow)
  - [ ] Flow OAuth Apple
  - [ ] Création compte automatique si nouveau
  - [ ] Redirection après connexion
- [ ] Workflow "Sign Out"
  - [ ] Déconnexion Supabase
  - [ ] Redirection vers LoginPage

### State Management
- [ ] Variable globale "CurrentUser"
- [ ] Variable globale "IsAuthenticated"
- [ ] Logique redirection si connecté/non connecté

### Tests
- [ ] Test inscription email/password
- [ ] Test connexion email/password
- [ ] Test connexion Apple
- [ ] Test déconnexion
- [ ] Test session persistante (redémarrage app)

---

## 📅 Semaine 3 : Gestion des Enfants

### Pages FlutterFlow
- [ ] Page `ChildrenListPage`
  - [ ] Liste enfants (ListView/Column)
  - [ ] Card enfant (prénom, photo, âge)
  - [ ] Bouton FAB "Ajouter un enfant"
  - [ ] Swipe-to-delete (optionnel)
  - [ ] Tap sur enfant → navigation `ChildDetailPage`
- [ ] Page `ChildFormPage`
  - [ ] Champ "Prénom" (required)
  - [ ] Champ "Date de naissance" (date picker)
  - [ ] Champ "Notes" (textarea, optionnel)
  - [ ] Upload photo (Supabase Storage)
  - [ ] Bouton "Enregistrer"
  - [ ] Bouton "Annuler"
  - [ ] Mode création vs édition (détection via paramètre)
- [ ] Page `ChildDetailPage`
  - [ ] Affichage informations enfant
  - [ ] Photo enfant
  - [ ] Liste événements (prochains)
  - [ ] Liste documents (récents)
  - [ ] Bouton "Modifier" → navigation `ChildFormPage`
  - [ ] Bouton "Supprimer" (avec confirmation)

### Workflows CRUD
- [ ] Workflow "Create Child"
  - [ ] Validation formulaire
  - [ ] Upload photo (si présente)
  - [ ] Insertion DB Supabase (`children`)
  - [ ] Gestion erreurs
  - [ ] Redirection après création
- [ ] Workflow "Read Children"
  - [ ] Query Supabase (filtré par `parent_id = auth.uid()`)
  - [ ] Affichage liste
  - [ ] Gestion état vide
- [ ] Workflow "Update Child"
  - [ ] Pré-remplissage formulaire
  - [ ] Validation formulaire
  - [ ] Update DB Supabase
  - [ ] Gestion erreurs
  - [ ] Redirection après mise à jour
- [ ] Workflow "Delete Child"
  - [ ] Confirmation utilisateur
  - [ ] Suppression DB Supabase (cascade events/documents)
  - [ ] Suppression photo Storage (si présente)
  - [ ] Gestion erreurs
  - [ ] Redirection après suppression

### Tests
- [ ] Test création enfant (sans photo)
- [ ] Test création enfant (avec photo)
- [ ] Test modification enfant
- [ ] Test suppression enfant
- [ ] Test isolation données (RLS) — créer enfant avec compte A, vérifier invisible avec compte B

---

## 📅 Semaine 4 : Dashboard & Navigation

### Pages FlutterFlow
- [ ] Page `DashboardPage`
  - [ ] Header avec nom utilisateur
  - [ ] Card "Mes enfants" (compteur + liste)
  - [ ] Card "Événements à venir" (7 prochains jours)
  - [ ] Card "Documents récents" (5 derniers)
  - [ ] Boutons navigation vers pages dédiées
- [ ] Page `ProfilePage`
  - [ ] Nom utilisateur
  - [ ] Email
  - [ ] Bouton "Déconnexion"
  - [ ] Section "Paramètres" (squelette)

### Navigation
- [ ] Bottom Navigation Bar
  - [ ] Onglet "Dashboard" (icône maison)
  - [ ] Onglet "Enfants" (icône enfant)
  - [ ] Onglet "Calendrier" (icône calendrier) — placeholder
  - [ ] Onglet "Documents" (icône dossier) — placeholder
  - [ ] Onglet "Profil" (icône utilisateur)
- [ ] Navigation entre pages fonctionnelle
- [ ] State navigation (page active highlightée)

### Design System v1
- [ ] Palette couleurs
  - [ ] Couleur primaire (pastel)
  - [ ] Couleur secondaire
  - [ ] Couleur accent
  - [ ] Couleurs texte (dark/light)
- [ ] Typographie
  - [ ] Police principale (SF Rounded / Nunito)
  - [ ] Tailles texte (h1, h2, body, caption)
- [ ] Composants réutilisables
  - [ ] Card component
  - [ ] Button component
  - [ ] Input component
- [ ] Spacing
  - [ ] Marges standardisées
  - [ ] Padding standardisé

### Tests
- [ ] Test navigation bottom bar
- [ ] Test dashboard affiche données réelles
- [ ] Test déconnexion depuis ProfilePage
- [ ] Test design cohérent sur toutes pages

---

## 🎯 Critères de Validation Phase 1

### Fonctionnel
- ✅ Utilisateur peut s'inscrire et se connecter
- ✅ Utilisateur peut créer/modifier/supprimer enfants
- ✅ Données isolées par utilisateur (RLS)
- ✅ Navigation fluide entre pages principales

### Technique
- ✅ Supabase configuré et sécurisé (RLS)
- ✅ FlutterFlow connecté à Supabase
- ✅ Workflows CRUD fonctionnels
- ✅ Upload photos fonctionnel

### Design
- ✅ Design System de base implémenté
- ✅ Interface cohérente et familiale
- ✅ Navigation intuitive

---

## 📝 Notes

- **Priorité sécurité** : Tester RLS à chaque ajout de feature
- **Performance** : Optimiser queries Supabase (limite résultats si nécessaire)
- **UX** : Messages d'erreur clairs et bienveillants

---

**Prochaine étape après Phase 1 :** Phase 2 — Calendrier & Documents


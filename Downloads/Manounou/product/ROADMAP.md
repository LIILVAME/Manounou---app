# 🗺️ Roadmap Manounou — Application Familiale

**Version :** 1.0.0  
**Période :** 3 mois (Q1 2025)  
**Objectif MVP :** Lancement bêta avec fonctionnalités essentielles  
**Stack :** FlutterFlow + Supabase

---

## 📊 Vue d'ensemble

| Phase | Durée | Objectif | Livrables |
|:------|:------|:----------|:----------|
| **Phase 1** | Mois 1 | Fondations & MVP Core | Auth, DB, Profils enfants |
| **Phase 2** | Mois 2 | Calendrier & Documents | Événements, Upload, Navigation |
| **Phase 3** | Mois 3 | Polish & Tests | QA, Design refiné, Bêta |

---

## 🎯 Phase 1 : Fondations & MVP Core (Semaines 1-4)

### Objectif
Créer les bases techniques et fonctionnelles pour permettre aux parents de créer des comptes et gérer leurs enfants.

### Semaine 1 : Setup & Architecture
**🎯 Objectif :** Infrastructure Supabase + Structure FlutterFlow

**Livrables :**
- [ ] Création instance Supabase (prod + staging)
- [ ] Script SQL complet (tables `users`, `children`, `events`, `documents`)
- [ ] Activation RLS + Policies de sécurité
- [ ] Création projet FlutterFlow "Manounou"
- [ ] Configuration connexion Supabase dans FlutterFlow
- [ ] Setup bucket Storage "documents" avec policies d'accès

**Critères de succès :**
- ✅ Base de données accessible via API Supabase
- ✅ RLS activé et testé (isolation des données par utilisateur)
- ✅ FlutterFlow connecté à Supabase

---

### Semaine 2 : Authentification & Onboarding
**🎯 Objectif :** Permettre aux utilisateurs de s'inscrire et se connecter

**Livrables :**
- [ ] Page `LoginPage` (FlutterFlow)
  - Email/Password
  - Connexion Apple (Sign in with Apple)
  - Lien "Créer un compte"
- [ ] Page `RegisterPage`
  - Formulaire email + mot de passe
  - Validation email
- [ ] Page `OnboardingPage` (première connexion)
  - Message de bienvenue
  - Explication courte de l'app
  - Bouton "Commencer"
- [ ] Workflow auth Supabase dans FlutterFlow
- [ ] Gestion session utilisateur (state management)

**Critères de succès :**
- ✅ Inscription fonctionnelle
- ✅ Connexion Apple/Email opérationnelle
- ✅ Session persistante après redémarrage app
- ✅ Redirection automatique si déjà connecté

---

### Semaine 3 : Gestion des Enfants
**🎯 Objectif :** CRUD complet pour les profils enfants

**Livrables :**
- [ ] Page `ChildrenListPage`
  - Liste des enfants (cards avec photo/avatar)
  - Bouton "Ajouter un enfant"
  - Swipe pour supprimer
- [ ] Page `ChildFormPage` (création/édition)
  - Champs : prénom, date de naissance, notes
  - Upload photo (optionnel, Supabase Storage)
  - Boutons "Enregistrer" / "Annuler"
- [ ] Page `ChildDetailPage`
  - Informations enfant
  - Liste événements associés
  - Liste documents associés
  - Bouton "Modifier"
- [ ] Workflows CRUD Supabase (Create, Read, Update, Delete)
- [ ] Validation des formulaires

**Critères de succès :**
- ✅ Création enfant fonctionnelle
- ✅ Modification enfant fonctionnelle
- ✅ Suppression enfant avec confirmation
- ✅ Données isolées par utilisateur (RLS)

---

### Semaine 4 : Dashboard & Navigation
**🎯 Objectif :** Navigation principale et vue d'ensemble

**Livrables :**
- [ ] Page `DashboardPage`
  - Compteur enfants
  - Événements à venir (prochaines 7 jours)
  - Documents récents
  - Cards cliquables vers pages dédiées
- [ ] Navigation Bottom Bar (FlutterFlow)
  - Onglets : Dashboard, Enfants, Calendrier, Documents, Profil
- [ ] Page `ProfilePage` (squelette)
  - Nom utilisateur
  - Email
  - Bouton "Déconnexion"
- [ ] Design System v1
  - Palette couleurs pastels
  - Typographie SF Rounded / Nunito
  - Composants réutilisables (cards, buttons)

**Critères de succès :**
- ✅ Navigation fluide entre pages
- ✅ Dashboard affiche données réelles
- ✅ Design cohérent et familial

---

## 🎯 Phase 2 : Calendrier & Documents (Semaines 5-8)

### Objectif
Ajouter la planification d'événements et la gestion de documents pour chaque enfant.

---

### Semaine 5 : Calendrier — Vue Jour & Semaine
**🎯 Objectif :** Affichage des événements par jour et semaine

**Livrables :**
- [ ] Page `EventsPage` — Vue Jour
  - Liste événements du jour sélectionné
  - Navigation jour précédent/suivant
  - Badge conflit si chevauchement
- [ ] Page `EventsPage` — Vue Semaine
  - Grille 7 jours avec événements
  - Sélection jour actif
  - Indicateur conflits
- [ ] Workflow lecture événements Supabase
  - Filtrage par date
  - Tri chronologique
- [ ] Détection conflits
  - Logique : chevauchement horaires pour même enfant

**Critères de succès :**
- ✅ Affichage événements jour/semaine
- ✅ Navigation temporelle fluide
- ✅ Détection conflits fonctionnelle

---

### Semaine 6 : Calendrier — Vue Mois & Création Événements
**🎯 Objectif :** Vue mensuelle et création d'événements

**Livrables :**
- [ ] Page `EventsPage` — Vue Mois
  - Calendrier mensuel avec dots indicateurs
  - Tap sur jour → vue détail
- [ ] Page `EventFormPage`
  - Formulaire : titre, enfant, date début, date fin
  - Sélection enfant (dropdown)
  - Validation chevauchement (warning)
  - Boutons "Enregistrer" / "Annuler"
- [ ] Page `EventDetailPage`
  - Informations événement
  - Bouton "Modifier" / "Supprimer"
- [ ] Workflows CRUD événements Supabase
- [ ] Toggle entre vues (Jour/Semaine/Mois)

**Critères de succès :**
- ✅ Vue mois fonctionnelle
- ✅ Création événement avec validation
- ✅ Modification/suppression événement
- ✅ Toggle vues fluide

---

### Semaine 7 : Gestion Documents — Upload & Liste
**🎯 Objectif :** Upload et affichage des documents

**Livrables :**
- [ ] Page `DocumentsPage`
  - Liste documents par enfant (filtre)
  - Cards avec nom fichier, type, date
  - Bouton "Ajouter un document"
- [ ] Page `DocumentUploadPage`
  - Sélection enfant
  - Sélection fichier (galerie/camera)
  - Type document (dropdown : certificat, autorisation, autre)
  - Upload Supabase Storage
  - Enregistrement métadonnées dans table `documents`
- [ ] Workflow upload Supabase Storage
  - Gestion erreurs (taille, format)
  - Progress indicator
- [ ] Affichage documents (images, PDF preview)

**Critères de succès :**
- ✅ Upload document fonctionnel
- ✅ Liste documents affichée
- ✅ Documents isolés par utilisateur (RLS)

---

### Semaine 8 : Gestion Documents — Visualisation & Partage
**🎯 Objectif :** Visualisation et partage des documents

**Livrables :**
- [ ] Page `DocumentDetailPage`
  - Visualisation document (PDF viewer / image viewer)
  - Informations (nom, type, date, enfant associé)
  - Bouton "Partager" (share sheet iOS/Android)
  - Bouton "Supprimer"
- [ ] Workflow suppression document
  - Suppression fichier Storage
  - Suppression métadonnées DB
- [ ] Filtres documents
  - Par enfant
  - Par type
- [ ] Recherche documents (nom)

**Critères de succès :**
- ✅ Visualisation document fonctionnelle
- ✅ Partage document opérationnel
- ✅ Suppression document fonctionnelle
- ✅ Filtres/recherche opérationnels

---

## 🎯 Phase 3 : Polish & Tests (Semaines 9-12)

### Objectif
Affiner l'expérience utilisateur, corriger les bugs et préparer la bêta.

---

### Semaine 9 : Design System & UX Refinement
**🎯 Objectif :** Design cohérent et expérience optimale

**Livrables :**
- [ ] Design System complet
  - Palette couleurs finale
  - Typographie (SF Rounded / Nunito)
  - Composants réutilisables (buttons, cards, inputs)
  - Spacing & Layout guidelines
- [ ] Animations & Transitions
  - Transitions entre pages
  - Animations micro-interactions
  - Loading states
- [ ] Responsive Design
  - Adaptation iPad/tablettes
  - Orientation portrait/paysage
- [ ] Accessibilité
  - Contrastes couleurs (WCAG AA)
  - Taille texte lisible
  - Support VoiceOver/TalkBack

**Critères de succès :**
- ✅ Design cohérent sur toutes les pages
- ✅ Animations fluides
- ✅ Accessibilité validée

---

### Semaine 10 : Tests Fonctionnels & QA
**🎯 Objectif :** Valider toutes les fonctionnalités et corriger les bugs

**Livrables :**
- [ ] Checklist tests fonctionnels
  - Auth (inscription, connexion, déconnexion)
  - CRUD enfants
  - CRUD événements
  - CRUD documents
  - Navigation
  - RLS (isolation données)
- [ ] Tests utilisateurs (3-5 parents bêta)
  - Scénarios réalistes
  - Feedback utilisateurs
- [ ] Correction bugs critiques
- [ ] Tests performance
  - Temps chargement pages
  - Upload documents
  - Synchronisation Supabase

**Critères de succès :**
- ✅ 0 bug critique
- ✅ Tous les scénarios fonctionnent
- ✅ Feedback utilisateurs intégré

---

### Semaine 11 : Features Additionnelles & Optimisations
**🎯 Objectif :** Ajouter des fonctionnalités bonus et optimiser

**Livrables :**
- [ ] Notifications locales (événements à venir)
  - Setup notifications iOS/Android
  - Rappels événements (24h avant)
- [ ] Export calendrier (iCal)
  - Export événements format .ics
- [ ] Statistiques Dashboard
  - Nombre événements mois
  - Nombre documents par enfant
- [ ] Optimisations
  - Cache images
  - Lazy loading listes
  - Réduction requêtes Supabase

**Critères de succès :**
- ✅ Notifications fonctionnelles
- ✅ Export calendrier opérationnel
- ✅ Performance améliorée

---

### Semaine 12 : Préparation Bêta & Documentation
**🎯 Objectif :** Finaliser pour lancement bêta

**Livrables :**
- [ ] Documentation utilisateur
  - Guide démarrage rapide
  - FAQ
- [ ] Documentation technique
  - Architecture FlutterFlow
  - Schéma Supabase
  - Guide déploiement
- [ ] Configuration bêta
  - TestFlight (iOS)
  - Google Play Internal Testing (Android)
- [ ] Marketing bêta
  - Landing page simple
  - Formulaire inscriptions bêta
- [ ] Checklist lancement
  - Tests finaux
  - Backup données
  - Monitoring Supabase

**Critères de succès :**
- ✅ Documentation complète
- ✅ App prête bêta TestFlight/Play Store
- ✅ Processus inscriptions bêta opérationnel

---

## 📈 Métriques de Succès (MVP)

| Métrique | Objectif | Mesure |
|:---------|:---------|:-------|
| **Taux conversion onboarding** | > 70% | Inscriptions / Ouvertures app |
| **Temps création enfant** | < 30s | Temps moyen formulaire |
| **Taux création événement** | > 50% | Événements créés / Utilisateurs actifs |
| **Taux upload document** | > 30% | Documents uploadés / Utilisateurs actifs |
| **Satisfaction utilisateurs** | > 4/5 | NPS ou feedback qualitatif |
| **Stabilité app** | < 1% crash | Taux crash Firebase Crashlytics |

---

## 🚀 Post-MVP (Roadmap future)

### Mois 4-6 : Améliorations & Partage
- Partage calendrier entre parents
- Invitation co-parents/nounous
- Notifications push Supabase
- Synchronisation temps réel (Supabase Realtime)

### Mois 7-9 : Intelligence & Automatisation
- Suggestions événements récurrents
- Rappels automatiques
- Export PDF rapports mensuels
- Intégration calendriers externes (Google Calendar, iCal)

### Mois 10-12 : Communauté & Évolutions
- Mode famille recomposée (multi-parents)
- Chat famille (intra-app)
- Backups automatiques
- Mode hors-ligne (offline-first)

---

## 📝 Notes de Roadmap

### Priorités
1. **Sécurité** : RLS doit être activé dès le début, testé à chaque étape
2. **Simplicité** : Chaque fonctionnalité doit être intuitive pour les parents
3. **Performance** : L'app doit être rapide même avec beaucoup de données

### Risques identifiés
- **Complexité calendrier** : Multi-vues peuvent être difficiles à implémenter dans FlutterFlow
  - *Mitigation* : Commencer par vue jour, puis semaine, puis mois
- **Upload documents** : Gestion erreurs réseau/stockage
  - *Mitigation* : Retry automatique, messages clairs
- **RLS** : Risque de bugs d'isolation données
  - *Mitigation* : Tests systématiques à chaque feature

### Dependencies
- FlutterFlow : Accès projet payant ou gratuit (selon plan)
- Supabase : Plan gratuit suffisant pour MVP (limite 500MB DB)
- Storage Supabase : Plan gratuit 1GB (suffisant pour MVP)

---

## 🎯 Prochaine Action Immédiate

**Semaine 1, Jour 1 :**
1. Créer instance Supabase
2. Exécuter script SQL (tables + RLS)
3. Créer projet FlutterFlow
4. Connecter FlutterFlow à Supabase

---

**Document maintenu par :** MultiApp Builder Team  
**Dernière mise à jour :** 2025-01-13  
**Version roadmap :** 1.0.0


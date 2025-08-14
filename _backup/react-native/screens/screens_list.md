# Liste des Écrans - Application Manounou

## 1. Pages Publiques

### 1.1 Landing Page (`/`)
- **Objectif** : Présenter Manounou et convertir les visiteurs
- **Éléments clés** :
  - Hero section avec proposition de valeur
  - Fonctionnalités principales
  - Témoignages
  - Tarification
  - CTA d'inscription
- **Responsive** : Oui
- **SEO** : Optimisé pour "app nounou parent", "gestion garde enfant"

### 1.2 Page Tarification (`/pricing`)
- **Objectif** : Détailler les plans et encourager l'upgrade
- **Éléments clés** :
  - Comparatif des 3 plans (Free, Starter, Full)
  - FAQ sur la facturation
  - Garantie et conditions
  - CTA d'inscription par plan

### 1.3 Pages Légales
- **CGU** (`/legal/terms`) : Conditions générales d'utilisation
- **Confidentialité** (`/legal/privacy`) : Politique de confidentialité
- **Cookies** (`/legal/cookies`) : Politique des cookies

## 2. Authentification

### 2.1 Connexion (`/auth/login`)
- **Éléments** :
  - Formulaire email/mot de passe
  - Lien "Mot de passe oublié"
  - Lien vers inscription
  - Connexion sociale (optionnel)
- **Validation** : Temps réel avec messages d'erreur clairs

### 2.2 Inscription (`/auth/register`)
- **Éléments** :
  - Formulaire email/mot de passe/confirmation
  - Acceptation CGU et politique de confidentialité
  - Lien vers connexion
- **Validation** : Force du mot de passe, unicité email

### 2.3 Mot de passe oublié (`/auth/forgot-password`)
- **Éléments** :
  - Formulaire email
  - Message de confirmation d'envoi
  - Lien retour connexion

### 2.4 Réinitialisation (`/auth/reset-password`)
- **Éléments** :
  - Formulaire nouveau mot de passe
  - Confirmation mot de passe
  - Validation token

## 3. Onboarding

### 3.1 Choix du rôle (`/onboarding/role`)
- **Objectif** : Identifier si l'utilisateur est parent ou nounou
- **Éléments** :
  - Deux cartes avec descriptions
  - Illustrations pour chaque rôle
  - Bouton "Continuer"

### 3.2 Sélection du plan (`/onboarding/plan`)
- **Objectif** : Choisir le plan d'abonnement
- **Éléments** :
  - Comparatif des plans avec limites
  - Recommandation selon le rôle
  - Option "Commencer gratuit"
  - Processus de paiement Stripe (si payant)

### 3.3 Profil initial (`/onboarding/profile`)
- **Objectif** : Compléter les informations de base
- **Éléments** :
  - Nom d'affichage
  - Photo de profil (optionnel)
  - Langue préférée
  - Bouton "Terminer l'inscription"

## 4. Application Principale

### 4.1 Tableau de bord (`/dashboard`)
- **Objectif** : Vue d'ensemble de l'activité
- **Éléments** :
  - Résumé du jour (événements à venir)
  - Statistiques rapides (enfants, documents, événements)
  - Notifications récentes
  - Raccourcis vers actions fréquentes
  - Indicateur de limite de plan

### 4.2 Gestion des enfants

#### 4.2.1 Liste des enfants (`/children`)
- **Éléments** :
  - Cartes enfants avec photo, nom, âge
  - Bouton "Ajouter un enfant" (si limite non atteinte)
  - Recherche/filtre
  - Indicateur limite plan

#### 4.2.2 Détail enfant (`/children/[id]`)
- **Éléments** :
  - Informations complètes (nom, date naissance, allergies)
  - Photo
  - Notes privées
  - Historique récent (événements, documents)
  - Actions rapides

#### 4.2.3 Créer/Modifier enfant (`/children/new`, `/children/[id]/edit`)
- **Formulaire** :
  - Nom complet
  - Date de naissance
  - Photo (upload)
  - Allergies
  - Notes
  - Validation côté client et serveur

### 4.3 Planning

#### 4.3.1 Vue Planning (`/planning`)
- **Vues disponibles** :
  - Jour (par défaut)
  - Semaine (Starter+)
  - Mois (Full uniquement)
- **Éléments** :
  - Calendrier interactif
  - Événements colorés par type
  - Bouton "Nouvel événement"
  - Filtres par enfant
  - Navigation temporelle

#### 4.3.2 Créer événement (`/planning/new`)
- **Formulaire** :
  - Type (activité, repas, sieste, sortie, vacances)
  - Titre
  - Enfant concerné (sélection multiple)
  - Date et heure début/fin
  - Notes
  - Récurrence (optionnel)

#### 4.3.3 Détail événement (`/planning/[id]`)
- **Éléments** :
  - Informations complètes
  - Historique des modifications
  - Actions (modifier, supprimer, dupliquer)
  - Participants (parent/nounou)

### 4.4 Documents

#### 4.4.1 Liste documents (`/documents`)
- **Éléments** :
  - Liste/grille des documents
  - Filtres par enfant, type, date
  - Recherche par nom
  - Bouton "Télécharger document" (si limite non atteinte)
  - Indicateur stockage utilisé

#### 4.4.2 Télécharger document (`/documents/upload`)
- **Formulaire** :
  - Sélection fichier (drag & drop)
  - Nom du document
  - Enfant concerné
  - Type/catégorie
  - Validation taille et format

#### 4.4.3 Visualiser document (`/documents/[id]`)
- **Éléments** :
  - Prévisualisation (PDF, images)
  - Métadonnées (nom, taille, date, auteur)
  - Actions (télécharger, supprimer, partager)
  - Historique d'accès

### 4.5 Profil utilisateur

#### 4.5.1 Mon profil (`/profile`)
- **Sections** :
  - Informations personnelles
  - Photo de profil
  - Préférences (langue, notifications)
  - Sécurité (changer mot de passe)
  - Plan actuel et utilisation

#### 4.5.2 Paramètres compte (`/profile/settings`)
- **Éléments** :
  - Notifications email
  - Langue interface
  - Fuseau horaire
  - Préférences d'affichage
  - Suppression de compte

#### 4.5.3 Facturation (`/profile/billing`)
- **Éléments** :
  - Plan actuel et limites
  - Historique des factures
  - Méthode de paiement
  - Boutons upgrade/downgrade
  - Annulation abonnement

## 5. Écrans d'erreur

### 5.1 Erreur 404 (`/404`)
- **Éléments** :
  - Message d'erreur friendly
  - Liens de navigation
  - Recherche
  - Retour accueil

### 5.2 Erreur 500 (`/500`)
- **Éléments** :
  - Message d'excuse
  - Contact support
  - Retry automatique

### 5.3 Maintenance (`/maintenance`)
- **Éléments** :
  - Message de maintenance
  - Estimation durée
  - Liens réseaux sociaux

## 6. Modales et Composants

### 6.1 Modales
- **Confirmation suppression** : Enfant, événement, document
- **Limite atteinte** : Upgrade vers plan supérieur
- **Partage document** : Sélection destinataires
- **Export planning** : Choix format et période

### 6.2 Notifications
- **Toast notifications** : Succès, erreur, info
- **Notifications push** : Événements, documents (Starter+)
- **Centre de notifications** : Historique des notifications

## 7. Responsive Design

### 7.1 Breakpoints
- **Mobile** : < 768px
- **Tablet** : 768px - 1024px
- **Desktop** : > 1024px

### 7.2 Adaptations mobiles
- Navigation bottom tab bar
- Formulaires optimisés tactile
- Calendrier swipe horizontal
- Upload photo depuis caméra

## 8. États de chargement

### 8.1 Skeletons
- Liste enfants
- Planning
- Documents
- Dashboard

### 8.2 Spinners
- Boutons d'action
- Upload fichiers
- Sauvegarde formulaires

## 9. Accessibilité

### 9.1 Navigation clavier
- Tous les éléments interactifs
- Skip links
- Focus visible

### 9.2 Screen readers
- Labels appropriés
- ARIA attributes
- Descriptions alternatives

### 9.3 Contrastes
- Conformité WCAG AA
- Mode sombre (optionnel)

## 10. Performances

### 10.1 Optimisations
- Lazy loading images
- Code splitting par route
- Compression assets
- CDN pour fichiers statiques

### 10.2 Métriques cibles
- **LCP** : < 2.5s
- **FID** : < 100ms
- **CLS** : < 0.1
- **TTI** : < 3.5s
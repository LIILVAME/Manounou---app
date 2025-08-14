# Manounou - Livrables MVP

## 📋 Vue d'ensemble

Ce dossier contient tous les livrables nécessaires pour développer l'application Manounou, une plateforme de gestion et d'organisation entre parents et nounous.

### 🎯 Objectif Business
Faciliter la communication et l'organisation quotidienne entre parents et nounous grâce à une application web intuitive et sécurisée.

### 👥 Personas
- **Parent** : Gère les profils des enfants, planifie les activités, partage les documents
- **Nounou** : Consulte les informations, gère ses disponibilités, accède aux documents

### 💡 Proposition de Valeur
- **FR** : "Simplifiez la garde de vos enfants avec Manounou - planning, documents et communication en un seul endroit"
- **EN** : "Simplify your childcare with Manounou - scheduling, documents and communication in one place"

### 📊 KPIs de Succès (90 jours)
- **Utilisateurs actifs** : 500 utilisateurs mensuels
- **Taux d'activation** : 70% (complètent l'onboarding)
- **Rétention D30** : 40%
- **Conversion payante** : 15%

## 📁 Structure des Livrables

```
deliverables/
├── design-system/          # Tokens de design et identité visuelle
│   └── tokens.json         # Couleurs, typographie, espacements, composants
├── copy/                   # Contenus textuels multilingues
│   ├── fr.json            # Textes français
│   └── en.json            # Textes anglais
├── schema/                 # Structure de données
│   ├── schema.sql         # Schéma SQL avec RLS et fonctions
│   └── schema.json        # Description JSON du modèle de données
├── integrations/          # Configuration des services externes
│   ├── stripe_products.json       # Produits et webhooks Stripe
│   ├── posthog_events.json        # Événements analytics PostHog
│   └── email_templates/            # Templates d'emails Resend
│       ├── planning_updated_fr.html
│       ├── planning_updated_en.html
│       ├── document_added_fr.html
│       ├── document_added_en.html
│       ├── vacation_added_fr.html
│       ├── vacation_added_en.html
│       ├── signup_confirmation_fr.html
│       ├── signup_confirmation_en.html
│       ├── password_reset_fr.html
│       ├── password_reset_en.html
│       └── templates_config.json
├── legal/                 # Documents légaux
│   ├── cgu.md            # Conditions générales d'utilisation
│   └── privacy.md        # Politique de confidentialité
├── screens/              # Spécifications des écrans
│   └── screens_list.md   # Liste détaillée de tous les écrans
├── limits/               # Configuration des plans et limites
│   └── plans_limits.json # Limites par plan et permissions par rôle
└── README.md            # Ce fichier
```

## 🏗️ Architecture MVP (MoSCoW)

### ✅ Must Have
- **Authentification** : Inscription, connexion, mot de passe oublié
- **Onboarding** : Choix rôle + plan d'abonnement
- **Dashboard** : Vue d'ensemble de l'activité
- **Enfants** : CRUD profils enfants avec photos et informations
- **Planning** : Gestion événements (activités, repas, siestes, sorties, vacances)
- **Documents** : Upload, visualisation, organisation par enfant
- **Profil** : Gestion compte utilisateur et préférences
- **Multilingue** : Interface FR/EN
- **Notifications email** : Planning, documents, vacances
- **Paiements Stripe** : Abonnements et facturation
- **Analytics PostHog** : Suivi utilisation et conversion

### 🎯 Should Have
- **Import/Export** : Export planning PDF/Excel
- **Vues planning** : Jour, semaine (selon plan)

### 💭 Could Have
- **Tags personnalisés** : Catégorisation événements
- **Notes privées** : Annotations personnelles

### ❌ Won't Have (MVP)
- **Chat temps réel** : Messagerie intégrée
- **Notifications push natives** : Apps mobiles
- **Marketplace** : Recherche de nounous

## 🎨 Design System

### Couleurs Principales
- **Primary** : #6C63FF (Violet moderne)
- **Background** : #F6F6FA (Gris très clair)
- **Text** : #202124 (Noir doux)
- **Surface** : #FFFFFF (Blanc)
- **Border** : #E7E7EF (Gris bordure)

### Typographie
- **Famille** : Inter (fallback: SF Pro, system)
- **Tailles** : 12px, 14px, 16px, 18px, 24px, 32px, 48px
- **Poids** : 400 (Regular), 500 (Medium), 600 (SemiBold), 700 (Bold)

### Espacements
- **Base** : 4px, 8px, 16px, 24px, 32px, 48px, 64px

## 💳 Plans d'Abonnement

| Plan | Prix | Enfants | Documents | Événements/jour |
|------|------|---------|-----------|------------------|
| **Free** | 0€ | 1 | 3 | 10 |
| **Starter** | 9,99€/mois | 3 | 20 | 50 |
| **Full** | 13,99€/mois | Illimité | Illimité | Illimité |

## 🔐 Rôles et Permissions

### Parent
- **Enfants** : CRUD complet
- **Événements** : CRUD complet
- **Documents** : CRUD complet
- **Planning** : Toutes les vues, export

### Nounou
- **Enfants** : Lecture seule (enfants assignés)
- **Événements** : CRUD sur ses créneaux uniquement
- **Documents** : Lecture seule
- **Planning** : Vues jour/semaine, pas d'export

## 🔧 Intégrations Techniques

### Services Requis
- **Supabase** : Base de données PostgreSQL + Auth + Storage
- **Stripe** : Paiements et abonnements
- **Resend** : Envoi d'emails transactionnels
- **PostHog** : Analytics et suivi utilisateur

### Configuration Stripe
- **Produits** : manounou_free, manounou_starter_monthly, manounou_full_monthly
- **Webhooks** : customer.subscription.*, checkout.session.completed

### Événements Analytics
- signup, select_plan, add_child, create_event, upload_document
- change_language, upgrade_plan, login, logout
- dashboard_view, planning_view, export_data
- limit_reached, error_occurred

## 📧 Notifications Email

### Déclencheurs
1. **Planning modifié** : Événement créé/modifié/supprimé
2. **Document ajouté** : Nouveau document téléchargé
3. **Vacances** : Période de vacances ajoutée/validée
4. **Compte** : Inscription confirmée, mot de passe réinitialisé

### Templates Disponibles
- Bilingues (FR/EN)
- Responsive design
- Variables dynamiques
- Liens vers l'application

## 🚀 Prochaines Étapes

### Phase 1 : Setup Technique
1. Configurer Supabase (base de données + auth)
2. Créer produits Stripe
3. Configurer Resend et PostHog
4. Implémenter schéma de base de données

### Phase 2 : Développement Core
1. Authentification et onboarding
2. Dashboard et navigation
3. Gestion des enfants
4. Planning de base

### Phase 3 : Fonctionnalités Avancées
1. Documents et upload
2. Notifications email
3. Paiements et abonnements
4. Analytics et optimisations

### Phase 4 : Tests et Déploiement
1. Tests fonctionnels complets
2. Tests de charge
3. Optimisations performances
4. Déploiement production

## 📞 Support et Contact

### Comptes de Test
- **Parent** : parent_test@manounou.com / TestPass123!
- **Nounou** : nanny_test@manounou.com / TestPass123!

### Données de Test
- 1 parent, 1 nounou
- 1 enfant (Emma, 3 ans)
- 5 événements sur la semaine
- 2 documents (certificat médical, photo)

### Scénarios de Validation
1. **Happy Path** : Inscription → Onboarding → Ajout enfant → Création événement
2. **Limites** : Tentative dépassement limites plan gratuit
3. **Paiement** : Upgrade vers plan payant
4. **Notifications** : Réception emails après actions

---

**Version** : 1.0
**Dernière mise à jour** : [DATE]
**Contact** : [EMAIL_CONTACT]
# Spécifications Fonctionnelles — MVP Manounou

Objectif: cadrer l’implémentation MVP autour des flows essentiels (Onboarding, Enfants, Calendrier, Documents), avec user stories et critères d’acceptation mesurables.

## Contexte
- Plateforme: iOS (SwiftUI), backend Supabase.
- Rôles: Parent (owner, member), Nounou.
- Contraintes: simplicité, sécurité (RLS), performance perçue, FR par défaut.

## Onboarding Minimal
### User Stories
- En tant que nouvel utilisateur, je crée un compte avec email et mot de passe.
- En tant que parent, je crée une famille et j’ajoute mon premier enfant.
- En tant que nounou, j’indique mes préférences de garde (optionnel) et accède au calendrier.

### Critères d’acceptation
- Formulaire login/register valide champs requis et formats (email, mot de passe ≥ 6).
- 4 étapes max: compte, rôle, (famille), premier enfant.
- Pas d’upload obligatoire; tout champ optionnel est marqué.
- Activation réussie si: compte créé + premier enfant créé.

## Enfants
### User Stories
- En tant que parent, je crée/modifie/supprime un enfant.
- En tant que nounou, je consulte les enfants qui me sont assignés.

### Critères d’acceptation
- Champs obligatoires: nom complet, date de naissance.
- Tags santé (allergies) optionnels; notes optionnelles.
- Détail enfant: sections repliables (santé, personnes autorisées, documents liés).
- Suppression confirmée par modal.

## Calendrier (Famille)
### User Stories
- En tant que parent/nounou, je crée un événement (Garde, Rendez-vous, Activité).
- En tant que parent, je configure une répétition hebdomadaire simple.
- En tant qu’utilisateur, je reçois un rappel par notification locale 15 min avant.

### Critères d’acceptation
- Création: titre, type, enfant (optionnel), heure début/fin, notes.
- Validation: fin > début; type sélectionné; titre non vide.
- Répétition: hebdo même jour (sans exceptions pour MVP).
- Rappels: notification locale programmée pour chaque événement valable.

## Documents
### User Stories
- En tant que parent/nounou, j’upload un document (JPEG/PDF) et je l’associe à un enfant ou à la famille.
- En tant qu’utilisateur, je filtre les documents par enfant et je consulte le dernier modifié.

### Critères d’acceptation
- Upload: compression côté client pour JPEG; progression visible; gestion des erreurs réseau.
- Tags: enfant, type (ex: santé, autorisation), notes.
- Suppression: confirmation; suppression irréversible.

## Rôles et Permissions
### User Stories
- En tant que parent owner, je gère les rôles et les accès.
- En tant que nounou, j’ajoute des événements de garde et consulte les enfants autorisés.

### Critères d’acceptation
- Parent owner: tout accès (y compris gestion des rôles, suppression famille).
- Parent member: accès complet sauf gestion des rôles critiques.
- Nounou: lecture enfants assignés, création/édition événements de garde, lecture calendrier; pas d’accès aux réglages de compte.
- RLS: aucune lecture/écriture en dehors des permissions définies.

## Notifications
### User Stories
- En tant qu’utilisateur, j’active/désactive les rappels dans Réglages.
- En tant que parent, je reçois des notifications locales pour les événements à venir.

### Critères d’acceptation
- Autorisation système demandée une seule fois et gérée dans Réglages.
- Rappels actifs si opt-in; pas de notifications si opt-out.

## États et Feedback
### User Stories
- En tant qu’utilisateur, je comprends les états vides et les erreurs et je peux agir.
- En tant qu’utilisateur, je vois des loaders squelettes pendant les chargements.

### Critères d’acceptation
- États vides: CTA vers action utile.
- Offline: bannière informative; données cache affichées si disponibles.
- Erreur: message clair + bouton "Réessayer".
- Toasters: succès/échec non bloquants.

## KPIs et Mesures
- Activation onboarding > 70%.
- Médiane temps création événement < 20 s.
- Upload documents: succès > 95%.
- Erreurs saisie < 0.3/session.

## Dépendances et Contraintes Techniques
- SwiftUI: listes performantes (`LazyVStack`), pagination si >200 items.
- Supabase: schémas simples, policies RLS strictes.
- iOS: guidelines typographiques, contrastes, tailles d’interaction.
- i18n: FR en premier; structure prête pour EN.
# UX Microcopy FR — Manounou

Objectif: fournir des messages clairs, utiles et rassurants pour les états vides, erreurs, offline et confirmations, sur les 4 écrans clés (Home, Enfants, Calendrier, Documents).

## Principes
- Clarté: phrases courtes, ton bienveillant, action explicite.
- Utilité: chaque message propose une prochaine action.
- Cohérence: vocabulaire aligné avec l’interface (CTA, labels).
- Accessibilité: éviter jargon technique, mentionner le contexte.

## Home (Tableau de bord)
- État vide (événements du jour)
  - Titre: "Aucun événement prévu aujourd'hui"
  - Sous-titre: "Ajoutez un rendez-vous, une garde ou une activité pour commencer."
  - CTA: "Ajouter un événement"
- Erreur chargement
  - Message: "Impossible d’afficher le tableau de bord."
  - Action: "Réessayer"
- Offline
  - Bannière: "Mode hors ligne — affichage des données en cache"

## Enfants (Liste)
- État vide
  - Titre: "Aucun enfant ajouté"
  - Sous-titre: "Ajoutez votre premier enfant pour personnaliser Manounou."
  - CTA: "Ajouter un enfant"
- Erreur chargement
  - Message: "Impossible de charger la liste des enfants."
  - Action: "Réessayer"
- Validation formulaire
  - Nom: "Le nom complet est requis"
  - Date de naissance: "La date de naissance est requise"
  - Date invalide: "Format de date invalide"
- Succès
  - Toast: "Enfant enregistré"
  - Toast (modification): "Profil enfant mis à jour"

## Fiche Enfant (Détail)
- État vide (sections)
  - Allergies (vide): "Aucune allergie renseignée"
  - Autorisations (vide): "Aucune personne autorisée — ajoutez une personne de confiance"
- Erreur sauvegarde
  - Message: "Échec de la sauvegarde du profil"
  - Action: "Réessayer"

## Calendrier (Famille)
- État vide
  - Titre: "Aucun événement dans la période"
  - Sous-titre: "Ajoutez une garde, un rendez-vous ou une activité."
  - CTA: "Nouvel événement"
- Erreur chargement
  - Message: "Impossible de charger le calendrier"
  - Action: "Réessayer"
- Événement (validation)
  - Titre requis: "Le titre est requis"
  - Type requis: "Sélectionnez un type d’événement"
  - Heures invalides: "L’heure de fin doit être après l’heure de début"
- Succès
  - Toast: "Événement ajouté"
  - Toast (modification): "Événement mis à jour"
  - Toast (suppression): "Événement supprimé"

## Documents
- État vide
  - Titre: "Aucun document ajouté"
  - Sous-titre: "Ajoutez une fiche santé, une autorisation ou un document utile."
  - CTA: "Ajouter un document"
- Upload (feedback)
  - Progression: "Téléchargement en cours…"
  - Succès: "Document ajouté"
  - Échec: "Échec du téléchargement — vérifiez votre connexion"
- Erreur chargement
  - Message: "Impossible de charger les documents"
  - Action: "Réessayer"

## États génériques
- Offline
  - "Mode hors ligne — certaines actions peuvent être indisponibles"
- Erreur générique
  - "Une erreur est survenue — réessayez ou revenez plus tard"
- Boutons génériques
  - "Réessayer", "Annuler", "Fermer", "Continuer"

## Notifications locales (exemples)
- Rappel d’événement
  - Titre: "Rappel: {title}"
  - Corps: "Commence à {startTime} — vérifiez les détails dans le calendrier."
- Document ajouté
  - Titre: "Document ajouté"
  - Corps: "{documentName} pour {childName}"
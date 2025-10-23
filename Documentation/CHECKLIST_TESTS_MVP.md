# Checklist de Tests Manuels — MVP Manounou

Objectif: valider les flows clés (Onboarding, Enfants, Calendrier, Documents) avec scénarios, prérequis et résultats attendus.

## Convention
- Statuts: Pass/Fail/Blocked.
- Données: email test, famille de démo, 2 enfants (Alice, Léo).
- Environnement: iOS Simulator + compte Supabase de dev.

## 1. Onboarding
- Créer compte email/mot de passe
  - Pré-requis: email non utilisé
  - Étapes: ouvrir app → s’inscrire → email/mot de passe → rôle
  - Attendu: compte créé, session active
- Créer famille
  - Étapes: sélectionner "Parent" → créer famille (nom)
  - Attendu: famille visible, rôle Owner
- Ajouter premier enfant
  - Étapes: formulaire enfant (nom, date de naissance)
  - Attendu: enfant listé sur écran Enfants
- Choisir rôle Nounou
  - Étapes: s’inscrire en tant que nounou
  - Attendu: accès limité, calendrier visible

## 2. Enfants
- Créer enfant
  - Étapes: + → nom, date de naissance → enregistrer
  - Attendu: enfant apparaît en liste
- Modifier enfant
  - Étapes: ouvrir détail → modifier champs → enregistrer
  - Attendu: valeurs mises à jour
- Supprimer enfant (Parent Owner)
  - Étapes: détail → supprimer → confirmer
  - Attendu: enfant retiré de la liste
- Nounou: accès enfants assignés
  - Pré-requis: assigner 1 enfant à la nounou
  - Étapes: connexion nounou → consulter liste
  - Attendu: enfant assigné visible, autres non

## 3. Calendrier
- Créer événement Garde
  - Étapes: + → type Garde → heures → enfant → enregistrer
  - Attendu: événement affiché, notification programmée
- Créer événement Rendez-vous
  - Étapes: + → type Rendez-vous → heures → enregistrer
  - Attendu: événement affiché
- Répétition hebdomadaire simple
  - Étapes: cocher répétition hebdo
  - Attendu: occurrences générées
- Éditer un événement
  - Étapes: ouvrir → modifier heure → enregistrer
  - Attendu: mise à jour visible
- Supprimer événement (Parent)
  - Étapes: détail → supprimer → confirmer
  - Attendu: retiré du calendrier
- Nounou: créer événement Garde
  - Étapes: nounou → + → type Garde → enfant assigné
  - Attendu: création autorisée

## 4. Documents
- Upload JPEG
  - Étapes: + → sélectionner photo → upload
  - Attendu: progression visible, document listé
- Upload PDF
  - Étapes: + → sélectionner PDF → upload
  - Attendu: progression visible, document listé
- Associer à un enfant
  - Étapes: choisir enfant lors de l’upload
  - Attendu: filtrage par enfant fonctionne
- Supprimer document (Parent)
  - Étapes: détail → supprimer → confirmer
  - Attendu: document retiré
- Nounou: lecture documents enfants assignés
  - Étapes: nounou → ouvrir documents
  - Attendu: visibles si liés à enfants assignés

## 5. Notifications Locales
- Activer notifications
  - Étapes: réglages → activer notifications
  - Attendu: autorisation système accordée
- Rappel 15 min avant
  - Étapes: créer événement proche
  - Attendu: notification reçue
- Désactiver notifications
  - Étapes: réglages → désactiver
  - Attendu: plus de rappels

## 6. Résilience & États
- Offline
  - Étapes: couper réseau → ouvrir app
  - Attendu: bannière offline, cache affiché si disponible
- Erreurs réseau upload
  - Étapes: upload avec réseau instable
  - Attendu: message d’erreur + bouton Réessayer
- États vides
  - Étapes: aucune donnée
  - Attendu: messages d’orientation + CTA

## 7. Sécurité/Permissions
- Nounou ne peut pas supprimer enfant
  - Étapes: nounou → tenter suppression
  - Attendu: action interdite
- Parent Member ne peut pas gérer rôles
  - Étapes: member → tenter accès réglages rôles
  - Attendu: action interdite

## 8. Performance perçue
- Chargement listes < 1s (≤50 items)
- Création événement < 20s
- Upload document < 10s (réseau stable)

## Sortie de Test
- Fichier de résultats: test_run_<date>.md avec statuts Pass/Fail/Blocked et anomalies.
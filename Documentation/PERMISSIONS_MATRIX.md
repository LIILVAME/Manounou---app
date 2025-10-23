# Matrice des Permissions — Manounou

Rôles: Parent Owner, Parent Member, Nounou.
Principe: accès minimal nécessaire, aligné avec RLS Supabase.

## Légende
- ✅ Autorisé
- ⚠️ Restreint (conditions)
- ❌ Interdit

## Actions par Domaines

### Enfants
- Voir liste des enfants
  - Parent Owner: ✅
  - Parent Member: ✅
  - Nounou: ⚠️ (uniquement enfants assignés)
- Créer un enfant
  - Parent Owner: ✅
  - Parent Member: ✅
  - Nounou: ❌
- Modifier un enfant
  - Parent Owner: ✅
  - Parent Member: ✅
  - Nounou: ❌
- Supprimer un enfant
  - Parent Owner: ✅
  - Parent Member: ❌
  - Nounou: ❌

### Calendrier
- Voir le calendrier familial
  - Parent Owner: ✅
  - Parent Member: ✅
  - Nounou: ⚠️ (événements associés aux enfants assignés)
- Créer un événement
  - Parent Owner: ✅
  - Parent Member: ✅
  - Nounou: ⚠️ (type = Garde, enfants assignés)
- Modifier un événement
  - Parent Owner: ✅
  - Parent Member: ✅
  - Nounou: ⚠️ (ses événements de Garde uniquement)
- Supprimer un événement
  - Parent Owner: ✅
  - Parent Member: ✅
  - Nounou: ❌

### Documents
- Voir documents
  - Parent Owner: ✅
  - Parent Member: ✅
  - Nounou: ⚠️ (documents liés aux enfants assignés)
- Upload document
  - Parent Owner: ✅
  - Parent Member: ✅
  - Nounou: ⚠️ (selon politique famille; par défaut ✅ sur enfants assignés)
- Supprimer document
  - Parent Owner: ✅
  - Parent Member: ✅ (ses propres uploads)
  - Nounou: ❌

### Compte & Réglages
- Gérer rôles/permissions
  - Parent Owner: ✅
  - Parent Member: ❌
  - Nounou: ❌
- Modifier paramètres application (notifications, langue)
  - Parent Owner: ✅
  - Parent Member: ✅
  - Nounou: ✅ (notifications locales)
- Mettre à jour profil utilisateur (avatar, email)
  - Parent Owner: ✅
  - Parent Member: ✅
  - Nounou: ✅
- Supprimer famille
  - Parent Owner: ✅
  - Parent Member: ❌
  - Nounou: ❌

## Règles RLS (guidelines)
- Enfants: `SELECT` pour nounou filtré par table de relation `nanny_children`.
- Événements: `SELECT/INSERT/UPDATE` pour nounou conditionné par `type = 'Garde'` et `child_id ∈ nanny_children`.
- Documents: `SELECT` pour nounou filtré par `child_id ∈ nanny_children`; `INSERT` autorisé si policy famille; `DELETE` réservé aux parents.
- Rôles: seules les actions d’admin sont possibles pour Parent Owner.

## Cas Limites
- Nounou sans enfant assigné: UI doit refléter accès restreint (états vides + guide d’accès).
- Conflits de modification: privilégier dernière écriture côté serveur; UI montre confirmation et rafraîchit.
- Révocation d’accès: effet immédiat; caches invalidés.

## Décisions Futures
- Option famille: autoriser upload doc par nounou (par défaut: autorisé, suppression non autorisée).
- Journal d’audit minimal: création/modification/suppression (événements, documents).
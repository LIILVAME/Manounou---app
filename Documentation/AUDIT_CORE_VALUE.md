# Audit profond — Core value de Manounou

> Date : 2026-06-14 · Périmètre : positionnement produit + alignement code/valeur.

## Verdict

Manounou a construit proprement la couche **commodité** (organiseur familial CRUD) et avait
*maquetté* la couche qui constitue sa vraie valeur (**automatisation Pajemploi** +
**collaboration parent↔nounou**). La core value est juste et défendable ; elle était
livrée comme une promesse visuelle, pas comme un produit fonctionnel.

Ce document fige le constat **et** acte le premier correctif (calcul Pajemploi réel).

---

## 1. La bonne core value

Deux visions se disputaient le repo :

| | Manounou A (README + spec MVP + plan lean, *avant* cet audit) | Manounou B (le nom, les écrans, les commentaires de code) |
|---|---|---|
| Pitch | « Organiseur familial : enfants, événements, documents » | « L'app qui simplifie **la garde** de vos enfants » |
| Différenciation | ❌ quasi nulle (concurrence gratuite : Apple/Google, Cozi…) | ✅ forte (douleur FR : déclaration Pajemploi, relation employeur-nounou) |
| Preuve à l'écran | générique | `PlanningView`, `PajemploiView` (« killer feature »), `MessagesView`, section « GARDE / Rémunération & Pajemploi » |

**Manounou B est la core value retenue** :

> Manounou enlève la charge mentale d'employer une nounou : planning de garde et
> déclaration Pajemploi mensuelle, calculés automatiquement et prêts à valider —
> pour le parent comme pour la nounou.

---

## 2. Le fossé constaté (état des lieux à l'audit)

| Feature | Promesse | Réalité constatée | Statut |
|---|---|---|---|
| **Pajemploi** | Déclaration mensuelle calculée | `PajemploiView(declaration: .sample)` — montants codés en dur (Fatou, 86 h, 472 €). `from(month:bookings:)` n'existait qu'en commentaire. | 🔴 → ✅ **corrigé** (cf. §3) |
| **Collaboration parent↔nounou** | Rôles + RLS (cf. `PERMISSIONS_MATRIX.md`) | Schéma **mono-propriétaire** (`auth.uid()` partout). « Nounou » = label texte (`carer_name`, `household_members.name`). Aucun compte, invitation, partage, ni table `nanny_children`. | 🔴 ouvert |
| **Messagerie** | Communiquer avec la nounou | `DemoConversation` / `DemoMessage` codés en dur. Pas de table ni de service. | 🔴 ouvert |
| **Statut « en direct »** | Où est mon enfant | Heuristique d'horloge (`ChildStatus.current(for:)`), pas de check-in réel. | 🟠 cosmétique |
| CRUD enfants / events / documents | — | Vrais services Supabase + DTO + upload. RLS owner-only correcte. | 🟢 solide |

**Synthèse :** la couche commodité était réelle ; la couche différenciante était démo/placeholder/inexistante — l'inverse de ce qu'exige une core value.

---

## 3. Correctif livré dans cet audit — Pajemploi réel

Première brique de P0 : rendre la killer feature réelle de bout en bout.

- **Migration** `supabase/migrations/20260614220000_planning_pajemploi_rates.sql` :
  ajoute `net_hourly_rate`, `upkeep_per_day`, `meal_per_day` sur `planning_schedules`
  (additif, non destructif, RLS inchangée).
- **Modèle** `PlanningSchedule` (Swift) : porte désormais ces taux (défauts alignés sur la migration).
- **Calcul** `PajemploiDeclaration.from(month:events:schedule:)` : déclaration calculée
  depuis les **vrais** créneaux de garde (`events` taggés « babysitter ») :
  heures = Σ durées, jours = jours distincts, salaire = heures × taux, entretien =
  jours × indemnités, net à payer = salaire + entretien.
- **Câblage** `HomeView` : la carte de rappel et l'écran Pajemploi affichent les
  montants **réels** du parent ; repli sur l'exemple de démo uniquement tant
  qu'aucun créneau n'est saisi (vitrine à l'installation).
- **Tests** `ManounouTests/SmokeTests.swift` : `PajemploiDeclarationTests` couvre le
  calcul et l'exclusion (autres mois / événements non-garde).

### Limites assumées de ce correctif
- Les taux ne sont pas encore **éditables in-app** ni relus depuis la base : ils
  utilisent le barème par défaut du foyer (DTO volontairement inchangé → zéro
  régression du save/fetch existant). Wiring DTO + éditeur de taux = prochain incrément.
- La migration n'est **pas appliquée** : le projet Supabase est en pause. À appliquer
  + valider via `get_advisors` (type `security`) après réactivation.

---

## 4. Reste à faire (priorisé)

- **P0** — Éditeur de taux (Planning) + lecture/écriture des taux via le DTO ;
  rappel mensuel de déclaration (notification le 25) ; état « mois déclaré » persisté.
- **P1** — Collaboration réelle : compte nounou + invitation + RLS par rôle conforme
  à `PERMISSIONS_MATRIX.md`. Messagerie réelle (table + realtime) **ou** retrait de l'écran démo.
- **P2** — Monétisation alignée sur la valeur Pajemploi (bulletin de salaire, historique,
  multi-nounou) plutôt que sur `max_children` / `max_documents`.
- **P3** — Hygiène : retirer le `MainTabView` legacy et ses stubs ; remplacer l'heuristique
  d'horloge du « statut » par un vrai check-in nounou.

---

## 5. Risques stratégiques

1. **Défensabilité plafonnée** sans le partenariat URSSAF (Brique 3, hors scope) :
   l'approche assistée reste une calculatrice + un rappel.
2. **Enjeux de confiance élevés** (salaire, URSSAF) : un calcul faux coûte de l'argent.
   Le calcul réel doit être testé et traçable.
3. **Dette de positionnement** tant que les docs tirent vers l'« organiseur familial ».

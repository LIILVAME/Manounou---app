# 📋 Roadmap Manounou — Résumé Exécutif

**Date :** 2025-01-13  
**Version :** 1.0.0  
**Durée totale :** 3 mois (12 semaines)

---

## 🎯 Vision MVP

**Manounou** est un carnet numérique familial permettant aux parents de :
- 👶 Gérer les profils de leurs enfants
- 📅 Planifier les événements dans un calendrier multi-vue
- 📁 Stocker et partager des documents importants
- 🔐 Tout cela dans un environnement sécurisé et bienveillant

---

## 📊 Timeline 3 Mois

```
┌─────────────────────────────────────────────────────────────┐
│  PHASE 1 : Fondations & MVP Core (Semaines 1-4)            │
│  ───────────────────────────────────────────────────────   │
│  • Setup Supabase + FlutterFlow                             │
│  • Authentification (Email + Apple)                         │
│  • Gestion enfants (CRUD complet)                           │
│  • Dashboard & Navigation                                    │
└─────────────────────────────────────────────────────────────┘
         ↓
┌─────────────────────────────────────────────────────────────┐
│  PHASE 2 : Calendrier & Documents (Semaines 5-8)           │
│  ───────────────────────────────────────────────────────   │
│  • Calendrier multi-vue (Jour/Semaine/Mois)                │
│  • CRUD événements avec détection conflits                  │
│  • Upload & gestion documents (Supabase Storage)           │
│  • Visualisation & partage documents                        │
└─────────────────────────────────────────────────────────────┘
         ↓
┌─────────────────────────────────────────────────────────────┐
│  PHASE 3 : Polish & Tests (Semaines 9-12)                    │
│  ───────────────────────────────────────────────────────   │
│  • Design System complet & UX refinement                   │
│  • Tests fonctionnels & QA                                  │
│  • Features bonus (notifications, export)                   │
│  • Préparation bêta TestFlight/Play Store                   │
└─────────────────────────────────────────────────────────────┘
```

---

## 🎯 Objectifs par Phase

### Phase 1 : Fondations (Mois 1)
**Livrable principal :** App fonctionnelle avec auth et gestion enfants

| Semaine | Objectif | Livrable Clé |
|:--------|:---------|:-------------|
| 1 | Infrastructure | Supabase + FlutterFlow configurés |
| 2 | Authentification | Login/Register/Apple fonctionnels |
| 3 | Gestion Enfants | CRUD enfants complet |
| 4 | Navigation | Dashboard + Bottom Bar |

**Critères de succès Phase 1 :**
- ✅ Utilisateurs peuvent s'inscrire et se connecter
- ✅ Utilisateurs peuvent créer/modifier/supprimer enfants
- ✅ Données isolées par utilisateur (RLS validé)
- ✅ Navigation fluide entre pages

---

### Phase 2 : Calendrier & Documents (Mois 2)
**Livrable principal :** Calendrier complet + Gestion documents

| Semaine | Objectif | Livrable Clé |
|:--------|:---------|:-------------|
| 5 | Calendrier Vue Jour/Semaine | Affichage événements + conflits |
| 6 | Calendrier Vue Mois + CRUD | Création/modification événements |
| 7 | Upload Documents | Upload + Liste documents |
| 8 | Visualisation Documents | Preview + Partage |

**Critères de succès Phase 2 :**
- ✅ Calendrier multi-vue fonctionnel
- ✅ CRUD événements avec validation
- ✅ Upload documents opérationnel
- ✅ Visualisation & partage documents

---

### Phase 3 : Polish & Tests (Mois 3)
**Livrable principal :** App prête pour bêta

| Semaine | Objectif | Livrable Clé |
|:--------|:---------|:-------------|
| 9 | Design System | Interface cohérente & animations |
| 10 | QA & Tests | Tests fonctionnels + Utilisateurs |
| 11 | Features Bonus | Notifications + Export |
| 12 | Préparation Bêta | Documentation + TestFlight/Play Store |

**Critères de succès Phase 3 :**
- ✅ 0 bug critique
- ✅ Design cohérent et accessible
- ✅ App prête bêta TestFlight/Play Store
- ✅ Documentation complète

---

## 📈 Métriques MVP

| Métrique | Objectif | Mesure |
|:---------|:---------|:-------|
| **Taux conversion onboarding** | > 70% | Inscriptions / Ouvertures app |
| **Temps création enfant** | < 30s | Temps moyen formulaire |
| **Taux création événement** | > 50% | Événements créés / Utilisateurs actifs |
| **Taux upload document** | > 30% | Documents uploadés / Utilisateurs actifs |
| **Satisfaction utilisateurs** | > 4/5 | NPS ou feedback qualitatif |
| **Stabilité app** | < 1% crash | Taux crash (Firebase Crashlytics) |

---

## 🚨 Risques & Mitigations

| Risque | Impact | Probabilité | Mitigation |
|:-------|:-------|:------------|:-----------|
| Complexité calendrier multi-vue | Élevé | Moyen | Commencer par vue jour, puis semaine, puis mois |
| Upload documents (erreurs réseau) | Moyen | Élevé | Retry automatique + messages clairs |
| Bugs RLS (isolation données) | Critique | Faible | Tests systématiques à chaque feature |
| Délais FlutterFlow | Moyen | Moyen | Prioriser fonctionnalités MVP, repousser nice-to-have |

---

## 🎯 Prochaines Actions Immédiates

### Semaine 1, Jour 1
1. **Créer instance Supabase**
   - Compte sur [supabase.com](https://supabase.com)
   - Projet "manounou-prod"
   - Exécuter script SQL (`/data/schema.sql`)

2. **Créer projet FlutterFlow**
   - Compte sur [flutterflow.io](https://flutterflow.io)
   - Projet "Manounou"
   - Connecter Supabase (URL + clé anonyme)

3. **Valider connexion**
   - Tester query simple Supabase depuis FlutterFlow
   - Vérifier RLS activé

---

## 📚 Documentation Associée

- **Roadmap complète :** `/product/ROADMAP.md`
- **Checklist Phase 1 :** `/product/CHECKLIST_PHASE1.md`
- **Schéma Supabase :** `/data/schema.sql` (à créer)
- **Policies RLS :** `/security/policies.sql` (à créer)
- **Architecture :** `/docs/architecture.md` (à créer)

---

## 🚀 Post-MVP (Roadmap future)

### Mois 4-6 : Améliorations & Partage
- Partage calendrier entre parents
- Invitation co-parents/nounous
- Notifications push
- Synchronisation temps réel

### Mois 7-9 : Intelligence & Automatisation
- Suggestions événements récurrents
- Rappels automatiques
- Export PDF rapports
- Intégration calendriers externes

### Mois 10-12 : Communauté & Évolutions
- Mode famille recomposée
- Chat famille
- Backups automatiques
- Mode hors-ligne

---

**Document maintenu par :** MultiApp Builder Team  
**Dernière mise à jour :** 2025-01-13


# 🔧 Fix : Affichage des plannings dans les vues Semaine et Mois

## 🔍 Analyse

**Problème** : Les plannings (horaires récurrents) ne s'affichaient pas dans les vues **Semaine** et **Mois** du calendrier, seulement dans la vue **Jour**.

**Cause** : Les fonctions `_buildWeekView()` et `_buildMonthView()` chargeaient uniquement les événements ponctuels, sans charger ni afficher les plannings.

---

## 🧭 Actions

### ✅ Corrections apportées

1. **Vue Semaine** (`_buildWeekView`) :
   - ✅ Ajout de `_loadWeekData()` pour charger plannings + événements
   - ✅ Affichage d'indicateurs visuels (points verts) dans la grille des jours
   - ✅ Affichage des plannings dans la liste sous la grille
   - ✅ Respect des filtres `_showSchedules` et `_showEvents`

2. **Vue Mois** (`_buildMonthView`) :
   - ✅ Ajout de `_loadMonthData()` pour charger plannings + événements
   - ✅ Affichage d'indicateurs visuels (points verts) dans la grille du calendrier
   - ✅ Affichage des plannings dans la liste sous la grille
   - ✅ Respect des filtres `_showSchedules` et `_showEvents`

3. **Fonctions helper créées** :
   - `_loadWeekData()` : Charge les événements et plannings pour une semaine
   - `_loadMonthData()` : Charge les événements et plannings pour un mois

---

## 💬 Code modifié

### Indicateurs visuels dans la grille

**Avant** : Seuls les événements affichaient un point orange/bleu

**Après** : 
- Point **orange/bleu** = événements ponctuels
- Point **vert** = plannings/horaires récurrents
- Les deux peuvent être affichés simultanément

### Affichage des plannings

Les plannings sont maintenant affichés dans des cartes `ScheduleCard` :
- Dans la vue **Semaine** : tous les plannings de la semaine
- Dans la vue **Mois** : tous les plannings du mois courant

---

## 🚀 Prochaine étape

1. **Tester** l'affichage des plannings dans les vues Semaine et Mois
2. **Vérifier** que les indicateurs visuels apparaissent correctement
3. **Tester** les filtres (boutons en haut à droite) pour masquer/afficher plannings et événements

---

## 📝 Notes techniques

- Les plannings sont chargés via `SchedulesService.getScheduleForDate()`
- La priorité est respectée : Ponctuel > Par jour > Régulier
- Les plannings sont filtrés selon l'enfant sélectionné (ou "Tous")
- Les performances sont optimisées avec un chargement à la demande par jour


# 🔧 Fix : Vue Semaine - Affichage de 3 jours avec navigation

## 🔍 Analyse

**Problème** : La vue semaine affichait 7 jours en une fois, ce qui était trop serré sur mobile et créait des problèmes d'overflow.

**Solution** : Afficher seulement **3 jours à la fois** (jour précédent, jour sélectionné, jour suivant) avec navigation horizontale.

---

## 🧭 Actions

### ✅ Modifications apportées

1. **Affichage de 3 jours** :
   - Jour précédent (gauche)
   - Jour sélectionné (centre, mis en évidence)
   - Jour suivant (droite)

2. **Navigation** :
   - **Boutons fléchés** en haut (← →) pour naviguer
   - **Swipe horizontal** : swipe gauche = jour suivant, swipe droite = jour précédent
   - Date formatée au centre : "Lundi 06 Novembre 2025"

3. **Chargement optimisé** :
   - Nouvelle fonction `_loadDaysData()` qui charge uniquement les 3 jours visibles
   - Plus performant que de charger toute la semaine

4. **UI améliorée** :
   - Colonnes plus larges (3 au lieu de 7)
   - Meilleure lisibilité sur mobile
   - Pas d'overflow

---

## 💬 Code modifié

### Structure de la vue semaine

```dart
// Calcul des 3 jours à afficher
final previousDay = _selectedDate.subtract(const Duration(days: 1));
final nextDay = _selectedDate.add(const Duration(days: 1));
final visibleDays = [previousDay, _selectedDate, nextDay];
```

### Navigation

- **Boutons** : `IconButton` avec chevrons gauche/droite
- **Swipe** : `GestureDetector` avec `onHorizontalDragEnd`
  - Swipe gauche (velocity > 0) → jour précédent
  - Swipe droite (velocity < 0) → jour suivant

### Chargement des données

- **Fonction** : `_loadDaysData(context, visibleDays)`
- Charge uniquement les événements et plannings des 3 jours visibles
- Plus rapide et efficace

---

## 🚀 Prochaine étape

1. **Tester** la navigation avec les flèches
2. **Tester** le swipe horizontal
3. **Vérifier** que les 3 jours s'affichent correctement
4. **Valider** qu'il n'y a plus d'overflow

---

## 📝 Notes techniques

### Amélioration UX

- **Avant** : 7 jours serrés → difficile à lire
- **Après** : 3 jours espacés → meilleure lisibilité

### Performance

- **Avant** : Charge 7 jours même si seulement 3 visibles
- **Après** : Charge uniquement les 3 jours nécessaires

### Navigation

- **Boutons** : Accessible et visible
- **Swipe** : Gesture naturelle sur mobile
- **Date au centre** : Indique clairement le jour sélectionné

---

**Document maintenu par :** MultiApp Builder Team


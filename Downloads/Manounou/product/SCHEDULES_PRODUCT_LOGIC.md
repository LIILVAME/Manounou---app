# 🧭 Product Logic — Gestion des Horaires

**Date :** 2025-01-13  
**Feature :** Horaires de dépôt/récupération  
**Objectif :** Logique métier claire et robuste

---

## 🎯 Priorité des Horaires

**Ordre de priorité (du plus spécifique au plus général) :**

1. **Ponctuel (Exception)** → Priorité maximale
   - Date spécifique avec horaire
   - Écrase les horaires réguliers pour cette date

2. **Par Jour (Variable)** → Priorité moyenne
   - Horaire spécifique à un jour de la semaine
   - S'applique chaque semaine sauf exception

3. **Régulier** → Priorité minimale
   - Horaire identique tous les jours
   - Base par défaut, peut être écrasé

**Logique :**
```dart
// Pour une date donnée, chercher dans cet ordre :
1. schedule_items avec date = date (ponctuel)
2. schedule_items avec day_of_week = date.weekday (par jour)
3. schedule_items avec day_of_week = null (régulier, tous les jours)
```

---

## 🔄 Règles Métier

### 1. Gestion de Conflits

**Détection automatique :**
- 2 horaires se chevauchent si :
  - Même jour/enfant
  - `drop_off_time < other.pick_up_time && pick_up_time > other.drop_off_time`

**Résolution :**
- Afficher badge "Conflit" (orange)
- Permettre quand même l'enregistrement (parent décide)
- Suggestion : "Voulez-vous remplacer l'autre horaire ?"

---

### 2. Duplication

**Fonctionnalité :** "Copier vers [autre enfant]"

**Flow :**
1. Menu "..." sur planning
2. "Copier vers..."
3. Sélection enfant
4. Création automatique avec mêmes horaires

**Validation :**
- Vérifier que l'enfant cible n'a pas déjà un planning actif
- Proposer de fusionner ou remplacer

---

### 3. Héritage des Horaires

**Cas :** Planning régulier + Exception ponctuelle

**Logique :**
- L'exception hérite du planning régulier
- L'exception peut modifier uniquement les horaires spécifiques
- Si exception supprimée → Retour au régulier

**Structure :**
- `schedule_items.parent_schedule_item_id` → Référence à l'item régulier
- `schedule_items.is_exception = true` → Flag exception

---

### 4. Dépôt sans Récupération

**Cas validé :** Dépôt peut exister sans récupération

**UI :**
- Bouton "Récup" reste vide/disabled si pas de récup
- Afficher "Dépôt uniquement" dans résumé

**Exemple :** Garde partagée, l'autre parent récupère

---

## 🗂️ Structure de Données

**Hiérarchie :**
```
Enfant
  └── Schedule (type: regular|daily|punctual)
        └── ScheduleItem[]
              ├── day_of_week (0-6) OU date (DATE)
              ├── drop_off_time (TIME)
              ├── pick_up_time (TIME)
              └── is_exception (BOOLEAN)
```

**Relations :**
- `children.id` → `schedules.child_id` (1:N)
- `schedules.id` → `schedule_items.schedule_id` (1:N)
- `schedule_items.parent_schedule_item_id` → Auto-référence (exception)

---

## ✅ Validation

### Validation Automatique

**Contraintes :**
- `drop_off_time < pick_up_time` (si les deux présents)
- Pas de chevauchement avec autres horaires (warning, pas erreur)
- Date future pour ponctuel (ou date passée acceptée si historique)

**Messages :**
- ❌ "Heure de récupération doit être après dépôt"
- ⚠️ "Conflit avec [autre horaire] - Voulez-vous continuer ?"

---

## 📋 Flow d'ajout/modification

### Flow Optimisé (≤ 3 clics)

**Ajout :**
1. Tap "Ajouter horaires" → Étape 1 (Type) → **1 clic**
2. Tap "Continuer" → Étape 2 (Saisie) → **2 clics**
3. Tap "Suivant" → Étape 3 (Résumé) → **3 clics**
4. Tap "Enregistrer" → **4 clics** (ou auto-save après 3)

**Modification :**
1. Tap "Modifier" sur carte jour → Étape 2 (Saisie) → **1 clic**
2. Modifier horaires → **2 clics** (tap dépôt/récup)
3. Tap "Enregistrer" → **3 clics**

**Optimisation :** Auto-save après Étape 3 → Réduit à **3 clics**

---

## 🧪 Cas de Test

### 1. Même jour, heures différentes

**Test :**
- Lundi : Dépôt 08:00, Récup 12:00
- Mardi : Dépôt 09:00, Récup 17:00

**Résultat attendu :** ✅ 2 horaires distincts affichés

---

### 2. Dépôt sans récupération

**Test :**
- Mercredi : Dépôt 08:00, Récup NULL

**Résultat attendu :** ✅ Affiche "Dépôt : 08:00" seulement

---

### 3. Exception sur journée récurrente

**Test :**
- Planning régulier : Lundi 08:00-17:00
- Exception : Lundi 25/12 (Noël) 09:00-16:00

**Résultat attendu :** ✅ 25/12 affiche 09:00-16:00, autres lundis 08:00-17:00

---

### 4. Copie planning entre enfants

**Test :**
- Clara : Planning "Garderie" (Lun-Ven 08:00-17:00)
- Copier vers Amidou

**Résultat attendu :** ✅ Amidou a même planning, indépendant

---

## 📱 Responsive Design

**Petits écrans (iPhone SE / mini) :**
- Cartes jour empilées verticalement
- TimePicker en plein écran (pas modal)
- Boutons taille minimale 44x44px (touch target)

**Tests :**
- ✅ Flow complet sur iPhone SE (320px)
- ✅ TimePicker accessible (scroll sans blocage)
- ✅ Résumé lisible (pas de texte tronqué)

---

**Document maintenu par :** MultiApp Builder Team  
**Dernière mise à jour :** 2025-01-13


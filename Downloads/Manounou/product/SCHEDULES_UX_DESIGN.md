# 🎯 UX Design — Gestion des Horaires (Schedules)

**Date :** 2025-01-13  
**Feature :** Horaires de dépôt/récupération  
**Objectif :** Flow ultra-fluide ≤ 3 clics

---

## 🧩 Parcours Utilisateurs Principaux

### 1️⃣ Parcours "Régulier" (Horaire Hebdomadaire Récurrent)

**Cas d'usage :** Garderie/Crèche avec horaires fixes chaque semaine

**Flow :**
1. **Étape 1 : Sélection Type** → "Régulier"
2. **Étape 2 : Saisie Globale** → "Appliquer à tous" → Saisie dépôt/récup
3. **Étape 3 : Résumé** → Confirmation

**Clics :** 3 clics minimum (sans saisie)

---

### 2️⃣ Parcours "Par Jour" (Horaires Variables)

**Cas d'usage :** Horaires différents selon les jours (ex: Mercredi court, Vendredi long)

**Flow :**
1. **Étape 1 : Sélection Type** → "Par jour"
2. **Étape 2 : Saisie Jour par Jour** → Carte jour → Dépôt/Récup par jour
3. **Étape 3 : Résumé** → Vue hebdomadaire avec tous les horaires

**Clics :** 3 clics + 5 interactions (un par jour)

---

### 3️⃣ Parcours "Ponctuel" (Exception/Date Spécifique)

**Cas d'usage :** Exception sur une date (ex: Jour férié, sortie scolaire)

**Flow :**
1. **Étape 1 : Sélection Type** → "Ponctuel" → Sélection date
2. **Étape 2 : Saisie Horaires** → Dépôt/Récup pour la date
3. **Étape 3 : Résumé** → Confirmation date + horaires

**Clics :** 3 clics + 1 sélection date

---

## 🎨 Interface 3 Étapes

### Étape 1 : Type de Planning

**Écran :** `ScheduleTypePage`

**Éléments :**
- Titre : "Quel type d'horaire ?"
- 3 cartes grandes (style FamPlan) :
  - 🗓️ **Régulier** : "Horaires identiques chaque semaine"
  - 📅 **Par jour** : "Horaires différents selon les jours"
  - 📌 **Ponctuel** : "Exception ou date spécifique"
- Bouton "Continuer" (teal-green)

**Micro-interaction :** Animation légère au survol, vibration au tap

---

### Étape 2 : Saisie Horaires

**Écran :** `ScheduleInputPage`

**Composants :**
- **Checkbox "Appliquer à tous"** (si type = Régulier)
- **Cartes Jour** (5 jours : Lun-Ven) avec :
  - Nom du jour (gras)
  - Bouton "Dépot" (si vide) ou horaire affiché (si rempli)
  - Bouton "Récup" (si vide) ou horaire affiché (si rempli)
  - Badge "Exception" si modification ponctuelle
- **TimePicker Modal** (slide-up depuis le bas)
  - Design : Rouleaux horaires (iOS style)
  - Couleurs : Teal-green pour sélection
  - Animation : Slide + fade

**Logique :**
- Tap sur "Dépot" → Ouvre TimePicker → Sauvegarde → Met à jour carte
- Tap sur "Récup" → Ouvre TimePicker → Sauvegarde → Met à jour carte
- Dépôt peut exister sans récupération (cas validé)

---

### Étape 3 : Résumé & Validation

**Écran :** `ScheduleSummaryPage`

**Éléments :**
- **Vue hebdomadaire** avec horaires consolidés
- **Format :** "08:00 - 17:00" par jour
- **Badge conflit** si chevauchement détecté
- **Bouton "Modifier"** → Retour Étape 2
- **Bouton "Enregistrer"** (teal-green) → Validation finale

**Feedback :**
- Snackbar : "Horaires enregistrés ✅"
- Animation : Confetti léger (optionnel)

---

## 🎨 Design Time Picker Mobile

**Style :** iOS Native Wheel Picker

**Composants :**
- **2 rouleaux** : Heures (0-23) + Minutes (0-59, par pas de 5)
- **Couleurs :**
  - Fond : Blanc
  - Sélection : Teal-green highlight
  - Texte : Gris foncé → Noir (quand sélectionné)
- **Animation :** Spring animation (bounce léger)
- **Accessibilité :** Haptic feedback au scroll

**Code couleur :**
- Dépôt : Teal-green (#4ECDC4)
- Récup : Orange (#FF6B6B)

---

## 📱 Carte Jour

**Composant :** `DayScheduleCard`

**Structure :**
```
┌─────────────────────────────┐
│ Lundi                       │
│                             │
│ [Dépot]  [Récup]            │
│  08:00     17:00            │
│                             │
│ [+ Exception] (si applicable)│
└─────────────────────────────┘
```

**États :**
- **Vide :** Boutons "Dépot" / "Récup" (outlined)
- **Rempli :** Horaires affichés (fond coloré)
- **Conflit :** Badge orange "Conflit"
- **Exception :** Badge "Exception"

---

## 🗓️ Vue Calendrier Compacte

**Composant :** `ScheduleCalendarView`

**Visualisation :**
- **Dots colorés** sous chaque jour :
  - 🔵 Bleu = Dépôt uniquement
  - 🟢 Vert = Dépôt + Récup
  - 🟠 Orange = Conflit
- **Tap sur jour** → Ouvre détails horaires
- **Légende** en bas

---

## 💬 Messages-Guides Bienveillants

**États vides :**
- "Aucun horaire configuré" → "Ajoutez votre premier horaire pour Clara"

**Confirmation :**
- "Horaires enregistrés ! ✅" (Snackbar)

**Conflit :**
- "⚠️ Attention : Conflit détecté avec [autre événement]"

**Modification :**
- "Horaires modifiés avec succès ✅"

---

## 🎨 Palette & Typographie

**Couleurs :**
- Dépôt : Teal-green (#4ECDC4)
- Récup : Orange (#FF6B6B)
- Conflit : Orange foncé (#FF6B6B)
- Fond : Blanc (#FFFFFF)
- Texte : Gris foncé (#2C3E50)

**Typographie :**
- Titres : SF Pro Display, Bold, 24px
- Corps : SF Pro Display, Regular, 16px
- Horaires : SF Mono, Medium, 18px

---

## 📋 Flow Ajout/Modification

**Flow optimal :**
1. Tap "Ajouter horaires" → Étape 1 (Type)
2. Tap "Continuer" → Étape 2 (Saisie)
3. Tap "Suivant" → Étape 3 (Résumé)
4. Tap "Enregistrer" → Validation

**Total : 4 clics** (optimisable à 3 avec auto-save)

---

**Document maintenu par :** MultiApp Builder Team  
**Dernière mise à jour :** 2025-01-13


# 🎯 Prochaines Étapes FlutterFlow — Manounou

**Après setup initial FlutterFlow**

---

## ✅ Ce qui est fait

- ✅ Supabase connecté
- ✅ Tables importées
- ✅ Authentication configurée
- ✅ Pages créées (squelettes)

---

## 🚀 Semaine 1 — Jour 2 : Workflows Authentication

### 1. Créer Workflow Sign Up
**Page :** `RegisterPage`

1. Sélectionner bouton "S'inscrire"
2. Action : Supabase → Create Account
3. Variables : email, password depuis inputs
4. Success : Navigate to `OnboardingPage`
5. Error : Show snackbar avec message

**Test :** Créer un compte test et vérifier redirection

---

### 2. Créer Workflow Sign In
**Page :** `LoginPage`

1. Sélectionner bouton "Se connecter"
2. Action : Supabase → Sign In
3. Variables : email, password depuis inputs
4. Success : Navigate to `DashboardPage`
5. Error : Show snackbar avec message

**Test :** Se connecter avec compte test

---

### 3. Créer Workflow Sign Out
**Page :** `ProfilePage`

1. Sélectionner bouton "Déconnexion"
2. Action : Supabase → Sign Out
3. After : Navigate to `LoginPage`

**Test :** Déconnexion et vérifier redirection

---

## 🚀 Semaine 1 — Jour 3 : Pages UI Auth

### 1. Designer LoginPage
- TextField Email (avec icône)
- TextField Password (avec icône, obscure)
- ElevatedButton "Se connecter"
- TextButton "Créer un compte"
- OutlinedButton "Continuer avec Apple" (si disponible)

### 2. Designer RegisterPage
- TextField Email
- TextField Password
- TextField Confirm Password
- ElevatedButton "S'inscrire"
- TextButton "Déjà un compte ?"

### 3. Designer OnboardingPage
- Logo/Icone
- Titre "Bienvenue dans Manounou !"
- Description
- ElevatedButton "Commencer"

---

## 🚀 Semaine 2 : Gestion Enfants

### 1. ChildrenListPage
- ListView avec enfants
- FloatingActionButton "Ajouter"
- Card pour chaque enfant (prénom, photo, âge)
- Tap sur enfant → Navigate to `ChildDetailPage`

### 2. ChildFormPage
- TextField "Prénom"
- DatePicker "Date de naissance"
- TextField "Notes" (multiline)
- Bouton "Enregistrer"
- Workflow Create/Update

### 3. ChildDetailPage
- Affichage infos enfant
- Bouton "Modifier"
- Bouton "Supprimer" (avec confirmation)

---

## 🚀 Semaine 3 : Dashboard & Navigation

### 1. DashboardPage
- Cards cliquables :
  - "Mes enfants" (compteur)
  - "Événements à venir"
  - "Documents récents"
- Navigation vers pages dédiées

### 2. Bottom Navigation Bar
- Configurer 5 onglets
- Navigation entre pages
- Highlight page active

---

## 📋 Checklist Progressive

### Semaine 1
- [x] Setup FlutterFlow
- [x] Connecter Supabase
- [x] Importer tables
- [ ] Workflows Auth (Sign Up, Sign In, Sign Out)
- [ ] Designer pages Auth
- [ ] Tester authentification

### Semaine 2
- [ ] ChildrenListPage (UI + workflow Read)
- [ ] ChildFormPage (UI + workflow Create)
- [ ] ChildDetailPage (UI + workflows Update/Delete)
- [ ] Tester CRUD enfants

### Semaine 3
- [ ] DashboardPage (avec vraies données)
- [ ] Bottom Navigation Bar
- [ ] Navigation complète
- [ ] Tests finaux Phase 1

---

## 🔗 Ressources

- **Guide complet** : `/docs/FLUTTERFLOW_SETUP_COMPLETE.md`
- **Quick Reference** : `/docs/FLUTTERFLOW_QUICK_REFERENCE.md`
- **Roadmap** : `/product/ROADMAP.md`
- **Code de référence** : `/flutterflow_export/`

---

**Document maintenu par :** MultiApp Builder Team  
**Dernière mise à jour :** 2025-01-13


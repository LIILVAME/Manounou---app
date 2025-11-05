# 🚀 Manounou — Flutter Export

**Structure de base Flutter pour Manounou**  
**Compatible avec FlutterFlow export**

---

## 📁 Structure

```
lib/
├── main.dart                    # Point d'entrée + init Supabase
├── core/
│   ├── app_container.dart       # Container avec Bottom Nav
│   ├── routes/
│   │   └── app_router.dart     # Routes GoRouter
│   └── services/
│       └── auth_service.dart    # Service authentification
└── pages/
    ├── auth/
    │   ├── login_page.dart
    │   ├── register_page.dart
    │   └── onboarding_page.dart
    ├── dashboard/
    │   └── dashboard_page.dart
    ├── children/
    │   ├── children_list_page.dart
    │   ├── child_form_page.dart
    │   └── child_detail_page.dart
    ├── events/
    │   └── events_page.dart
    ├── documents/
    │   └── documents_page.dart
    └── profile/
        └── profile_page.dart
```

---

## ⚙️ Configuration

### 1. Remplacer les credentials Supabase

Dans `lib/main.dart`, remplacer :
```dart
await Supabase.initialize(
  url: 'YOUR_SUPABASE_URL',      // ← Remplacer
  anonKey: 'YOUR_SUPABASE_ANON_KEY', // ← Remplacer
);
```

**Voir :** `/docs/SUPABASE_CREDENTIALS.md`

---

## 🚀 Installation

```bash
cd flutterflow_export
flutter pub get
cd ios && pod install && cd ..
./fix_file_picker.sh    # Corriger l'erreur file_picker iOS (si nécessaire)
./fix_sdwebimage.sh     # Corriger les erreurs SDWebImage iOS (si nécessaire)
flutter run
```

**Note iOS** : 
- Si vous compilez pour iOS et rencontrez une erreur `file_picker`, exécutez `./fix_file_picker.sh` après chaque `flutter pub get`.
- Si vous rencontrez des erreurs SDWebImage (double-quoted includes), exécutez `./fix_sdwebimage.sh` après chaque `pod install`.
- Si vous rencontrez des erreurs `sqflite_darwin` (Flutter/Flutter.h not found), exécutez `./fix_sqflite_darwin.sh` après chaque `pod install`.
- Voir `/docs/FIX_FILE_PICKER_IOS_ERROR.md`, `/docs/FIX_SDWEBIMAGE_IOS_ERROR.md` et `/docs/FIX_SQFLITE_DARWIN_IOS_ERROR.md` pour plus de détails.

---

## 📱 Pages Implémentées

### ✅ Complètes
- `LoginPage` — Authentification email/password + Apple
- `RegisterPage` — Inscription
- `OnboardingPage` — Page de bienvenue
- `DashboardPage` — Vue d'ensemble (squelette)
- `ProfilePage` — Profil utilisateur + déconnexion

### ⚠️ Squelettes (à implémenter)
- `ChildrenListPage` — Liste enfants
- `ChildFormPage` — Formulaire enfant
- `ChildDetailPage` — Détails enfant
- `EventsPage` — Calendrier
- `DocumentsPage` — Documents

---

## 🔧 Services

### AuthService
- `signUp()` — Inscription
- `signIn()` — Connexion
- `signInWithApple()` — Connexion Apple
- `signOut()` — Déconnexion

---

## 🎨 Design System

- **Couleur primaire** : Pastel Pink (#FFB6C1)
- **Police** : SF Rounded (iOS) / Nunito (Android)
- **Style** : Material 3 avec bordures arrondies

---

## 📚 Documentation

- **Setup FlutterFlow** : `/docs/FLUTTERFLOW_SETUP.md`
- **Roadmap** : `/product/ROADMAP.md`
- **Checklist Phase 1** : `/product/CHECKLIST_PHASE1.md`

---

## 🐛 Notes

- Les pages enfants, événements et documents sont des squelettes
- À implémenter selon la roadmap Phase 1
- Les workflows CRUD Supabase seront ajoutés progressivement

---

**Document maintenu par :** MultiApp Builder Team  
**Dernière mise à jour :** 2025-01-13


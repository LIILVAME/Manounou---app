# 🐛 Troubleshooting — Manounou Flutter

**Solutions aux problèmes courants**

---

## ⚠️ Warnings file_picker

### Problème
```
Package file_picker:linux references file_picker:linux as the default
plugin, but it does not provide an inline implementation.
```

### Solution
**Ces warnings sont non bloquants.** Ils indiquent simplement que `file_picker` n'a pas d'implémentation inline pour certaines plateformes. L'app fonctionnera normalement.

**Si tu veux les corriger :**
```bash
# Mettre à jour file_picker
flutter pub upgrade file_picker

# Ou utiliser une version plus récente dans pubspec.yaml
# file_picker: ^10.3.3
```

---

## ❌ Erreur : "No devices found"

### Problème
```
No supported devices connected.
```

### Solutions

#### 1. iOS Simulator
```bash
# Ouvrir Simulator
open -a Simulator

# Vérifier les devices
flutter devices

# Lancer
flutter run
```

#### 2. Android Emulator
```bash
# Ouvrir Android Studio
# Device Manager → Créer un AVD
# Lancer l'émulateur

# Puis :
flutter run
```

#### 3. Web (toujours disponible)
```bash
flutter run -d chrome
```

---

## ❌ Erreur : "Command not found: flutter"

### Solution
```bash
# Vérifier l'installation
which flutter

# Si pas installé :
# 1. Télécharger Flutter : https://flutter.dev/docs/get-started/install
# 2. Ajouter au PATH
export PATH="$PATH:`pwd`/flutter/bin"
```

---

## ❌ Erreur : "Supabase connection failed"

### Problème
L'app ne se connecte pas à Supabase.

### Solutions
1. **Vérifier les credentials** dans `lib/main.dart`
2. **Vérifier la connexion internet**
3. **Vérifier que Supabase est actif** : [supabase.com/dashboard](https://supabase.com/dashboard)

### Test de connexion
```dart
// Dans main.dart, après Supabase.initialize
try {
  final response = await Supabase.instance.client
      .from('users')
      .select('count')
      .count();
  print('✅ Supabase connecté: ${response.count}');
} catch (e) {
  print('❌ Erreur Supabase: $e');
}
```

---

## ❌ Erreur : "Package not found"

### Solution
```bash
# Nettoyer et réinstaller
flutter clean
flutter pub get
flutter run
```

---

## ❌ Erreur : "Build failed"

### Solutions

#### 1. Nettoyer le build
```bash
flutter clean
flutter pub get
flutter run
```

#### 2. Vérifier les versions
```bash
flutter --version
flutter doctor
```

#### 3. Mettre à jour Flutter
```bash
flutter upgrade
```

---

## ❌ Erreur : "Platform not supported"

### Problème
Certaines fonctionnalités ne fonctionnent pas sur toutes les plateformes.

### Solutions
- **iOS/Android :** Utiliser un émulateur ou device physique
- **Web :** Certaines fonctionnalités (Apple Sign In) peuvent être limitées

---

## ✅ Vérifications Rapides

### 1. Flutter installé
```bash
flutter --version
flutter doctor
```

### 2. Dépendances installées
```bash
cd flutterflow_export
flutter pub get
```

### 3. Devices disponibles
```bash
flutter devices
```

### 4. Build réussit
```bash
flutter build apk --debug  # Android
flutter build ios --debug  # iOS
```

---

## 📚 Ressources

- **Flutter Docs** : [flutter.dev/docs](https://flutter.dev/docs)
- **Flutter Troubleshooting** : [flutter.dev/docs/get-started/install](https://flutter.dev/docs/get-started/install)
- **Supabase Flutter** : [supabase.com/docs/guides/getting-started/flutter](https://supabase.com/docs/guides/getting-started/flutter)

---

**Document maintenu par :** MultiApp Builder Team  
**Dernière mise à jour :** 2025-01-13


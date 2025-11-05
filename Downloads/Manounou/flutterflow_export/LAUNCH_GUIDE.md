# 🚀 Guide de Lancement — Manounou Flutter

**Comment lancer l'application Manounou**

---

## ✅ État Actuel

- ✅ Dépendances installées (`flutter pub get` réussi)
- ✅ Code compilé sans erreurs
- ⚠️ Warnings `file_picker` (non bloquants, peuvent être ignorés)
- ⚠️ Aucun device connecté

---

## 📱 Option 1 : Lancer sur Émulateur iOS

### Prérequis
- macOS avec Xcode installé
- Émulateur iOS configuré

### Étapes
```bash
cd flutterflow_export

# Lister les devices disponibles
flutter devices

# Si un iPhone est disponible, lancer :
flutter run

# Ou spécifier explicitement :
flutter run -d "iPhone 15 Pro"
```

### Si aucun émulateur n'est disponible
```bash
# Ouvrir Xcode
open -a Simulator

# Puis dans un autre terminal :
flutter run
```

---

## 🤖 Option 2 : Lancer sur Émulateur Android

### Prérequis
- Android Studio installé
- Émulateur Android configuré

### Étapes
```bash
cd flutterflow_export

# Lancer l'émulateur Android depuis Android Studio
# Ou via ligne de commande :
emulator -avd <nom_émulateur>

# Puis lancer Flutter :
flutter run
```

---

## 🌐 Option 3 : Lancer sur Web (Chrome)

### Étapes
```bash
cd flutterflow_export

# Lancer sur Chrome
flutter run -d chrome

# Ou spécifier le navigateur :
flutter run -d edge
flutter run -d safari
```

**Note :** Certaines fonctionnalités (comme Supabase Auth avec Apple) peuvent ne pas fonctionner sur web.

---

## 📲 Option 4 : Lancer sur Device Physique

### iOS (iPhone/iPad)
```bash
# Connecter le device via USB
# Autoriser l'ordinateur sur le device

flutter run -d <device-id>

# Pour trouver l'ID du device :
flutter devices
```

### Android
```bash
# Activer le mode développeur sur Android
# Activer USB Debugging

flutter run -d <device-id>

# Pour trouver l'ID du device :
flutter devices
```

---

## 🔍 Vérifier les Devices Disponibles

```bash
flutter devices
```

**Sortie attendue :**
```
2 connected devices:

iPhone 15 Pro (mobile) • 12345678-1234-1234-1234-123456789012 • ios • com.apple.CoreSimulator.SimRuntime.iOS-17-0 (simulator)
Chrome (web) • chrome • web-javascript • Google Chrome 120.0.0.0
```

---

## 🐛 Dépannage

### Problème : "No devices found"
**Solutions :**
1. **iOS :** Ouvrir Xcode → Window → Devices and Simulators → Créer un simulateur
2. **Android :** Ouvrir Android Studio → Device Manager → Créer un AVD
3. **Web :** Utiliser `flutter run -d chrome`

### Problème : "Command not found: flutter"
**Solution :**
```bash
# Vérifier que Flutter est installé
which flutter

# Si pas installé, suivre : https://flutter.dev/docs/get-started/install
```

### Problème : Erreurs de compilation
**Solution :**
```bash
# Nettoyer et réinstaller
flutter clean
flutter pub get
flutter run
```

### Problème : Warnings file_picker
**Solution :** Ces warnings sont non bloquants et peuvent être ignorés. Ils n'empêchent pas l'app de fonctionner.

---

## 📋 Checklist Rapide

- [ ] Flutter installé (`flutter --version`)
- [ ] Dépendances installées (`flutter pub get`)
- [ ] Device/émulateur disponible (`flutter devices`)
- [ ] Credentials Supabase configurés dans `main.dart`
- [ ] Lancer l'app (`flutter run`)

---

## 🎯 Prochaines Étapes

Une fois l'app lancée :
1. ✅ Vérifier que la page Login s'affiche
2. ✅ Tester l'inscription (Register)
3. ✅ Tester la connexion (Login)
4. ✅ Vérifier la redirection vers Dashboard

---

## 📚 Ressources

- **Flutter Docs** : [flutter.dev/docs](https://flutter.dev/docs)
- **Setup FlutterFlow** : `/docs/FLUTTERFLOW_SETUP_COMPLETE.md`
- **Roadmap** : `/product/ROADMAP.md`

---

**Document maintenu par :** MultiApp Builder Team  
**Dernière mise à jour :** 2025-01-13


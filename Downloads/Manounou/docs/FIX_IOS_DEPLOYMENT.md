# 🔧 Fix — Problème d'installation iOS

## Problème
Le build Xcode réussit, mais l'installation/lancement sur l'iPhone échoue avec un timeout.

## Solutions

### Solution 1 : Lancer depuis Xcode (Recommandé)
```bash
cd /Users/vametoure/Downloads/Manounou/flutterflow_export/ios
open Runner.xcworkspace
```
**OU** depuis le dossier racine :
```bash
cd flutterflow_export
open ios/Runner.xcworkspace
```
Puis dans Xcode :
1. Sélectionner votre iPhone dans la liste des appareils
2. Cliquer sur "Product > Run" (⌘R)

### Solution 2 : Augmenter le timeout Flutter
```bash
cd flutterflow_export
flutter run -d "iPhone de Vamé" --device-timeout=60
```

### Solution 3 : Utiliser un câble USB (plus fiable)
1. Connecter l'iPhone via USB
2. Autoriser l'ordinateur sur l'iPhone
3. Exécuter : `flutter run -d "iPhone de Vamé"`

### Solution 4 : Vérifications
1. ✅ iPhone déverrouillé
2. ✅ Mode développeur activé (Settings > Privacy & Security > Developer Mode)
3. ✅ Appareil fait confiance à cet ordinateur
4. ✅ Certificat de développement valide dans Xcode (Preferences > Accounts)

### Solution 5 : Nettoyer et rebuilder
```bash
cd flutterflow_export
flutter clean
flutter pub get
cd ios && pod install && cd ..
flutter run -d "iPhone de Vamé"
```

## Vérification du build
Le build a réussi ✅, donc le problème est uniquement lors de l'installation/lancement.


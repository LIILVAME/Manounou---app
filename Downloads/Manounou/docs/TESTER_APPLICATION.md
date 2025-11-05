# 🧪 Guide de Test - Application Manounou

## 📱 Méthodes de Test Disponibles

### ✅ Option 1 : Tester sur Web (Le plus simple)

```bash
cd flutterflow_export
flutter run -d chrome
```

**Avantages :**
- ✅ Pas besoin d'appareil physique
- ✅ Démarrage rapide
- ✅ Teste toutes les fonctionnalités UI/UX
- ✅ Parfait pour tester les animations

**Limitations :**
- ❌ Pas de test de caméra/galerie (upload photos)
- ❌ Pas de test de file picker natif

---

### ✅ Option 2 : Simulateur iOS (Recommandé pour iOS)

#### Étape 1 : Ouvrir le simulateur

```bash
# Depuis Xcode
open -a Simulator

# OU depuis le terminal
xcrun simctl list devices available
xcrun simctl boot "iPhone 15 Pro"  # Remplacer par le nom de votre simulateur
```

#### Étape 2 : Lancer l'app

```bash
cd flutterflow_export
flutter run
```

**Avantages :**
- ✅ Teste le comportement iOS natif
- ✅ Pas besoin d'appareil physique
- ✅ Teste toutes les fonctionnalités

---

### ✅ Option 3 : iPhone Physique via Xcode (Recommandé)

#### Étape 1 : Préparer l'iPhone

1. **Déverrouiller l'iPhone**
2. **Activer le Developer Mode** :
   - Aller dans **Réglages > Confidentialité et sécurité**
   - Activer **Mode développeur**
   - Redémarrer l'iPhone si demandé
3. **Faire confiance à l'ordinateur** :
   - Connecter l'iPhone avec un **câble USB**
   - Sur l'iPhone : "Faire confiance à cet ordinateur" → Accepter

#### Étape 2 : Ouvrir le projet dans Xcode

```bash
cd flutterflow_export/ios
open Runner.xcworkspace
```

#### Étape 3 : Configurer le projet

1. Dans Xcode, sélectionner **Runner** dans le projet
2. Aller dans **Signing & Capabilities**
3. Sélectionner votre **Team** (Apple ID)
4. Xcode créera automatiquement un **provisioning profile**

#### Étape 4 : Lancer depuis Xcode

1. Sélectionner votre **iPhone** dans la barre d'outils (en haut)
2. Cliquer sur le bouton **▶️ Run** (ou ⌘R)
3. Si demandé, autoriser l'installation sur l'iPhone

**Avantages :**
- ✅ Test réel sur appareil physique
- ✅ Teste toutes les fonctionnalités natives
- ✅ Meilleure performance

---

### ✅ Option 4 : iPhone Physique via Flutter (Wireless)

⚠️ **Attention** : Nécessite que l'iPhone soit déverrouillé et en Developer Mode

```bash
cd flutterflow_export

# Lancer sur votre iPhone (remplacer par l'ID de votre iPhone)
flutter run -d 00008150-0016350136B8401C  # iPhone de Vamé
# OU
flutter run -d 00008120-0011786E0C7BC01E  # iPhone de Tamara
```

**Si erreur "code -27" :**
- Vérifier que l'iPhone est **déverrouillé**
- Vérifier que le **Developer Mode** est activé
- Essayer de **connecter l'iPhone avec un câble USB** d'abord
- Redémarrer l'iPhone et le Mac

---

## 🚨 Dépannage

### Problème : "Unable to find any emulator"

**Solution :**
```bash
# Ouvrir Xcode
open -a Xcode

# Dans Xcode : Window > Devices and Simulators
# Créer un nouveau simulateur iOS si nécessaire
```

### Problème : "Code signing error"

**Solution :**
1. Ouvrir `Runner.xcworkspace` dans Xcode
2. Sélectionner **Runner** → **Signing & Capabilities**
3. Sélectionner votre **Team** (Apple ID)
4. Cocher **Automatically manage signing**

### Problème : "Device not found"

**Solution :**
```bash
# Vérifier les appareils
flutter devices

# Si iPhone en wireless ne fonctionne pas, utiliser un câble USB
# OU tester sur simulateur/web
```

### Problème : "Build failed"

**Solution :**
```bash
cd flutterflow_export
flutter clean
flutter pub get
cd ios
pod install
cd ..
flutter run
```

---

## 🎯 Test Recommandé (Ordre de Priorité)

1. **🌐 Web** → Pour tester rapidement les animations et l'UI
2. **📱 Simulateur iOS** → Pour tester le comportement iOS
3. **📱 iPhone Physique** → Pour le test final complet

---

## ✅ Checklist de Test

### Animations
- [ ] Boutons : Scale au tap
- [ ] FAB : Rotation et scale
- [ ] Avatars : Fade-in au chargement
- [ ] Cartes : Animation d'entrée
- [ ] Empty states : Animation du bouton

### Fonctionnalités
- [ ] Connexion/Inscription
- [ ] Ajout d'enfant
- [ ] Upload photo enfant
- [ ] Création d'événement
- [ ] Upload document
- [ ] Navigation entre pages

---

## 📞 Support

Si le problème persiste, vérifier :
1. Les logs dans Xcode Console
2. Les logs Flutter : `flutter run -v`
3. Les logs iOS : Console.app sur Mac


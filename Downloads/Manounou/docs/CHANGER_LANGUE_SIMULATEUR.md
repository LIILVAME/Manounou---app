# 🌐 Comment Changer la Langue du Simulateur iOS (Nouvelle Interface)

## 🎯 Méthode 1 : Depuis le Simulateur (Recommandé)

### Étapes détaillées :

1. **Ouvrir le simulateur iOS**
   - Le simulateur doit être lancé et visible

2. **Ouvrir les Réglages**
   - Cliquer sur l'icône **Réglages** (roue crantée) sur l'écran d'accueil du simulateur

3. **Naviguer vers Langue et région**
   - Dans Réglages, faire défiler et toucher **Général**
   - Faire défiler et toucher **Langue et région**

4. **Changer la langue**
   - Toucher **Langue de l'iPhone**
   - Sélectionner **Français**
   - Toucher **Terminé** en haut à droite
   - Le simulateur demandera de redémarrer → Toucher **Redémarrer**

5. **Après redémarrage**
   - Le simulateur sera en français
   - Relancer l'app : `flutter run`
   - Le clavier sera maintenant en AZERTY

---

## 🎯 Méthode 2 : Via Xcode (Nouvelle Interface 2024/2025)

### Instructions Pas-à-Pas pour la Nouvelle Interface Xcode :

#### Option A : Via le Menu Xcode

1. **Ouvrir la fenêtre des appareils**
   - Dans Xcode : Menu **Window** (Fenêtre) en haut
   - Cliquer sur **Devices and Simulators** (Appareils et Simulateurs)
   - **OU** raccourci clavier : **⌘⇧2** (Commande + Majuscule + 2)

2. **Dans la fenêtre qui s'ouvre**
   - Onglet **Simulators** (en haut à gauche)
   - Liste des simulateurs à gauche (ex: "iPhone 15 Pro", "iPhone 16", etc.)

3. **Sélectionner votre simulateur**
   - Cliquer sur le nom de votre simulateur dans la liste
   - Le simulateur doit être **déjà lancé** (visible sur l'écran)

4. **Ouvrir les réglages du simulateur**
   - **Clic droit** sur le simulateur dans la liste
   - Menu contextuel apparaît
   - Cliquer sur **"Open Simulator Settings"** ou **"Réglages du simulateur"**
   - **OU** dans le menu Xcode : **Device** > **Open Simulator Settings**

5. **Changer la langue**
   - Dans la fenêtre des réglages qui s'ouvre
   - Aller dans **General** (Général) dans la liste de gauche
   - Faire défiler et cliquer sur **Language & Region** (Langue et région)
   - Cliquer sur **iPhone Language** (Langue de l'iPhone)
   - Sélectionner **Français** dans la liste
   - Cliquer **Done** (Terminé) en haut à droite
   - Le simulateur redémarre automatiquement

#### Option B : Si l'Option A ne fonctionne pas

1. **Fermer Xcode complètement**
2. **Ouvrir le Simulateur directement**
   ```bash
   open -a Simulator
   ```
3. **Dans le simulateur** (pas Xcode)
   - Cliquer sur l'icône **Réglages** (roue crantée) sur l'écran d'accueil
   - Suivre les étapes de la Méthode 1

---

## 🎯 Méthode 3 : Créer un Nouveau Simulateur en Français

1. **Dans Xcode**
   - Menu **Window** > **Devices and Simulators**
   - Cliquer sur le bouton **+** en bas à gauche
   - Choisir :
     - **Device Type** : iPhone (ex: iPhone 15 Pro)
     - **OS Version** : La dernière version disponible
   - Cliquer **Create**

2. **Configurer la langue**
   - Au premier démarrage, le simulateur demandera la langue
   - Sélectionner **Français**

3. **Utiliser ce simulateur**
   ```bash
   flutter devices
   flutter run -d <id-du-simulateur-français>
   ```

---

## 🎯 Méthode 4 : Via la Ligne de Commande (RECOMMANDÉ - Le plus simple !)

### ✅ Méthode la plus rapide et fiable

```bash
# 1. Lister tous les simulateurs disponibles
xcrun simctl list devices available

# 2. Trouver l'ID de votre simulateur (ex: "iPhone 15 Pro")
# Chercher dans la liste : "iPhone 15 Pro (XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX)"

# 3. Changer la langue directement via la ligne de commande
# Remplacez "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX" par l'ID de votre simulateur
xcrun simctl shutdown all  # Arrêter tous les simulateurs
xcrun simctl boot "iPhone 15 Pro"  # Démarrer votre simulateur (remplacer par le nom exact)

# 4. Ouvrir le simulateur
open -a Simulator

# 5. Attendre que le simulateur démarre, puis dans le simulateur :
#    - Cliquer sur Réglages (icône roue crantée)
#    - Général > Langue et région > Langue de l'iPhone > Français
#    - Redémarrer

# 6. Relancer l'app
cd flutterflow_export
flutter run
```

### 🚀 Script Automatique (Encore plus simple)

Créez un fichier `change_simulator_language.sh` :

```bash
#!/bin/bash
echo "🌐 Changement de langue du simulateur en français..."
echo ""
echo "Étapes :"
echo "1. Le simulateur va s'ouvrir"
echo "2. Dans le simulateur : Réglages > Général > Langue et région > Français"
echo "3. Redémarrer le simulateur"
echo ""
read -p "Appuyez sur Entrée pour continuer..."

# Ouvrir le simulateur
open -a Simulator

echo ""
echo "✅ Simulateur ouvert !"
echo "📱 Maintenant, dans le simulateur :"
echo "   1. Cliquez sur 'Réglages' (icône roue crantée)"
echo "   2. Général > Langue et région"
echo "   3. Langue de l'iPhone > Français"
echo "   4. Redémarrer"
```

### ⚡ Alternative : Forcer la langue via Terminal (Avancé)

```bash
# Cette méthode change la langue sans ouvrir le simulateur
# Nécessite que le simulateur soit déjà booté

# 1. Trouver l'ID du simulateur
xcrun simctl list devices | grep "iPhone"

# 2. Changer la langue (remplacer DEVICE_ID par l'ID trouvé)
xcrun simctl spawn <DEVICE_ID> defaults write NSGlobalDomain AppleLanguages "(fr-FR)"

# 3. Redémarrer le simulateur
xcrun simctl shutdown <DEVICE_ID>
xcrun simctl boot <DEVICE_ID>
```

---

## ✅ Vérification

Après avoir changé la langue :

1. **Vérifier dans le simulateur**
   - Les menus devraient être en français
   - "Réglages" au lieu de "Settings"

2. **Tester le clavier**
   - Ouvrir l'app
   - Taper dans un champ de texte
   - Le clavier devrait être en AZERTY (Q en haut à gauche, A-Z-E-R-T-Y sur la première ligne)

---

## 🚨 Si ça ne fonctionne toujours pas

1. **Vérifier la langue du système Mac**
   - Préférences Système > Langue et région
   - S'assurer que le français est en priorité

2. **Forcer le redémarrage complet**
   ```bash
   # Arrêter tous les simulateurs
   xcrun simctl shutdown all
   
   # Redémarrer
   open -a Simulator
   ```

3. **Vérifier la configuration de l'app**
   - Info.plist doit avoir `CFBundleDevelopmentRegion = fr`
   - main.dart doit avoir `locale: Locale('fr', 'FR')`

---

## 📝 Note

Sur iOS, le clavier suit **toujours** la langue du système. Si le simulateur est en anglais, le clavier sera QWERTY même si l'app est en français.

**Solution définitive :** Changer la langue du simulateur en français.


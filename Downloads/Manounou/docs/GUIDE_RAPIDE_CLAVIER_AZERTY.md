# ⌨️ Guide Rapide : Clavier AZERTY sur Simulateur iOS

## 🚀 Solution la Plus Simple (2 minutes)

### Option 1 : Script Automatique (Recommandé)

```bash
cd /Users/vametoure/Downloads/Manounou
./change_simulator_to_french.sh
```

Puis suivez les instructions affichées dans le simulateur.

---

### Option 2 : Manuel (Directement dans le Simulateur)

1. **Ouvrir le simulateur**
   ```bash
   open -a Simulator
   ```

2. **Dans le simulateur** :
   - Cliquer sur **Réglages** (icône ⚙️)
   - **Général** > **Langue et région**
   - **Langue de l'iPhone** > **Français**
   - **Terminé** → Le simulateur redémarre

3. **Relancer l'app**
   ```bash
   cd flutterflow_export
   flutter run
   ```

---

### Option 3 : Via Xcode (Si nécessaire)

1. **Ouvrir Xcode**
2. **Menu Window** > **Devices and Simulators** (⌘⇧2)
3. **Onglet Simulators**
4. **Clic droit** sur votre simulateur > **Open Simulator Settings**
5. **General** > **Language & Region** > **iPhone Language** > **Français**
6. Redémarrer

---

## ✅ Vérification

Après avoir changé la langue :

1. Le simulateur affiche "Réglages" au lieu de "Settings"
2. Dans l'app, quand vous tapez dans un champ texte :
   - Le clavier est en **AZERTY** (Q en haut à gauche, A-Z-E-R-T-Y sur la première ligne)
   - Pas de QWERTY (Q-W-E-R-T-Y)

---

## 🚨 Si ça ne fonctionne toujours pas

1. **Vérifier que le simulateur a bien redémarré**
   ```bash
   xcrun simctl shutdown all
   open -a Simulator
   ```

2. **Vérifier la langue du système Mac**
   - Préférences Système > Langue et région
   - Le français doit être en priorité

3. **Créer un nouveau simulateur en français**
   - Xcode > Window > Devices and Simulators
   - Bouton **+** > Créer un nouveau simulateur
   - Au premier démarrage, sélectionner **Français**

---

## 📝 Note Importante

⚠️ **Sur iOS, le clavier suit TOUJOURS la langue du système.**

Même si votre app est configurée en français, si le simulateur/iPhone est en anglais, le clavier sera QWERTY.

**Solution définitive :** Changer la langue du simulateur/iPhone en français.

---

## 🎯 Résumé Express

```bash
# 1. Ouvrir le simulateur
open -a Simulator

# 2. Dans le simulateur : Réglages > Général > Langue et région > Français

# 3. Relancer l'app
cd flutterflow_export && flutter run
```

**C'est tout !** 🎉


# ⌨️ Solution : Problème de Mapping Clavier Mac (@ donne §)

## 🔍 Problème Identifié

Quand vous tapez **@** sur votre clavier Mac AZERTY, le simulateur iOS affiche **§**.

**Cause :** Le simulateur iOS interprète votre clavier Mac AZERTY comme un clavier QWERTY, créant un décalage de mapping.

---

## ✅ Solution 1 : Utiliser le Clavier Virtuel iOS (RECOMMANDÉ)

### Étapes :

1. **Dans le simulateur iOS** :
   - Menu **I/O** (en haut) > **Keyboard**
   - **DÉCOCHER** "Connect Hardware Keyboard"
   - Le clavier virtuel iOS apparaît à l'écran

2. **Le clavier virtuel iOS** :
   - Sera en **AZERTY** si le simulateur est en français
   - Cliquez directement sur les touches à l'écran
   - Plus de problème de mapping !

3. **Pour réactiver le clavier Mac** :
   - Menu **I/O** > **Keyboard** > **COCHER** "Connect Hardware Keyboard"

---

## ✅ Solution 2 : Forcer le Français sur le Simulateur

### Script Automatique :

```bash
cd /Users/vametoure/Downloads/Manounou
./force_simulator_french.sh
```

Puis suivez les instructions pour utiliser le clavier virtuel iOS.

---

## ✅ Solution 3 : Configurer le Clavier Mac

### Si vous voulez continuer à utiliser le clavier physique Mac :

1. **Préférences Système Mac** :
   - **Clavier** > **Sources d'entrée**
   - Vérifier que "Français - AZERTY" est présent
   - Si non, cliquer **+** et ajouter "Français"

2. **Dans le simulateur** :
   - Menu **I/O** > **Keyboard**
   - **DÉCOCHER** "Connect Hardware Keyboard"
   - Utiliser le clavier virtuel iOS (plus fiable)

3. **OU** : Configurer le mapping via Terminal :
   ```bash
   # Ajouter le clavier français au Mac
   defaults write -g AppleKeyboardLayout -string "French"
   ```

---

## ✅ Solution 4 : Vérifier la Langue du Simulateur

### Vérifier que le simulateur est vraiment en français :

1. **Dans le simulateur** :
   - Cliquer sur **Réglages** (⚙️)
   - **Général** > **Langue et région**
   - Vérifier que "Langue de l'iPhone" = **Français**

2. **Si ce n'est pas le cas** :
   - Changer en **Français**
   - Redémarrer le simulateur
   - Le clavier virtuel sera en AZERTY

---

## 🎯 Solution Définitive (Recommandée)

**Utiliser le clavier virtuel iOS du simulateur** :

1. ✅ Pas de problème de mapping
2. ✅ Clavier en AZERTY si simulateur en français
3. ✅ Fonctionne à tous les coups
4. ✅ Plus réaliste (comme sur un vrai iPhone)

### Activation rapide :

```
Simulateur > I/O > Keyboard > [DÉCOCHER] Connect Hardware Keyboard
```

Le clavier virtuel apparaît automatiquement à l'écran.

---

## 🚨 Pourquoi "@" donne "§" ?

**Explication technique :**

- Votre Mac : Clavier **AZERTY** (touche @ = Alt+0)
- Simulateur iOS : Pense que le clavier est **QWERTY**
- Mapping incorrect : @ (AZERTY) → § (QWERTY)

**Solution :** Utiliser le clavier virtuel iOS qui suit la langue du simulateur, pas celle du Mac.

---

## ✅ Checklist de Vérification

- [ ] Le simulateur est en français (Réglages > Général > Langue et région)
- [ ] Le clavier virtuel iOS est activé (I/O > Keyboard > Connect Hardware Keyboard = DÉCOCHÉ)
- [ ] Le clavier virtuel affiche "AZERTY" (Q en haut à gauche, A-Z-E-R-T-Y)
- [ ] Taper "@" donne bien "@" (pas "§")

---

## 📝 Note Finale

⚠️ **Le mapping clavier Mac → Simulateur iOS est complexe et dépend de la configuration système.**

💡 **La solution la plus fiable : Utiliser le clavier virtuel iOS du simulateur.**

C'est aussi plus réaliste car cela simule l'expérience d'un vrai iPhone où on tape sur l'écran !


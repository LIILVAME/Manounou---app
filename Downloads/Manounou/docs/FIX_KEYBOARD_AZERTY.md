# ⌨️ Configuration Clavier AZERTY

## 🎯 Problème
Le clavier affiché est en QWERTY au lieu d'AZERTY (français).

## ✅ Solutions Appliquées

### 1. Configuration Info.plist
- `CFBundleDevelopmentRegion` → `fr` (français)
- `CFBundleLocalizations` → `['fr', 'en']`

### 2. Configuration Flutter
- Locale forcée à `fr_FR` dans `main.dart`
- `supportedLocales` inclut `fr_FR` en priorité

### 3. Configuration Simulateur/iPhone

**Pour le simulateur iOS :**
1. Ouvrir **Réglages** dans le simulateur
2. Aller dans **Général > Langue et région**
3. Sélectionner **Français (France)**
4. Redémarrer le simulateur si nécessaire

**Pour l'iPhone physique :**
1. Aller dans **Réglages > Général > Langue et région**
2. Vérifier que la langue est **Français**
3. Si nécessaire, changer la langue du système

## 🔍 Vérification

Après avoir changé la langue du système :
1. Relancer l'application
2. Taper dans un champ de texte
3. Le clavier devrait être en AZERTY

## 📝 Note

Sur iOS, le clavier suit **toujours la langue du système**. Même si l'app est configurée en français, si le système est en anglais, le clavier sera QWERTY.

**Solution définitive :** Changer la langue du système iOS en français.


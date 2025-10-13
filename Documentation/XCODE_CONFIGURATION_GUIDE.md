# 🔧 Guide de Configuration Xcode - Manounou

## 📋 Résolution des Erreurs de Signature

### **Problèmes Identifiés**
- ❌ `No Accounts: Add a new account in Accounts settings`
- ❌ `No profiles for 'com.vametoure.manounou' were found`

### **Solutions Recommandées**

## 🎯 **Solution 1 : Configuration pour Simulateur Uniquement (Recommandée)**

### **Étape 1 : Ouvrir le Projet**
1. Ouvrez **Xcode**
2. Ouvrez le fichier `Manounou.xcodeproj`
3. Attendez que les dépendances se chargent

### **Étape 2 : Configuration de Signature**
1. Sélectionnez le projet **Manounou** dans le navigateur
2. Sélectionnez la target **Manounou**
3. Allez dans l'onglet **"Signing & Capabilities"**
4. **Décochez** "Automatically manage signing"
5. Laissez **"Provisioning Profile"** vide
6. Définissez **"Signing Certificate"** sur "Don't Code Sign"

### **Étape 3 : Configuration de Build**
1. Allez dans l'onglet **"Build Settings"**
2. Recherchez **"Code Signing Identity"**
3. Définissez sur **"Don't Code Sign"** pour Debug et Release
4. Recherchez **"Development Team"**
5. Laissez vide

### **Étape 4 : Sélection du Simulateur**
1. Dans la barre d'outils Xcode, cliquez sur le sélecteur de destination
2. Choisissez **"iPhone 15"** ou tout autre simulateur iOS
3. Assurez-vous qu'il s'agit bien d'un **simulateur** et non d'un appareil physique

### **Étape 5 : Test de Compilation**
1. Appuyez sur **Cmd+B** pour compiler
2. Ou appuyez sur **Cmd+R** pour compiler et lancer

---

## 🍎 **Solution 2 : Ajout d'un Compte Développeur Apple**

### **Si vous avez un Apple ID Developer**
1. Allez dans **Xcode > Preferences** (ou **Settings** sur Xcode 14+)
2. Cliquez sur l'onglet **"Accounts"**
3. Cliquez sur **"+"** en bas à gauche
4. Sélectionnez **"Apple ID"**
5. Entrez vos identifiants Apple ID
6. Retournez aux paramètres de signature du projet
7. Sélectionnez votre équipe dans **"Team"**

### **Si vous n'avez pas de compte développeur**
- Utilisez la **Solution 1** (simulateur uniquement)
- Ou créez un compte développeur gratuit sur [developer.apple.com](https://developer.apple.com)

---

## 🚀 **Test des Composants Refactorisés**

### **Après Configuration Réussie**

1. **Compilation :**
   ```bash
   # Dans le terminal
   cd "/Users/vametoure/Library/Mobile Documents/com~apple~CloudDocs/VAM/PROJETS - STARTUP/Manounou - app"
   ./test_modern_app.sh
   ```

2. **Ou dans Xcode :**
   - Sélectionnez un simulateur iPhone
   - Appuyez sur **Cmd+R**

### **Validation des Fonctionnalités**

#### **✅ Checklist de Test**
- [ ] L'application se lance sans erreur
- [ ] Les 5 onglets sont visibles (Home, Enfants, Calendrier, Documents, Paramètres)
- [ ] Navigation entre les onglets fonctionne
- [ ] **Onglet Enfants :**
  - [ ] Liste des enfants s'affiche
  - [ ] Bouton "Ajouter un enfant" fonctionne
  - [ ] Formulaire d'ajout s'ouvre
  - [ ] Sauvegarde d'un nouvel enfant
- [ ] **Onglet Calendrier :**
  - [ ] Calendrier s'affiche
  - [ ] Liste des événements
  - [ ] Ajout d'événement fonctionne
- [ ] **Onglet Documents :**
  - [ ] Liste des documents
  - [ ] Recherche fonctionne
  - [ ] Ajout de document
- [ ] **Onglet Paramètres :**
  - [ ] Sections de profil visibles
  - [ ] Paramètres de l'application accessibles

---

## 🔍 **Dépannage**

### **Erreur : "Could not resolve package dependencies"**
```bash
# Nettoyer les dépendances
rm -rf ~/Library/Developer/Xcode/DerivedData/Manounou-*

# Résoudre les dépendances
xcodebuild -resolvePackageDependencies -project Manounou.xcodeproj
```

### **Erreur : "Build input file cannot be found"**
1. Vérifiez que tous les fichiers sont bien ajoutés au projet
2. Dans Xcode : **Product > Clean Build Folder**
3. Relancez la compilation

### **Simulateur ne démarre pas**
```bash
# Redémarrer le service simulateur
sudo killall -9 com.apple.CoreSimulator.CoreSimulatorService
xcrun simctl shutdown all
xcrun simctl boot "iPhone 15"
```

---

## 📱 **Scripts Disponibles**

### **1. Configuration Automatique**
```bash
./configure_simulator_build.sh
```

### **2. Compilation Simulateur**
```bash
./build_simulator_only.sh
```

### **3. Test Complet**
```bash
./test_modern_app.sh
```

---

## ✅ **Validation Finale**

Une fois la configuration terminée, vous devriez pouvoir :

1. ✅ Compiler le projet sans erreurs de signature
2. ✅ Lancer l'application sur simulateur
3. ✅ Tester tous les composants refactorisés
4. ✅ Valider que les fonctionnalités existantes fonctionnent

---

## 📞 **Support**

Si vous rencontrez encore des problèmes :

1. Vérifiez que Xcode est à jour (version 15+)
2. Redémarrez Xcode complètement
3. Nettoyez le cache : **Product > Clean Build Folder**
4. Consultez les logs de compilation pour des erreurs spécifiques

**Le projet est maintenant prêt pour les tests sur simulateur ! 🎉**
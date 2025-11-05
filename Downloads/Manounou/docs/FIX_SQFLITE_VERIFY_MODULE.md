# 🔧 Correction Erreur VerifyModule sqflite_darwin

## 📋 Problème

Xcode génère des erreurs lors de la phase `VerifyModule` pour `sqflite_darwin` :

```
'Flutter/Flutter.h' file not found
could not build module 'sqflite_darwin'
```

La phase `VerifyModule` essaie de compiler le module indépendamment mais ne trouve pas les headers Flutter.

## ✅ Solution Définitive

### Option 1 : Réinstallation Complète (Recommandé)

```bash
cd flutterflow_export

# 1. Nettoyer complètement
flutter clean
cd ios
rm -rf Pods Podfile.lock .symlinks
cd ..

# 2. Réinstaller les pods (le Podfile désactivera automatiquement VerifyModule)
cd ios
pod install --repo-update
cd ..

# 3. Appliquer toutes les corrections
./fix_all_ios.sh

# 4. Nettoyer le DerivedData Xcode
rm -rf ~/Library/Developer/Xcode/DerivedData
```

### Option 2 : Suppression Manuelle dans Xcode

Si l'Option 1 ne fonctionne pas :

1. **Ouvrir le projet Pods dans Xcode** :
   ```bash
   open ios/Pods/Pods.xcodeproj
   ```

2. **Dans Xcode** :
   - Sélectionner le target `sqflite_darwin` dans la liste des targets
   - Aller dans l'onglet **"Build Phases"**
   - Chercher la phase **"VerifyModule"** ou **"Run Script"** qui contient `modules-verifier`
   - **Supprimer cette phase** (clic droit → Delete ou sélectionner puis appuyer sur Delete)

3. **Fermer Xcode**

4. **Nettoyer et recompiler** :
   - Dans Xcode : Product > Clean Build Folder (⇧⌘K)
   - Recompiler le projet

### Option 3 : Modification du Projet Xcode via Script

Le script `remove_verify_module.sh` peut supprimer automatiquement la phase :

```bash
cd flutterflow_export
./remove_verify_module.sh
```

## 🔍 Vérification

Pour vérifier que `ENABLE_MODULE_VERIFIER` est bien désactivé :

```bash
# Vérifier les fichiers .xcconfig
grep "ENABLE_MODULE_VERIFIER" ios/Pods/Target\ Support\ Files/sqflite_darwin/sqflite_darwin.*.xcconfig

# Devrait afficher : ENABLE_MODULE_VERIFIER = NO
```

## 📝 Configuration Podfile

Le Podfile configure déjà automatiquement `sqflite_darwin` pour :

1. **Désactiver VerifyModule** :
   ```ruby
   config.build_settings['ENABLE_MODULE_VERIFIER'] = 'NO'
   ```

2. **Supprimer la phase VerifyModule** :
   ```ruby
   phases_to_remove.each { |phase| target.build_phases.delete(phase) }
   ```

3. **Ajouter les chemins Flutter** :
   ```ruby
   config.build_settings['HEADER_SEARCH_PATHS'] = [
     "$(PODS_CONFIGURATION_BUILD_DIR)/Flutter/Flutter.framework/Headers",
     "$(PODS_ROOT)/../Flutter/Flutter.framework/Headers",
     "$(SRCROOT)/../Flutter/Flutter.framework/Headers",
   ]
   ```

## ⚠️ Si le Problème Persiste

1. **Vérifier que le Podfile est bien exécuté** :
   - Le `post_install` doit s'exécuter lors de `pod install`
   - Vérifier les logs de `pod install` pour voir s'il y a des erreurs

2. **Supprimer manuellement dans Xcode** (Option 2 ci-dessus)

3. **Vérifier le fichier project.pbxproj** :
   ```bash
   grep -i "sqflite_darwin" ios/Pods/Pods.xcodeproj/project.pbxproj | grep -i "verify"
   ```
   - Si des résultats apparaissent, la phase est toujours présente

4. **Alternative : Désactiver complètement les modules pour sqflite_darwin** :
   - Dans le Podfile, changer `DEFINES_MODULE = YES` en `DEFINES_MODULE = NO`
   - ⚠️ Cela peut casser les imports `@import sqflite_darwin` dans le code Swift

## 🚀 Procédure Complète Recommandée

```bash
# 1. Aller dans flutterflow_export
cd /Users/vametoure/Downloads/Manounou/flutterflow_export

# 2. Nettoyer complètement
flutter clean
cd ios
rm -rf Pods Podfile.lock .symlinks
cd ..

# 3. Réinstaller les pods
cd ios
pod install --repo-update
cd ..

# 4. Appliquer toutes les corrections
./fix_all_ios.sh

# 5. Supprimer VerifyModule si nécessaire
./remove_verify_module.sh

# 6. Nettoyer Xcode
rm -rf ~/Library/Developer/Xcode/DerivedData

# 7. Dans Xcode
# - Product > Clean Build Folder (⇧⌘K)
# - Fermer et rouvrir Xcode
# - Recompiler
```


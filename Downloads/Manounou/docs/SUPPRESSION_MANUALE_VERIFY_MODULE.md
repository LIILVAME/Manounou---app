# 🔧 Suppression Manuelle VerifyModule - Guide Détaillé

## ⚠️ Si les Scripts Automatiques Échouent

La phase `VerifyModule` est toujours exécutée par Xcode malgré les configurations. Voici la **procédure manuelle définitive** :

## 📋 Procédure Étape par Étape

### Étape 1 : Ouvrir le Projet Pods

```bash
cd /Users/vametoure/Downloads/Manounou/flutterflow_export
open ios/Pods/Pods.xcodeproj
```

### Étape 2 : Localiser le Target sqflite_darwin

1. **Dans la barre latérale gauche de Xcode** :
   - Ouvrir le projet **"Pods"** (clic sur le triangle)
   - Ouvrir **"TARGETS"**
   - Chercher et **sélectionner** le target **"sqflite_darwin"**

### Étape 3 : Accéder aux Build Phases

1. **En haut de la fenêtre** : Cliquer sur l'onglet **"Build Phases"**
2. **Déplier la section** si nécessaire pour voir toutes les phases

### Étape 4 : Identifier la Phase VerifyModule

Chercher une phase qui contient :
- **Nom** : "Run Script" ou "VerifyModule" ou "Verify Swift Module"
- **Script** : Contient `modules-verifier` dans le contenu

**Comment identifier** :
- Si vous voyez plusieurs phases "Run Script", cliquez sur chacune
- Regardez le contenu du script dans la zone de texte en bas
- La phase problématique contiendra : `/usr/bin/modules-verifier` ou `modules-verifier`

### Étape 5 : Supprimer la Phase

1. **Sélectionner** la phase VerifyModule (clic dessus)
2. **Appuyer sur la touche Delete** (ou clic droit → **Delete**)
3. **Confirmer** la suppression si demandé

### Étape 6 : Vérifier les Settings

1. **Onglet "Build Settings"** (à côté de Build Phases)
2. **Chercher** : `ENABLE_MODULE_VERIFIER`
3. **Vérifier** que la valeur est `NO` (si elle existe)

### Étape 7 : Nettoyer et Recompiler

1. **Dans Xcode** :
   - **Product** → **Clean Build Folder** (⇧⌘K)
   - Attendre la fin du nettoyage

2. **Fermer Xcode complètement** (⌘Q)

3. **Nettoyer DerivedData** :
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData
   ```

4. **Rouvrir Xcode** :
   ```bash
   open ios/Runner.xcworkspace
   ```

5. **Recompiler** :
   - **Product** → **Build** (⌘B)

## 🎯 Alternative : Désactiver VerifyModule Globalement

Si la suppression manuelle ne fonctionne pas ou si la phase revient, vous pouvez désactiver VerifyModule pour **tous** les pods :

### Modification du Podfile

Ajoutez ceci dans le `post_install` du Podfile :

```ruby
post_install do |installer|
  installer.pods_project.targets.each do |target|
    # Désactiver VerifyModule pour tous les targets
    target.build_configurations.each do |config|
      config.build_settings['ENABLE_MODULE_VERIFIER'] = 'NO'
      config.build_settings['CLANG_ENABLE_MODULE_DEBUGGING'] = 'NO'
    end
    
    # Supprimer toutes les phases VerifyModule
    phases_to_remove = []
    target.build_phases.each do |phase|
      if phase.is_a?(Xcodeproj::Project::Object::PBXShellScriptBuildPhase)
        script = phase.shell_script || ''
        if script.include?('modules-verifier')
          phases_to_remove << phase
        end
      end
    end
    phases_to_remove.each { |phase| target.build_phases.delete(phase) }
  end
  
  installer.pods_project.save
end
```

Puis réinstallez :
```bash
cd ios
pod install
cd ..
```

## 🔍 Vérification

Après suppression, vérifier :

```bash
# Vérifier que la phase n'existe plus
grep -c "modules-verifier" ios/Pods/Pods.xcodeproj/project.pbxproj
# Devrait afficher : 0

# Vérifier les settings
grep "ENABLE_MODULE_VERIFIER" ios/Pods/Target\ Support\ Files/sqflite_darwin/sqflite_darwin.*.xcconfig
# Devrait afficher : ENABLE_MODULE_VERIFIER = NO
```

## ⚠️ Notes Importantes

1. **La phase peut être recréée** : Si vous exécutez `pod install` après, la phase peut revenir
2. **Solution permanente** : Modifier le Podfile pour désactiver globalement (voir Alternative ci-dessus)
3. **Nettoyer DerivedData** : Toujours nettoyer DerivedData après modifications

## 📝 Capture d'Écran Conceptuelle

```
┌─────────────────────────────────────────┐
│  Xcode - Pods.xcodeproj                │
├─────────────────────────────────────────┤
│  [Navigateur]  [Target: sqflite_darwin] │
│  ├─ Pods                                │
│  │  ├─ TARGETS                          │
│  │  │  ├─ sqflite_darwin  ← SELECTIONNER│
│  │  │  └─ ...                           │
│  │                                      │
│  [Onglets]                              │
│  [General] [Signing] [Build Settings]  │
│  [Build Phases] ← CLIQUER ICI           │
│                                      │
│  ┌─ Build Phases ───────────────────┐ │
│  │  ▶ Copy Bundle Resources         │ │
│  │  ▶ Run Script [1] ← CLIQUEZ ICI │ │
│  │     └─ Script: modules-verifier │ │
│  │  ▶ Run Script [2]                │ │
│  │                                   │ │
│  │  [Supprimer avec Delete]         │ │
│  └──────────────────────────────────┘ │
└─────────────────────────────────────────┘
```

## 🚀 Si Rien Ne Fonctionne

En dernier recours, désactiver VerifyModule pour **tous** les pods dans le Podfile (voir Alternative ci-dessus) et réinstaller les pods.


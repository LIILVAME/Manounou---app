# 🔧 Fix Stale Files Warnings iOS

## 🎯 Problème
Warnings Xcode : "Stale file ... is located outside of the allowed root paths"

Ces warnings apparaissent quand :
- Des fichiers de build obsolètes restent dans `build/ios/Debug-iphoneos/`
- Xcode détecte des frameworks/bundles qui ne devraient pas être là
- Le dossier build contient des artefacts de builds précédents

## ✅ Solution

### 1. Nettoyer le build Flutter
```bash
cd flutterflow_export
flutter clean
```

### 2. Supprimer le dossier build iOS
```bash
rm -rf build/ios/Debug-iphoneos
```

### 3. Rebuild depuis Xcode
- Product > Clean Build Folder (⇧⌘K)
- Product > Build (⌘B)

## 📝 Notes

- Ces warnings sont **non-bloquants** (le build peut réussir malgré eux)
- Ils indiquent juste que Xcode détecte des fichiers obsolètes
- Le nettoyage complet résout généralement le problème
- Si les warnings persistent, supprimer tout le dossier `build/` :
  ```bash
  rm -rf build/
  ```

## 🚀 Après nettoyage

Le build devrait maintenant être propre sans warnings de stale files.


# 🔧 Fix iOS Crash — __pthread_kill

## 🎯 Problème
Crash iOS avec `__pthread_kill` dans `libsystem_kernel.dylib`. Cela indique généralement :
- Une exception non gérée
- Un crash mémoire (SIGSEGV)
- Un problème d'initialisation (SIGABRT)

## ✅ Solutions Appliquées

### 1. Gestion d'erreurs globale Flutter (`main.dart`)
- `FlutterError.onError` : Capture toutes les erreurs Flutter
- `PlatformDispatcher.instance.onError` : Capture les erreurs non gérées au niveau plateforme
- Try-catch autour de l'initialisation Supabase
- Fallback UI si l'app ne peut pas démarrer

### 2. Gestion d'erreurs native iOS (`AppDelegate.swift`)
- `NSSetUncaughtExceptionHandler` : Capture les exceptions Objective-C/Swift non gérées
- `signal(SIGABRT)` : Capture les arrêts anormaux
- `signal(SIGSEGV)` : Capture les violations de mémoire
- Try-catch autour de l'enregistrement des plugins

## 🔍 Diagnostic

Pour identifier la cause exacte du crash :

1. **Vérifier les logs Xcode** :
   - Console Xcode > Filtrer par "Manounou"
   - Chercher les messages avec ❌ ou "Uncaught Exception"

2. **Vérifier les logs système** :
   ```bash
   # Sur le Mac
   log show --predicate 'process == "Runner"' --last 5m
   ```

3. **Activer le mode debug détaillé** :
   - Dans Xcode : Product > Scheme > Edit Scheme
   - Arguments > Environment Variables
   - Ajouter : `FLUTTER_DEBUG=1`

## 🚀 Prochaines Étapes

1. Relancer l'app et observer les logs
2. Identifier le message d'erreur exact (sera affiché dans la console)
3. Si le crash persiste, vérifier :
   - Les permissions dans Info.plist
   - Les plugins natifs (sqflite_darwin, etc.)
   - La configuration réseau

Les handlers d'erreur devraient maintenant capturer et afficher la cause réelle du crash au lieu de simplement crasher silencieusement.


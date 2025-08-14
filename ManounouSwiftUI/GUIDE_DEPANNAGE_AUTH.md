# 🔧 Guide de Dépannage - Problèmes d'Authentification

## ⚠️ PROBLÈME IDENTIFIÉ

Vous rencontrez des difficultés avec :
- ❌ Impossible d'accéder à l'interface principale après connexion
- ❌ Le bouton "Se déconnecter" ne fonctionne pas
- ❌ L'application reste bloquée sur l'écran de connexion

## 🚀 SOLUTION ÉTAPE PAR ÉTAPE

### **Étape 1 : Vérifier les Tables Supabase**

1. **Aller sur Supabase Dashboard**
   - URL : https://app.supabase.com/project/emgrtgencepzainsknsb
   - Se connecter à votre compte

2. **Vérifier les Tables**
   - Aller dans "Table Editor"
   - Vérifier que ces tables existent :
     - ✅ `profiles`
     - ✅ `children`
     - ✅ `events`
     - ✅ `documents`
     - ✅ `family_relationships`

3. **Si les tables manquent**
   - Aller dans "SQL Editor"
   - Copier TOUT le contenu de `supabase_setup.sql`
   - Exécuter le script

### **Étape 2 : Vérifier l'Utilisateur**

1. **Dans Supabase Dashboard**
   - Aller dans "Authentication" > "Users"
   - Vérifier que votre compte existe
   - Noter l'email exact utilisé

2. **Vérifier le Profil**
   - Aller dans "Table Editor" > "profiles"
   - Chercher votre utilisateur par email
   - Si absent, le profil n'a pas été créé automatiquement

### **Étape 3 : Test de Connexion Manuelle**

1. **Nettoyer l'Application**
   - Fermer complètement l'app iOS
   - Dans le simulateur : Device > Erase All Content and Settings
   - Relancer le simulateur

2. **Réinstaller l'App**
   ```bash
   cd ManounouSwiftUI
   xcodebuild -project Manounou.xcodeproj -scheme Manounou -destination 'platform=iOS Simulator,name=iPhone 15,OS=18.0' build
   xcrun simctl install booted /path/to/Manounou.app
   ```

3. **Tester la Connexion**
   - Utiliser l'email EXACT de Supabase
   - Utiliser le mot de passe correct
   - Observer les logs dans Xcode Console

### **Étape 4 : Vérifier les Logs**

1. **Ouvrir Xcode Console**
   - Window > Devices and Simulators
   - Sélectionner le simulateur
   - Cliquer sur "Open Console"

2. **Filtrer les Logs**
   - Rechercher "Manounou"
   - Chercher ces messages :
     - 🚀 "Initialisation AuthManager..."
     - 🔍 "Vérification de la session actuelle..."
     - 🔐 "Connexion réussie pour: [email]"

### **Étape 5 : Créer un Nouveau Compte**

1. **Si le problème persiste**
   - Utiliser un nouvel email
   - Créer un nouveau compte dans l'app
   - Vérifier immédiatement dans Supabase

2. **Vérifications Post-Création**
   - Table "auth.users" : nouvel utilisateur
   - Table "profiles" : profil créé automatiquement
   - Logs app : messages de succès

## 🔍 DIAGNOSTIC AVANCÉ

### **Problèmes Courants et Solutions**

#### **1. Tables Supabase Manquantes**
```sql
-- Vérifier l'existence des tables
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'public';
```

#### **2. Politiques RLS Incorrectes**
```sql
-- Vérifier les politiques
SELECT * FROM pg_policies WHERE schemaname = 'public';
```

#### **3. Trigger de Profil Manquant**
```sql
-- Vérifier le trigger
SELECT * FROM information_schema.triggers 
WHERE trigger_name = 'on_auth_user_created';
```

### **Messages d'Erreur Fréquents**

| Erreur | Cause | Solution |
|--------|-------|----------|
| "Invalid login credentials" | Email/mot de passe incorrect | Vérifier dans Supabase Auth |
| "Row Level Security" | Politiques RLS manquantes | Exécuter le script SQL |
| "Table doesn't exist" | Tables non créées | Exécuter supabase_setup.sql |
| "Network error" | Problème de connexion | Vérifier URL/clé Supabase |

## 🛠️ RÉPARATION MANUELLE

### **Si Rien ne Fonctionne**

1. **Supprimer le Projet Supabase**
   - Créer un nouveau projet
   - Noter la nouvelle URL et clé

2. **Mettre à Jour Config.swift**
   ```swift
   static let url = "NOUVELLE_URL_SUPABASE"
   static let anonKey = "NOUVELLE_CLE_ANON"
   ```

3. **Recréer les Tables**
   - Exécuter supabase_setup.sql
   - Vérifier toutes les tables

4. **Tester Complètement**
   - Créer un nouveau compte
   - Vérifier la navigation
   - Tester la déconnexion

## 📱 TEST FINAL

### **Checklist de Validation**

- [ ] Tables Supabase créées
- [ ] Utilisateur existe dans Auth
- [ ] Profil créé dans table profiles
- [ ] Connexion réussie (logs visibles)
- [ ] Navigation vers interface principale
- [ ] Message "Bonjour {prénom} !" affiché
- [ ] Boutons fonctionnels sur toutes les pages
- [ ] Déconnexion fonctionnelle

### **Si Tout Fonctionne**

✅ **Félicitations !** Votre application Manounou est maintenant pleinement opérationnelle.

### **Si Problème Persiste**

📞 **Support** : Fournir ces informations :
- Logs Xcode Console complets
- Captures d'écran Supabase Dashboard
- Étapes exactes reproduisant le problème
- Version iOS et Xcode utilisées

---

**💡 Astuce** : Gardez toujours un onglet Supabase ouvert pour surveiller les données en temps réel !

**🔧 Maintenance** : Exécutez ce guide à chaque problème d'authentification.
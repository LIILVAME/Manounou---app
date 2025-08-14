# 🗄️ Guide de Création des Tables Supabase

## ⚠️ IMPORTANT : Tables Manquantes

Si le bouton "Créer un compte" ne fonctionne pas, c'est probablement parce que les tables Supabase n'ont pas encore été créées.

## 🚀 Solution Rapide

### Étape 1 : Accéder au Dashboard Supabase
1. Ouvrir votre navigateur
2. Aller sur : **https://app.supabase.com/project/emgrtgencepzainsknsb/sql**
3. Se connecter à votre compte Supabase

### Étape 2 : Exécuter le Script SQL
1. Dans le SQL Editor, créer une nouvelle requête
2. Copier **TOUT** le contenu du fichier `supabase_setup.sql`
3. Coller dans l'éditeur SQL
4. Cliquer sur **"Run"** ou **"Exécuter"**

### Étape 3 : Vérifier la Création
1. Aller dans l'onglet **"Table Editor"**
2. Vérifier que ces 5 tables sont créées :
   - ✅ `profiles`
   - ✅ `children`
   - ✅ `events`
   - ✅ `documents`
   - ✅ `family_relationships`

### Étape 4 : Tester l'Application
1. Retourner dans l'app iOS
2. Essayer de créer un compte
3. Le bouton devrait maintenant fonctionner !

## 🔧 Dépannage

### Si vous avez des erreurs SQL :
- Vérifiez que vous êtes bien connecté à Supabase
- Assurez-vous d'avoir les permissions d'administration
- Exécutez le script par petites sections si nécessaire

### Si le bouton ne fonctionne toujours pas :
1. Fermer complètement l'app iOS
2. Relancer l'app
3. Essayer à nouveau

## 📱 Test de Création de Compte

Une fois les tables créées, testez avec :
- **Email** : test@example.com
- **Mot de passe** : 123456 (minimum 6 caractères)
- **Prénom** : Test
- **Nom** : User

## ✅ Résultat Attendu

Après création du compte :
1. L'utilisateur est automatiquement connecté
2. Un profil est créé dans la table `profiles`
3. L'app affiche l'interface principale avec les 5 onglets

---

**💡 Astuce** : Gardez l'onglet Supabase ouvert pour pouvoir vérifier les données en temps réel !
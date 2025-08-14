# 🍼 Manounou - Application Familiale iOS

**Version :** 1.0.0  
**Plateforme :** iOS (SwiftUI)  
**Backend :** Supabase  
**Architecture :** MVVM + Combine

---

## 📱 Description

**Manounou** est une application familiale moderne développée en SwiftUI pour iOS. Elle permet aux parents de centraliser la gestion de leurs enfants : profils, événements, documents et bien plus.

### ✨ **Fonctionnalités**
- 🏠 **Dashboard Familial** : Vue d'ensemble personnalisée
- 👶 **Gestion des Enfants** : Profils complets avec allergies et contacts d'urgence
- 📅 **Calendrier Familial** : Planification et suivi des événements
- 📄 **Documents** : Stockage sécurisé des documents importants
- 👤 **Profil Utilisateur** : Gestion des informations personnelles

---

## 🏗️ **Structure du Projet**

```
Manounou-App/
├── 📱 ManounouSwiftUI/          # Application iOS principale
│   ├── Manounou/               # Code source Swift
│   ├── Manounou.xcodeproj/     # Projet Xcode
│   ├── supabase/               # Configuration base de données
│   └── create_documents_table.sql
├── 📚 docs/                    # Documentation centralisée
│   ├── README.md               # Documentation détaillée
│   ├── AUDIT_REPORT_360.md     # Rapport d'audit complet
│   ├── REFACTORING_PLAN.md     # Plan de refactoring
│   ├── guides/                 # Guides techniques
│   └── legal/                  # Documents légaux
├── 🎨 design/                  # Ressources de design
│   ├── assets/                 # Images et icônes
│   ├── copy/                   # Textes et traductions
│   └── tokens.json             # Design tokens
├── 📋 project/                 # Gestion de projet
│   ├── deliverables/           # Livrables
│   ├── scripts/                # Scripts utilitaires
│   └── checklists/             # Listes de vérification
├── 🔧 config/                  # Configuration globale
│   ├── .gitignore
│   ├── .env.example
│   └── project_rules.md
└── 🗄️ _backup/                 # Sauvegardes (code React Native)
```

---

## 🚀 **Démarrage Rapide**

### **1. Prérequis**
- Xcode 15.0+
- iOS 16.0+
- Compte Supabase
- Swift 5.9+

### **2. Installation**
```bash
# Cloner le repository
git clone [URL_DU_REPO]
cd Manounou-App

# Ouvrir le projet iOS
open ManounouSwiftUI/Manounou.xcodeproj
```

### **3. Configuration Supabase**
1. Aller sur [Supabase Dashboard](https://app.supabase.com/project/emgrtgencepzainsknsb/sql)
2. Exécuter le script `ManounouSwiftUI/create_documents_table.sql`
3. Vérifier la configuration dans `ManounouSwiftUI/Manounou/Config.swift`

### **4. Lancer l'Application**
```bash
# Via Xcode
Cmd+R dans Xcode

# Via ligne de commande
cd ManounouSwiftUI
xcodebuild -project Manounou.xcodeproj -scheme Manounou -destination 'platform=iOS Simulator,name=iPhone 15' build
```

---

## 📚 **Documentation**

### **📖 Guides Principaux**
- 📊 **[Audit 360°](docs/AUDIT_REPORT_360.md)** : Analyse complète du projet
- 🗄️ **[Vérification Tables](docs/TABLES_VERIFICATION_REPORT.md)** : État de la base de données
- 🔧 **[Plan Refactoring](docs/REFACTORING_PLAN.md)** : Restructuration du projet

### **🔧 Guides Techniques**
- 📋 **[Création Tables](docs/guides/)** : Configuration Supabase
- 🚨 **[Dépannage Auth](docs/guides/)** : Résolution problèmes authentification
- 📱 **[Développement Lean](docs/guides/)** : Méthodologie de développement

### **⚖️ Documents Légaux**
- 🔒 **[Politique de Confidentialité](docs/legal/PRIVACY_POLICY.md)**
- 📜 **[Conditions d'Utilisation](docs/legal/TERMS_OF_USE.md)**

---

## 🛠️ **Scripts Utilitaires**

### **🗄️ Base de Données**
```bash
# Appliquer la migration Supabase
./project/scripts/apply_migration.sh

# Exécuter du SQL directement
./project/scripts/execute_sql_direct.sh
```

### **📱 Application**
```bash
# Valider pour l'App Store
./project/scripts/validate-app-store.sh

# Déployer l'application
./project/scripts/deploy.sh
```

---

## 🎯 **État du Projet**

### **✅ Fonctionnalités Implémentées**
- [x] Interface SwiftUI complète (5 écrans)
- [x] Authentification Supabase
- [x] Gestion des enfants (CRUD)
- [x] Gestion des événements (CRUD)
- [x] Interface documents (prête)
- [x] Profil utilisateur
- [x] Navigation TabView
- [x] Gestion d'erreur gracieuse

### **🔧 Corrections Récentes**
- [x] Tables Supabase corrigées et optimisées
- [x] Modèles de données synchronisés
- [x] Erreurs HTTP 400 résolues
- [x] Structure projet refactorisée

### **📈 Score Qualité**
- **Architecture** : 8.5/10
- **Interface** : 9/10
- **Fonctionnalités** : 8/10
- **Documentation** : 9/10
- **Maintenabilité** : 9/10

---

## 🧪 **Tests**

### **📱 Tests Manuels**
1. Lancer l'application dans le simulateur
2. Tester la navigation entre les 5 onglets
3. Vérifier les données : 3 enfants existants
4. Tester l'ajout d'enfants avec allergies
5. Créer des événements avec statut
6. Vérifier la page documents

### **🔍 Vérifications**
```sql
-- Dans Supabase Dashboard
SELECT * FROM verify_data_integrity();
SELECT * FROM app_statistics;
```

---

## 🤝 **Contribution**

### **📋 Workflow**
1. Fork le repository
2. Créer une branche feature
3. Développer et tester
4. Créer une Pull Request
5. Review et merge

### **📏 Standards**
- Suivre les conventions Swift
- Documenter le code complexe
- Tester les nouvelles fonctionnalités
- Respecter l'architecture MVVM

---

## 📞 **Support**

- **Documentation** : Dossier `docs/`
- **Issues** : GitHub Issues
- **Email** : support@manounou.app

---

## 🎉 **Changelog**

### **v1.0.0 - 14 Août 2025**
- ✅ Application SwiftUI complète
- ✅ Base de données Supabase optimisée
- ✅ Structure projet refactorisée
- ✅ Documentation complète
- ✅ Scripts d'automatisation

---

**🍼 Manounou - Simplifier la vie familiale avec une technologie moderne**

*Dernière mise à jour : 14 Août 2025*
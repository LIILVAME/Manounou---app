# ⚡ FlutterFlow Quick Reference — Manounou

**Guide rapide pour les actions courantes dans FlutterFlow**

---

## 🔑 Credentials Supabase (Rapide)

```
URL: https://emgrtgencepzainsknsb.supabase.co
Key: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVtZ3J0Z2VuY2VwemFpbnNrbnNiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTUxNjU3MzcsImV4cCI6MjA3MDc0MTczN30.2TtED_BEXHf6UqgPPcuOOd5YYTZlyqLSZRMoZtO93yM
```

---

## 📋 Actions Supabase Courantes

### Authentication

**Sign Up (Email/Password)**
```
Action: Supabase → Create Account
- Email: [variable from input]
- Password: [variable from input]
Success: Navigate to OnboardingPage
Error: Show error message
```

**Sign In (Email/Password)**
```
Action: Supabase → Sign In
- Email: [variable from input]
- Password: [variable from input]
Success: Navigate to DashboardPage
Error: Show error message
```

**Sign Out**
```
Action: Supabase → Sign Out
After: Navigate to LoginPage
```

---

## 🗂️ CRUD Operations

### Create Child
```
Action: Supabase → Insert Row
Table: children
Fields:
  - parent_id: auth.uid()
  - first_name: [variable]
  - birth_date: [variable]
  - info: [variable] (optional)
Success: Navigate to ChildrenListPage
```

### Read Children (List)
```
Action: Supabase → Query Rows
Table: children
Filter: parent_id = auth.uid()
Store in: childrenList
```

### Update Child
```
Action: Supabase → Update Row
Table: children
Filter: id = [child_id]
Fields: [updated fields]
Success: Navigate back
```

### Delete Child
```
Action: Supabase → Delete Row
Table: children
Filter: id = [child_id]
Success: Navigate to ChildrenListPage
```

---

## 🎨 Composants UI Recommandés

### LoginPage
- TextField (Email)
- TextField (Password, obscure)
- ElevatedButton (Sign In)
- TextButton (Register link)
- OutlinedButton (Apple Sign In)

### RegisterPage
- TextField (Email)
- TextField (Password, obscure)
- TextField (Confirm Password, obscure)
- ElevatedButton (Sign Up)
- TextButton (Login link)

### ChildrenListPage
- ListView (Children list)
- FloatingActionButton (Add child)
- Card (Child item)

### ChildFormPage
- TextField (First Name)
- DatePicker (Birth Date)
- TextField (Info, multiline)
- ElevatedButton (Save)
- TextButton (Cancel)

---

## 📱 Navigation

### Bottom Navigation Bar
```
Items:
1. Dashboard → DashboardPage
2. Enfants → ChildrenListPage
3. Calendrier → EventsPage
4. Documents → DocumentsPage
5. Profil → ProfilePage
```

### Navigation Actions
```
Navigate to Page: [select page]
Navigate Back: [go back]
Navigate with Parameters: [pass data]
```

---

## 🔍 Variables Utiles

### Auth Variables
- `auth.uid()` — ID utilisateur connecté
- `auth.email()` — Email utilisateur connecté
- `auth.isAuthenticated` — Boolean

### Page Variables
- `pageParameters.childId` — ID enfant depuis paramètre
- `pageParameters.eventId` — ID événement depuis paramètre

### Data Variables
- `childrenList` — Liste des enfants
- `currentChild` — Enfant sélectionné
- `eventsList` — Liste des événements

---

## 🎯 Workflows Typiques

### Page Load (Liste enfants)
```
1. Query Rows (children)
2. Filter: parent_id = auth.uid()
3. Store in: childrenList
4. Display in ListView
```

### Form Submit (Créer enfant)
```
1. Validate inputs
2. Insert Row (children)
3. If success → Navigate to list
4. If error → Show error
```

### Delete with Confirmation
```
1. Show Dialog (Confirm delete?)
2. If confirmed → Delete Row
3. If success → Navigate to list
```

---

## 🐛 Troubleshooting Rapide

**Action ne fonctionne pas ?**
- Vérifier les types de variables
- Vérifier les noms de colonnes
- Tester chaque action individuellement

**Données non affichées ?**
- Vérifier le filtre (parent_id = auth.uid())
- Vérifier RLS dans Supabase
- Vérifier que l'utilisateur est connecté

**Navigation ne fonctionne pas ?**
- Vérifier que la page existe
- Vérifier les paramètres de navigation
- Vérifier les conditions (if/else)

---

## 📚 Liens Utiles

- **Guide complet** : `/docs/FLUTTERFLOW_SETUP_COMPLETE.md`
- **Roadmap** : `/product/ROADMAP.md`
- **Schéma Supabase** : `/data/schema.sql`

---

**Document maintenu par :** MultiApp Builder Team  
**Dernière mise à jour :** 2025-01-13


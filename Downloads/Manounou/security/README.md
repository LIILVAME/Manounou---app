# 🔐 Security — Manounou

**Dossier :** `/security`  
**Contenu :** Policies RLS, règles de sécurité, conformité RGPD

---

## 📄 Fichiers

- **[policies.sql](./policies.sql)** — Policies Row Level Security (RLS) complètes
- **[README.md](./README.md)** — Ce fichier

---

## 🛡️ Row Level Security (RLS)

**RLS activé sur toutes les tables :**
- ✅ `users`
- ✅ `children`
- ✅ `events`
- ✅ `documents`

---

## 🔒 Policies Définies

### 1. Users — "Users can access their own profile"
- **Accès** : Utilisateur peut lire/modifier uniquement son propre profil
- **Condition** : `auth.uid() = id`

### 2. Children — "Parents can access their children"
- **Accès** : Parent peut accéder uniquement à ses enfants
- **Condition** : `auth.uid() = parent_id`

### 3. Events — "Parents can access their events"
- **Accès** : Parent peut accéder aux événements de ses enfants
- **Condition** : `auth.uid() IN (SELECT parent_id FROM children WHERE id = events.child_id)`

### 4. Documents — "Parents can access their documents"
- **Accès** : Parent peut accéder aux documents de ses enfants
- **Condition** : `auth.uid() IN (SELECT parent_id FROM children WHERE id = documents.child_id)`

---

## ✅ Tests de Sécurité

### Vérifier l'isolation des données

```sql
-- Test 1 : Utilisateur A ne peut pas voir les enfants de l'utilisateur B
-- (Tester avec deux comptes différents)

-- Test 2 : Utilisateur ne peut pas modifier les données d'un autre utilisateur
-- (Tester UPDATE/DELETE avec auth.uid() différent)

-- Test 3 : RLS bloque les requêtes non authentifiées
-- (Tester sans token auth)
```

---

## 🔍 Advisors Supabase

Exécuter régulièrement :
```bash
mcp_supabase_get_advisors type=security
```

**Warnings courants à surveiller :**
- ⚠️ Functions avec search_path mutable (corrigé pour `update_updated_at_column`)
- ⚠️ Leaked password protection (activer dans Auth settings)
- ⚠️ MFA options (activer MFA dans Auth settings)
- ⚠️ Postgres version (mettre à jour si patchs disponibles)

---

## 📋 Checklist Sécurité

- [x] RLS activé sur toutes les tables
- [x] Policies créées pour toutes les tables
- [x] Functions sécurisées (search_path fixé)
- [ ] Tests d'isolation données effectués
- [ ] Leaked password protection activé (Auth settings)
- [ ] MFA activé (Auth settings)
- [ ] Storage bucket sécurisé (policies d'accès)

---

## 🚀 Application des Policies

### Via SQL Editor Supabase
1. Ouvrir l'éditeur SQL dans le dashboard
2. Copier le contenu de `policies.sql`
3. Exécuter le script

### Via MCP Supabase
```bash
# Migration automatique
mcp_supabase_apply_migration enable_rls_and_policies
```

---

## 📚 Conformité RGPD

### Principes appliqués
- ✅ **Minimisation des données** : Seules les données nécessaires sont stockées
- ✅ **Isolation stricte** : RLS garantit que chaque utilisateur ne voit que ses données
- ✅ **Droit à l'effacement** : Suppression en cascade (ON DELETE CASCADE)
- ✅ **Sécurité** : Données chiffrées en transit (HTTPS) et au repos (Supabase)

### Actions à prévoir
- [ ] Politique de confidentialité
- [ ] Consentement utilisateur (RGPD)
- [ ] Export données utilisateur (droit à la portabilité)
- [ ] Suppression compte (droit à l'oubli)

---

**Voir aussi :**
- `/data/schema.sql` — Schéma de base de données
- `/product/ROADMAP.md` — Roadmap produit


# ⚡ Quick Start — Manounou

**Objectif :** Démarrer rapidement le développement de Manounou  
**Durée estimée :** 30 minutes

---

## ✅ Étape 1 : Vérifier Supabase (5 min)

### État actuel
- ✅ Schéma créé (4 tables : users, children, events, documents)
- ✅ RLS activé sur toutes les tables
- ✅ Policies créées (isolation par utilisateur)
- ✅ Bucket Storage "documents" créé
- ✅ Policies Storage configurées

**Vérification :**
```bash
# Via MCP Supabase (déjà fait)
mcp_supabase_list_tables
```

**✅ Status :** Supabase prêt

---

## 🚀 Étape 2 : Setup FlutterFlow (15 min)

### 2.1 Créer le projet
1. Aller sur [flutterflow.io](https://flutterflow.io)
2. Créer compte ou se connecter
3. **Create New Project** → Nom : `Manounou`
4. Template : **Blank App**

### 2.2 Récupérer credentials Supabase
1. Aller sur [supabase.com/dashboard](https://supabase.com/dashboard)
2. Sélectionner projet "Manounou"
3. **Settings → API**
4. Copier :
   - **Project URL** : `https://xxxxx.supabase.co`
   - **Anon Key** : `eyJhbGc...`

**Voir guide détaillé :** [SUPABASE_CREDENTIALS.md](./SUPABASE_CREDENTIALS.md)

### 2.3 Connecter Supabase dans FlutterFlow
1. FlutterFlow → **Settings → Integrations**
2. Chercher **Supabase** → **Connect**
3. Remplir :
   - **Supabase URL** : Project URL
   - **Supabase Anon Key** : Anon Key
4. **Test Connection** → Si succès → **Save**

### 2.4 Importer les tables
1. FlutterFlow → **Data → Supabase**
2. **Import Tables**
3. Sélectionner les 4 tables :
   - ✅ `users`
   - ✅ `children`
   - ✅ `events`
   - ✅ `documents`
4. **Import**

**Voir guide détaillé :** [FLUTTERFLOW_SETUP.md](./FLUTTERFLOW_SETUP.md)

---

## 🎨 Étape 3 : Créer les pages de base (10 min)

### Pages à créer (squelettes pour l'instant)

1. **LoginPage**
   - Champ email
   - Champ mot de passe
   - Bouton "Se connecter"
   - Lien "Créer un compte"

2. **RegisterPage**
   - Champ email
   - Champ mot de passe
   - Champ confirmation
   - Bouton "S'inscrire"

3. **DashboardPage**
   - Header avec nom utilisateur
   - Cards vides (à remplir plus tard)

4. **ProfilePage**
   - Nom utilisateur
   - Email
   - Bouton "Déconnexion"

---

## ✅ Checklist Rápide

- [x] Supabase configuré
- [ ] FlutterFlow projet créé
- [ ] Supabase connecté dans FlutterFlow
- [ ] Tables importées
- [ ] Pages de base créées (squelettes)

---

## 🎯 Prochaine Étape

**Semaine 1 — Jour 2 :**
- Créer workflows Authentication (Sign Up, Sign In)
- Tester l'authentification
- Créer navigation Bottom Bar

**Voir :** [ROADMAP Phase 1](../../product/ROADMAP.md#phase-1--fondations--mvp-core-semaines-1-4)

---

## 📚 Ressources

- **Roadmap complète** : `/product/ROADMAP.md`
- **Checklist Phase 1** : `/product/CHECKLIST_PHASE1.md`
- **Guide FlutterFlow** : [FLUTTERFLOW_SETUP.md](./FLUTTERFLOW_SETUP.md)
- **Guide credentials** : [SUPABASE_CREDENTIALS.md](./SUPABASE_CREDENTIALS.md)

---

**Temps total estimé :** 30 minutes  
**Prêt pour :** Semaine 1 — Jour 2 (Workflows Authentication)

---

**Document maintenu par :** MultiApp Builder Team  
**Dernière mise à jour :** 2025-01-13


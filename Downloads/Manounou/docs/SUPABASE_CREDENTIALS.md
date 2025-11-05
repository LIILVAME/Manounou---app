# 🔐 Supabase Credentials — Manounou

**⚠️ IMPORTANT :** Ce fichier contient des informations sensibles. Ne pas commiter dans Git.

---

## 📋 Credentials Récupérés (via MCP)

### Project URL
```
https://emgrtgencepzainsknsb.supabase.co
```

### Anon Key (Public)
```
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVtZ3J0Z2VuY2VwemFpbnNrbnNiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTUxNjU3MzcsImV4cCI6MjA3MDc0MTczN30.2TtED_BEXHf6UqgPPcuOOd5YYTZlyqLSZRMoZtO93yM
```

---

## ✅ Configuration Appliquée

Les credentials ont été automatiquement configurés dans :
- ✅ `/flutterflow_export/lib/main.dart` — Configuration Supabase

---

## 📝 Configuration FlutterFlow

### Dans FlutterFlow → Settings → Integrations → Supabase :

- **Supabase URL** : `https://emgrtgencepzainsknsb.supabase.co`
- **Supabase Anon Key** : `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVtZ3J0Z2VuY2VwemFpbnNrbnNiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTUxNjU3MzcsImV4cCI6MjA3MDc0MTczN30.2TtED_BEXHf6UqgPPcuOOd5YYTZlyqLSZRMoZtO93yM`

---

## 🔒 Sécurité

### ✅ À faire
- Utiliser uniquement l'**Anon Key** dans FlutterFlow
- RLS activé sur toutes les tables (déjà fait)
- Policies créées pour isolation données (déjà fait)

### ❌ À ne jamais faire
- Exposer Service Role Key côté client
- Commiter les credentials dans Git
- Partager les credentials publiquement

---

## 📚 Documentation

- **Setup FlutterFlow** : `/docs/FLUTTERFLOW_SETUP.md`
- **Schéma Supabase** : `/data/schema.sql`
- **Policies RLS** : `/security/policies.sql`

---

**Document maintenu par :** MultiApp Builder Team  
**Dernière mise à jour :** 2025-01-13  
**Credentials récupérés via :** MCP Supabase

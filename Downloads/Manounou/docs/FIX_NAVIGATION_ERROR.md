# 🔧 Fix Navigation Error — Manounou

**Problème :** `GoError: There is nothing to pop` lors de l'enregistrement d'un enfant  
**Cause :** Utilisation de `context.go()` au lieu de `context.push()` pour naviguer  
**Solution :** Utiliser `context.push()` pour les formulaires et vérifier `Navigator.canPop()` avant de pop

---

## 🚨 Problème Identifié

L'erreur se produit car :
- La page `ChildFormPage` est ouverte avec `context.go('/children/new')`
- `context.go()` remplace la route actuelle au lieu d'ajouter à la pile
- Quand on essaie de `context.pop()`, il n'y a rien à "pop" car la route n'a pas été "pushed"

**Erreur :**
```
GoError: There is nothing to pop
```

---

## ✅ Solution Appliquée

### 1. Utiliser `context.push()` pour les formulaires

**Fichier :** `children_list_page.dart`

```dart
// Avant
onPressed: () => context.go('/children/new'),

// Après
onPressed: () => context.push('/children/new'),
```

**Fichier :** `child_detail_page.dart`

```dart
// Avant
onPressed: () => context.go('/children/${widget.childId}/edit'),

// Après
onPressed: () => context.push('/children/${widget.childId}/edit'),
```

### 2. Vérifier avant de pop

**Fichier :** `child_form_page.dart`

```dart
// Après sauvegarde
if (Navigator.canPop(context)) {
  context.pop();
} else {
  context.go('/children');
}
```

### 3. Recharger la liste après création

```dart
// Recharger la liste des enfants
final childrenService = context.read<ChildrenService>();
await childrenService.loadChildren();

// Puis pop
if (Navigator.canPop(context)) {
  context.pop();
} else {
  context.go('/children');
}
```

---

## 📋 Différence entre `go()` et `push()`

### `context.go()`
- **Remplace** la route actuelle
- **N'ajoute pas** à la pile de navigation
- **Ne peut pas** être "popped"
- **Utilisation :** Navigation principale (liste, dashboard, etc.)

### `context.push()`
- **Ajoute** une nouvelle route à la pile
- **Peut être** "popped" pour revenir
- **Utilisation :** Formulaires, modales, pages temporaires

---

## 🧪 Test

**Après correction :**

1. Aller sur "Mes enfants"
2. Cliquer sur le FAB (+) pour ajouter un enfant
3. Remplir le formulaire
4. Cliquer sur "Ajouter"
5. ✅ Devrait retourner à la liste sans erreur
6. ✅ L'enfant devrait apparaître dans la liste

---

## ✅ Checklist

- [x] Utiliser `context.push()` pour ouvrir les formulaires
- [x] Vérifier `Navigator.canPop()` avant de pop
- [x] Recharger la liste après création/modification
- [x] Gérer le cas où il n'y a rien à pop (fallback vers `go()`)

---

## 📚 Ressources

- **GoRouter Navigation** : [pub.dev/packages/go_router](https://pub.dev/packages/go_router)
- **Flutter Navigation** : [flutter.dev/docs/development/ui/navigation](https://flutter.dev/docs/development/ui/navigation)

---

**Document maintenu par :** MultiApp Builder Team  
**Dernière mise à jour :** 2025-01-13


# 🎨 Design System — Manounou

**Version :** 1.0.0  
**Date :** 2025-01-13  
**Status :** ✅ Implémenté

---

## 🎯 Principes

### Vision
Interface **bienveillante, claire et rassurante** pour les familles.

### Valeurs
- **Simplicité** : Navigation intuitive, actions claires
- **Sérénité** : Couleurs pastels apaisantes
- **Confiance** : Sécurité des données, design professionnel
- **Accessibilité** : Lisibilité, contrastes suffisants

---

## 🎨 Palette de Couleurs

### Couleurs Primaires
- **Primary** : `#FFB6C1` (Pastel Pink)
- **Primary Light** : `#FFE4E1` (Light Pink)
- **Primary Dark** : `#FF69B4` (Hot Pink)

### Couleurs Secondaires
- **Secondary** : `#B0E0E6` (Powder Blue)
- **Secondary Light** : `#E0F7FA` (Light Blue)
- **Secondary Dark** : `#87CEEB` (Sky Blue)

### Couleurs Accent
- **Accent** : `#FFD700` (Gold)
- **Accent Light** : `#FFF8DC` (Cornsilk)
- **Accent Dark** : `#FFA500` (Orange)

### Couleurs Texte
- **Text Primary** : `#2C3E50` (Dark Blue Grey)
- **Text Secondary** : `#7F8C8D` (Grey)
- **Text Light** : `#95A5A6` (Light Grey)

### Couleurs de Fond
- **Background** : `#FAFAFA` (Off White)
- **Surface** : `#FFFFFF` (White)
- **Surface Variant** : `#F5F5F5` (Light Grey)

### Couleurs d'État
- **Success** : `#4CAF50` (Green)
- **Warning** : `#FFC107` (Amber)
- **Error** : `#E53935` (Red)
- **Info** : `#2196F3` (Blue)

### Couleurs pour Enfants (Pastel)
- Pink, Blue, Gold, Mint, Light Salmon, Plum, Sky Blue, Moccasin

**Fichier :** `/flutterflow_export/lib/core/theme/app_colors.dart`

---

## 📝 Typographie

### Police Principale
- **SF Rounded** (iOS) / **Nunito** (fallback Android)
- **Style :** Arrondie, bienveillante

### Tailles
- **H1** : 32px, Bold
- **H2** : 24px, Bold
- **H3** : 20px, Bold
- **Body Large** : 16px
- **Body Medium** : 14px
- **Body Small** : 12px
- **Caption** : 12px, Grey

**Fichier :** `/flutterflow_export/lib/core/theme/app_text_styles.dart`

---

## 📏 Espacements

### Standard
- **XS** : 4px
- **SM** : 8px
- **MD** : 16px
- **LG** : 24px
- **XL** : 32px
- **XXL** : 48px

### Padding
- **Standard** : 16px
- **Large** : 24px
- **Small** : 8px

**Fichier :** `/flutterflow_export/lib/core/theme/app_spacing.dart`

---

## 🧩 Composants Réutilisables

### ChildAvatar
**Fichier :** `/flutterflow_export/lib/core/widgets/child_avatar.dart`

**Usage :**
```dart
ChildAvatar(
  firstName: 'Emma',
  photoUrl: child.photoUrl,
  radius: 30,
)
```

**Fonctionnalités :**
- Affiche photo si disponible
- Fallback vers initiale du prénom
- Couleurs pastels automatiques

---

### ManounouCard
**Fichier :** `/flutterflow_export/lib/core/widgets/manounou_card.dart`

**Usage :**
```dart
ManounouCard(
  onTap: () => context.go('/children'),
  child: Column(
    children: [...],
  ),
)
```

**Propriétés :**
- Border radius 16px
- Elevation 2
- Padding 16px par défaut
- Tap area avec InkWell

---

### ManounouButton
**Fichier :** `/flutterflow_export/lib/core/widgets/manounou_button.dart`

**Usage :**
```dart
ManounouButton(
  label: 'Enregistrer',
  icon: Icons.save,
  onPressed: _handleSave,
  isLoading: _isSaving,
)
```

**Variantes :**
- `isOutlined: true` → OutlinedButton
- `isLoading: true` → Affiche CircularProgressIndicator
- Support icon optionnel

---

## 🎭 Éléments UI

### Cards
- **Border radius** : 16px
- **Elevation** : 2
- **Padding** : 16px
- **Couleur** : White

### Boutons
- **Border radius** : 12px
- **Padding vertical** : 16px
- **Couleur primaire** : Pastel Pink
- **États** : Normal, Hover, Disabled, Loading

### Inputs
- **Border radius** : 12px
- **Icon prefix** : Optionnel
- **Validation** : Messages d'erreur clairs

### Avatars
- **Photo** : Si disponible
- **Fallback** : Initiale du prénom
- **Couleur** : Pastel selon index

---

## 📐 Guidelines

### Layout
- **Padding standard** : 16px sur toutes les pages
- **Marges entre sections** : 24px
- **Marges entre éléments** : 16px

### Navigation
- **Bottom Bar** : Fixed, 5 onglets
- **AppBar** : Elevation 0 (design moderne)
- **Transitions** : Fluides, sans animation excessive

### Responsive
- **Mobile first** : Design optimisé pour mobile
- **Tablette** : Adaptation future
- **Breakpoints** : À définir selon besoins

---

## ✅ Checklist Implémentation

### Composants
- [x] ChildAvatar
- [x] ManounouCard
- [x] ManounouButton
- [ ] ManounouInput (à créer si besoin)
- [ ] ManounouDialog (à créer si besoin)

### Thème
- [x] AppColors
- [x] AppTextStyles
- [x] AppSpacing
- [x] ThemeData dans main.dart

### Usage
- [x] Cards utilisent ManounouCard
- [x] Avatars utilisent ChildAvatar
- [x] Couleurs utilisent AppColors
- [x] Espacements utilisent AppSpacing

---

## 📚 Ressources

- **Palette couleurs** : `/flutterflow_export/lib/core/theme/app_colors.dart`
- **Typographie** : `/flutterflow_export/lib/core/theme/app_text_styles.dart`
- **Espacements** : `/flutterflow_export/lib/core/theme/app_spacing.dart`
- **Composants** : `/flutterflow_export/lib/core/widgets/`

---

**Document maintenu par :** MultiApp Builder Team  
**Dernière mise à jour :** 2025-01-13


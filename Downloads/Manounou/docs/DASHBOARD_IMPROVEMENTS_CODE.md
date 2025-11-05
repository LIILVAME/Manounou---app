# 🔧 Code d'Amélioration Dashboard - Implémentations Prêtes

**Complément à :** `AUDIT_DASHBOARD_UI_UX.md`  
**Objectif :** Fournir le code prêt à l'emploi pour les améliorations prioritaires

---

## 🔴 Priorité 1 : États de Chargement et Erreur

### 1.1 Dashboard avec États Complets

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../core/services/children_service.dart';
import '../../core/theme/famplan_colors.dart';
import '../../core/widgets/famplan_card.dart';
import '../../core/widgets/animated_avatar.dart';
import '../../core/widgets/animated_fab.dart';
import '../../core/widgets/scale_tap_wrapper.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/shimmer_loading.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadChildren();
    });
  }

  Future<void> _loadChildren() async {
    setState(() => _errorMessage = null);
    try {
      await context.read<ChildrenService>().loadChildren();
    } catch (e) {
      setState(() => _errorMessage = 'Erreur lors du chargement: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final childrenService = context.watch<ChildrenService>();
    final children = childrenService.children;

    return Scaffold(
      backgroundColor: FamPlanColors.backgroundWhite,
      appBar: AppBar(
        title: const Text(
          'Organiser votre semaine',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: FamPlanColors.textDark,
          ),
        ),
        elevation: 0,
        backgroundColor: FamPlanColors.backgroundWhite,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: FamPlanColors.textDark),
            onPressed: () {
              // TODO: Implémenter recherche
            },
          ),
        ],
      ),
      body: _buildBody(childrenService, children),
      floatingActionButton: AnimatedFloatingActionButton(
        onPressed: () => context.go('/children/new'),
        icon: Icons.add,
        backgroundColor: FamPlanColors.tealGreen,
        foregroundColor: FamPlanColors.white,
        tooltip: 'Ajouter un enfant',
        enableRotation: true,
      ),
    );
  }

  Widget _buildBody(ChildrenService service, List children) {
    // État de chargement
    if (service.isLoading) {
      return _buildLoadingState();
    }

    // État d'erreur (si erreur lors du chargement)
    if (_errorMessage != null) {
      return _buildErrorState();
    }

    // État vide (seulement si pas de chargement et pas d'erreur)
    if (children.isEmpty && !service.isLoading) {
      return _buildEmptyState();
    }

    // État succès
    return _buildSuccessState(children);
  }

  Widget _buildLoadingState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Shimmer pour les tabs
          Row(
            children: List.generate(3, (i) => Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ShimmerLoading(
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
            )),
          ),
          const SizedBox(height: 24),
          // Shimmer pour les cartes
          ...List.generate(3, (i) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: ChildCardShimmer(),
          )),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return EmptyState(
      icon: Icons.error_outline,
      title: 'Erreur de chargement',
      subtitle: _errorMessage ?? 'Impossible de charger les enfants',
      actionLabel: 'Réessayer',
      onAction: _loadChildren,
      iconColor: Colors.red[300],
    );
  }

  Widget _buildEmptyState() {
    return EmptyState(
      icon: Icons.child_care,
      title: 'Aucun enfant enregistré',
      subtitle: 'Commencez par ajouter votre premier enfant pour organiser votre famille',
      actionLabel: 'Ajouter un enfant',
      onAction: () => context.go('/children/new'),
      iconColor: FamPlanColors.tealGreen,
    );
  }

  Widget _buildSuccessState(List children) {
    return RefreshIndicator(
      onRefresh: _loadChildren,
      color: FamPlanColors.tealGreen,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section "Famille heureuse" (améliorée)
            _buildFamilySection(children),
            const SizedBox(height: 24),
            
            // Titre section enfants
            const Text(
              'Membres de la famille',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: FamPlanColors.textDark,
              ),
            ),
            const SizedBox(height: 16),
            
            // Cards d'enfants (tous les enfants, pas seulement 3)
            ...children.map((child) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildChildCard(child),
            )),
            
            const SizedBox(height: 16),
            
            // Liste horizontale avatars
            _buildAvatarsList(children),
          ],
        ),
      ),
    );
  }

  Widget _buildFamilySection(List children) {
    return InkWell(
      onTap: () => context.go('/children'),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: FamPlanColors.backgroundLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [FamPlanColors.orange, FamPlanColors.blue, FamPlanColors.tealGreen],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.favorite,
                color: FamPlanColors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Famille heureuse',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: FamPlanColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Vous avez ${children.length} enfant${children.length > 1 ? 's' : ''} dans votre famille',
                    style: const TextStyle(
                      fontSize: 14,
                      color: FamPlanColors.textLight,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: FamPlanColors.textLight),
          ],
        ),
      ),
    );
  }

  Widget _buildChildCard(dynamic child) {
    return FamPlanCard(
      backgroundColor: FamPlanColors.getCardColor(children.indexOf(child)),
      onTap: () => context.go('/children/${child.id}'),
      leadingIcon: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: FamPlanColors.white.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          child.gender == 'F' ? Icons.female : Icons.male,
          color: FamPlanColors.white,
        ),
      ),
      trailingIcon: _buildChildMenu(child),
      title: child.firstName,
      subtitle: child.age != null
          ? '${child.age} ans'
          : child.birthDate != null
              ? 'Né${child.birthDate!.day == 1 ? 'e' : ''} le ${DateFormat('dd MMMM', 'fr_FR').format(child.birthDate!)}'
              : 'Enfant',
    );
  }

  Widget _buildChildMenu(dynamic child) {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert,
        color: FamPlanColors.white,
      ),
      color: FamPlanColors.white,
      onSelected: (value) {
        switch (value) {
          case 'edit':
            context.go('/children/${child.id}/edit');
            break;
          case 'delete':
            _showDeleteDialog(child);
            break;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit, size: 20, color: FamPlanColors.textDark),
              SizedBox(width: 8),
              Text('Modifier'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, size: 20, color: Colors.red),
              SizedBox(width: 8),
              Text('Supprimer', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarsList(List children) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: children.length + 1,
        itemBuilder: (context, index) {
          if (index == children.length) {
            return Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Column(
                children: [
                  ScaleTapWrapper(
                    onTap: () => context.go('/children/new'),
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: FamPlanColors.backgroundLight,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: FamPlanColors.textLight.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.add,
                        color: FamPlanColors.textDark,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Ajouter',
                    style: TextStyle(
                      fontSize: 12,
                      color: FamPlanColors.textLight,
                    ),
                  ),
                ],
              ),
            );
          }
          
          final child = children[index];
          return Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Column(
              children: [
                ScaleTapWrapper(
                  onTap: () => context.go('/children/${child.id}'),
                  child: AnimatedAvatar(
                    firstName: child.firstName,
                    photoUrl: child.photoUrl,
                    gender: child.gender,
                    radius: 35,
                    enableScaleAnimation: true,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  child.firstName,
                  style: const TextStyle(
                    fontSize: 12,
                    color: FamPlanColors.textDark,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showDeleteDialog(dynamic child) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer l\'enfant'),
        content: Text('Êtes-vous sûr de vouloir supprimer ${child.firstName} ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await context.read<ChildrenService>().deleteChild(child.id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${child.firstName} a été supprimé')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erreur: $e')),
                  );
                }
              }
            },
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
```

---

## 🟠 Priorité 2 : Supprimer ou Implémenter les Tabs

### Option A : Supprimer les Tabs (Recommandé si pas de fonctionnalité)

```dart
// Supprimer complètement cette section :
// Row(
//   children: [
//     _buildTab(context, 'Tous', true),
//     const SizedBox(width: 16),
//     _buildTab(context, 'Populaires', false),
//     const SizedBox(width: 16),
//     _buildTab(context, 'Catégories', false),
//   ],
// ),
// const SizedBox(height: 24),
```

### Option B : Implémenter les Tabs

```dart
class _DashboardPageState extends State<DashboardPage> {
  String _selectedTab = 'Tous';
  
  // ... autres variables

  List<Child> _getFilteredChildren(List<Child> allChildren) {
    switch (_selectedTab) {
      case 'Populaires':
        // Exemple : enfants avec le plus d'événements
        return allChildren..sort((a, b) {
          // Logique de tri par popularité
          return 0;
        });
      case 'Catégories':
        // Exemple : grouper par genre
        return allChildren;
      default:
        return allChildren;
    }
  }

  Widget _buildTab(String label, String value) {
    final isActive = _selectedTab == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? FamPlanColors.textDark : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? FamPlanColors.white : FamPlanColors.textDark,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  // Dans buildSuccessState, utiliser :
  final filteredChildren = _getFilteredChildren(children);
  // ... au lieu de children
}
```

---

## 🎨 Amélioration Visuelle : Section "Famille heureuse"

La section est déjà améliorée dans le code ci-dessus avec :
- `InkWell` pour rendre cliquable
- `chevron_right` au lieu de `more_horiz`
- Navigation vers `/children` au tap

---

## 📊 Checklist d'Implémentation

### Phase 1 : États Critiques
- [x] Code de chargement avec ShimmerLoading
- [x] Code d'erreur avec EmptyState
- [x] Code d'état vide amélioré
- [x] Pull-to-refresh ajouté

### Phase 2 : Navigation
- [x] Menu contextuel sur les cartes
- [x] Icône corrigée (gender au lieu de check)
- [ ] Supprimer ou implémenter les tabs

### Phase 3 : Améliorations
- [x] Afficher tous les enfants (pas seulement 3)
- [x] Section "Famille heureuse" cliquable
- [x] Gestion d'erreur avec retry

---

## 🚀 Prochaines Étapes

1. **Remplacer** `dashboard_page.dart` par le code ci-dessus
2. **Tester** tous les états (loading, error, empty, success)
3. **Décider** : supprimer ou implémenter les tabs
4. **Valider** sur différents écrans (SE, Pro Max)

---

**Note :** Le code ci-dessus est prêt à l'emploi et respecte les patterns existants de Manounou.


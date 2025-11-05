import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/services/children_service.dart';
import '../../core/theme/famplan_colors.dart';
import '../../core/widgets/animated_child_card.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/shimmer_loading.dart';
import '../../core/widgets/elegant_snackbar.dart';
import '../../core/widgets/animated_fab.dart';

class ChildrenListPage extends StatefulWidget {
  const ChildrenListPage({super.key});

  @override
  State<ChildrenListPage> createState() => _ChildrenListPageState();
}

class _ChildrenListPageState extends State<ChildrenListPage> {
  @override
  void initState() {
    super.initState();
    // Charger les enfants au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChildrenService>().loadChildren();
    });
  }

  @override
  Widget build(BuildContext context) {
    final childrenService = context.watch<ChildrenService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes enfants'),
        elevation: 0,
      ),
      body: childrenService.isLoading
          ? _buildLoadingState()
          : childrenService.children.isEmpty
              ? _buildEmptyState(context)
              : _buildChildrenList(context, childrenService.children),
      floatingActionButton: AnimatedFloatingActionButton(
        onPressed: () => context.push('/children/new'),
        icon: Icons.add,
        backgroundColor: FamPlanColors.tealGreen,
        foregroundColor: FamPlanColors.white,
        tooltip: 'Ajouter un enfant',
        enableRotation: true,
      ),
    );
  }

  Widget _buildLoadingState() {
    return RefreshIndicator(
      onRefresh: () => context.read<ChildrenService>().loadChildren(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: 3,
        itemBuilder: (context, index) => const ChildCardShimmer(),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => context.read<ChildrenService>().loadChildren(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: EmptyState(
          icon: Icons.child_care_outlined,
          title: 'Aucun enfant pour le moment',
          subtitle: 'Ajoutez votre premier enfant pour commencer',
          actionLabel: 'Ajouter un enfant',
          onAction: () => context.push('/children/new'),
        ),
      ),
    );
  }

  Widget _buildChildrenList(BuildContext context, List<Child> children) {
    final childrenService = context.watch<ChildrenService>();
    
    return RefreshIndicator(
      onRefresh: () => context.read<ChildrenService>().loadChildren(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: children.length,
        itemBuilder: (context, index) {
          final child = children[index];
          return AnimatedChildCard(
            child: child,
            index: index,
            onTap: () => context.go('/children/${child.id}'),
            onDelete: () => _handleDelete(context, child, childrenService),
          );
        },
      ),
    );
  }

  Future<void> _handleDelete(
    BuildContext context,
    Child child,
    ChildrenService childrenService,
  ) async {
    try {
      await childrenService.deleteChild(child.id);
      if (context.mounted) {
        ElegantSnackbar.showSuccess(
          context,
          '${child.firstName} a été supprimé',
        );
      }
    } catch (e) {
      if (context.mounted) {
        ElegantSnackbar.showError(
          context,
          'Erreur lors de la suppression: $e',
        );
      }
    }
  }
}


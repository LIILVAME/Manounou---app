import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/services/children_service.dart';
import '../../core/theme/famplan_colors.dart';
import '../../core/widgets/famplan_card.dart';
import '../../core/widgets/animated_avatar.dart';
import '../../core/widgets/animated_fab.dart';
import '../../core/widgets/scale_tap_wrapper.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/shimmer_loading.dart';
import '../../core/utils/date_helper.dart';

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
    // Charger les enfants au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadChildren();
    });
  }

  Future<void> _loadChildren() async {
    setState(() => _errorMessage = null);
    try {
      await context.read<ChildrenService>().loadChildren();
      
      // Vérifier si l'utilisateur est toujours connecté après le chargement
      final session = Supabase.instance.client.auth.currentSession;
      if (session == null) {
        // Rediriger vers login si pas de session
        if (mounted) {
          context.go('/login');
        }
        return;
      }
    } catch (e) {
      final errorString = e.toString();
      
      // Si erreur d'authentification, proposer de se reconnecter
      if (errorString.contains('Auth') || 
          errorString.contains('session') ||
          errorString.contains('oauth_client_id')) {
        setState(() {
          _errorMessage = 'Session expirée. Veuillez vous reconnecter.';
        });
        
        // Rediriger vers login après un court délai
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            context.go('/login');
          }
        });
      } else {
        setState(() {
          _errorMessage = 'Erreur lors du chargement. Veuillez réessayer.';
        });
      }
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Shimmer pour la section "Famille heureuse"
          ShimmerLoading(
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Shimmer pour le titre "Membres de la famille"
          ShimmerLoading(
            child: Container(
              height: 24,
              width: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Shimmer pour les cartes (2 par ligne)
          ...List.generate(2, (rowIndex) {
            return Padding(
              padding: EdgeInsets.only(bottom: rowIndex < 1 ? 16 : 0),
              child: Row(
                children: [
                  const Expanded(
                    child: ChildCardShimmer(),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: ChildCardShimmer(),
                  ),
                ],
              ),
            );
          }),
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
            // Section "Famille heureuse" (améliorée et cliquable)
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
            
            // Grille de cartes d'enfants (2 par ligne)
            _buildChildrenGrid(children),
            
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

  Widget _buildChildrenGrid(List children) {
    if (children.isEmpty) {
      return const SizedBox.shrink();
    }

    // Créer des paires d'enfants pour afficher 2 par ligne
    final rows = <List<dynamic>>[];
    for (int i = 0; i < children.length; i += 2) {
      if (i + 1 < children.length) {
        // Paire complète
        rows.add([children[i], children[i + 1]]);
      } else {
        // Dernier enfant seul (cas impair)
        rows.add([children[i]]);
      }
    }

    return Column(
      children: rows.asMap().entries.map((entry) {
        final rowIndex = entry.key;
        final rowChildren = entry.value;
        
        return Padding(
          padding: EdgeInsets.only(
            bottom: rowIndex < rows.length - 1 ? 16 : 0,
          ),
          child: Row(
            children: [
              // Première carte
              Expanded(
                child: _buildChildCard(rowChildren[0], rowIndex * 2),
              ),
              // Espacement entre les cartes
              if (rowChildren.length > 1) ...[
                const SizedBox(width: 16),
                // Deuxième carte
                Expanded(
                  child: _buildChildCard(rowChildren[1], rowIndex * 2 + 1),
                ),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildChildCard(dynamic child, int index) {
    return Semantics(
      label: 'Carte de ${child.firstName}, ${child.age != null ? "${child.age} ans" : "enfant"}',
      button: true,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: 120, // Hauteur minimale pour cohérence visuelle
        ),
        child: FamPlanCard(
          backgroundColor: FamPlanColors.getCardColor(index),
          onTap: () => context.go('/children/${child.id}'),
          leadingIcon: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: FamPlanColors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              child.gender == 'F' ? Icons.female : Icons.male,
              color: FamPlanColors.white,
              semanticLabel: child.gender == 'F' ? 'Fille' : 'Garçon',
            ),
          ),
          trailingIcon: _buildChildMenu(child),
          title: child.firstName,
          subtitle: child.age != null
              ? '${child.age} ans'
              : child.birthDate != null
                  ? DateHelper.formatBirthDateShort(child.birthDate!)
                  : 'Enfant',
        ),
      ),
    );
  }

  Widget _buildChildMenu(dynamic child) {
    return PopupMenuButton<String>(
      icon: const Icon(
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
                          color: FamPlanColors.textLight.withValues(alpha: 0.3),
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
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              try {
                await context.read<ChildrenService>().deleteChild(child.id);
                if (mounted) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text('${child.firstName} a été supprimé'),
                      backgroundColor: FamPlanColors.tealGreen,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text('Erreur: $e'),
                      backgroundColor: Colors.red,
                    ),
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

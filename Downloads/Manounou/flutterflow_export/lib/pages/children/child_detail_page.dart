import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/services/children_service.dart';
import '../../core/services/events_service.dart';
import '../../core/services/documents_service.dart';
import '../../core/widgets/child_avatar.dart';
import '../../core/widgets/manounou_card.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/manounou_button.dart';
import '../../core/theme/famplan_colors.dart';
import '../../core/utils/date_helper.dart';

class ChildDetailPage extends StatefulWidget {
  final String childId;

  const ChildDetailPage({super.key, required this.childId});

  @override
  State<ChildDetailPage> createState() => _ChildDetailPageState();
}

class _ChildDetailPageState extends State<ChildDetailPage> {
  bool _isLoading = true;
  Child? _child;
  String? _errorMessage;
  int _eventsCount = 0;
  int _documentsCount = 0;

  /// Calcule l'âge à partir de la date de naissance
  int _calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  @override
  void initState() {
    super.initState();
    // Délayer le chargement après la construction initiale pour éviter setState() during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadChild();
      }
    });
  }

  Future<void> _loadChild() async {
    if (!mounted) return;
    
    debugPrint('🔄 Chargement enfant: ${widget.childId}');
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final childrenService = context.read<ChildrenService>();
      final eventsService = context.read<EventsService>();
      final documentsService = context.read<DocumentsService>();
      
      debugPrint('📦 Services récupérés, chargement des données...');
      
      // Charger toutes les données en parallèle
      // Note: loadEvents() et loadDocuments() peuvent notifier les listeners,
      // mais c'est OK car on est après la construction initiale
      final results = await Future.wait([
        childrenService.getChildById(widget.childId),
        eventsService.loadEvents(),
        documentsService.loadDocuments(),
      ]);
      
      final child = results[0] as Child?;
      
      debugPrint('✅ Données chargées - Enfant: ${child != null ? child.firstName : "null"}');
      
      // Vérifier que l'enfant existe
      if (child == null) {
        debugPrint('❌ Enfant non trouvé avec l\'ID: ${widget.childId}');
        if (mounted) {
          setState(() {
            _errorMessage = 'Enfant non trouvé (ID: ${widget.childId})';
            _isLoading = false;
          });
        }
        return;
      }
      
      // Compter les événements et documents pour cet enfant
      final events = eventsService.events.where((e) => e.childId == widget.childId).toList();
      final documents = documentsService.documents.where((d) => d.childId == widget.childId).toList();
      
      debugPrint('📊 Statistiques - Événements: ${events.length}, Documents: ${documents.length}');
      
      if (mounted) {
        setState(() {
          _child = child;
          _eventsCount = events.length;
          _documentsCount = documents.length;
          _isLoading = false;
          _errorMessage = null;
        });
        debugPrint('✅ Page mise à jour avec succès');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Erreur lors du chargement: $e');
      debugPrint('Stack trace: $stackTrace');
      if (mounted) {
        setState(() {
          _errorMessage = 'Erreur lors du chargement: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer l\'enfant'),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer ${_child?.firstName} ? Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        final childrenService = context.read<ChildrenService>();
        await childrenService.deleteChild(widget.childId);
        
        if (mounted) {
          context.go('/children');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur lors de la suppression: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (Navigator.canPop(context)) {
                context.pop();
              } else {
                context.go('/children');
              }
            },
            tooltip: 'Retour',
          ),
          title: const Text('Détails enfant'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null || _child == null) {
      debugPrint('⚠️ Affichage écran d\'erreur - Message: $_errorMessage, Enfant: $_child');
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (Navigator.canPop(context)) {
                context.pop();
              } else {
                context.go('/children');
              }
            },
            tooltip: 'Retour',
          ),
          title: const Text('Détails enfant'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  _errorMessage ?? 'Enfant non trouvé',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                if (widget.childId.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'ID: ${widget.childId}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => context.go('/children'),
                  child: const Text('Retour à la liste'),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _loadChild,
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.canPop(context)) {
              context.pop();
            } else {
              context.go('/children');
            }
          },
          tooltip: 'Retour',
        ),
        title: Text(_child!.firstName),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              // Attendre le retour de la page d'édition pour recharger
              await context.push('/children/${widget.childId}/edit');
              // Recharger les données après retour
              if (mounted) {
                _loadChild();
              }
            },
            tooltip: 'Modifier',
          ),
        ],
      ),
      body: Builder(
        builder: (context) {
          try {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header avec avatar et infos principales
                  _buildHeaderSection(context),
                  
                  // Statistiques rapides
                  _buildStatsSection(context),
                  
                  // Sections principales
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        
                        // Informations
                        _buildInfoSection(context),
                        const SizedBox(height: 16),

                        // Planning
                        _buildPlanningSection(context),
                        const SizedBox(height: 16),

                        // Événements
                        _buildEventsSection(context),
                        const SizedBox(height: 16),

                        // Documents
                        _buildDocumentsSection(context),
                        const SizedBox(height: 24),

                        // Bouton Supprimer
                        _buildDeleteButton(context),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ],
              ),
            );
          } catch (e, stackTrace) {
            debugPrint('❌ Erreur dans body: $e');
            debugPrint('Stack trace: $stackTrace');
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Erreur d\'affichage: $e',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context) {
    if (_child == null) {
      return const SizedBox.shrink();
    }
    
    try {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              FamPlanColors.tealGreen.withValues(alpha: 0.1),
              Colors.transparent,
            ],
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
        child: Column(
          children: [
            // Avatar avec animation
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 600),
              tween: Tween(begin: 0.0, end: 1.0),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: child,
                );
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: FamPlanColors.tealGreen.withValues(alpha: 0.3),
                        width: 4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: FamPlanColors.tealGreen.withValues(alpha: 0.2),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                  ),
                  ChildAvatar(
                    firstName: _child!.firstName,
                    photoUrl: _child!.photoUrl,
                    gender: _child!.gender,
                    radius: 56,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Nom avec badge genre
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _child!.firstName,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: FamPlanColors.textDark,
                      ),
                ),
                if (_child!.gender != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _child!.gender == 'F' 
                          ? Colors.pink.withValues(alpha: 0.2)
                          : Colors.blue.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _child!.gender == 'F' ? Icons.female : Icons.male,
                      size: 16,
                      color: _child!.gender == 'F' 
                          ? Colors.pink[700]
                          : Colors.blue[700],
                    ),
                  ),
                ],
              ],
            ),
            
            // Age si disponible
            if (_child!.birthDate != null) ...[
              const SizedBox(height: 8),
              Text(
                '${_calculateAge(_child!.birthDate!)} ans',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: FamPlanColors.textLight,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ],
        ),
      );
    } catch (e) {
      debugPrint('❌ Erreur dans _buildHeaderSection: $e');
      return Container(
        padding: const EdgeInsets.all(16),
        child: Text('Erreur: $e'),
      );
    }
  }

  Widget _buildStatsSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              context,
              icon: Icons.event,
              label: 'Événements',
              value: '$_eventsCount',
              color: FamPlanColors.orange,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              context,
              icon: Icons.description,
              label: 'Documents',
              value: '$_documentsCount',
              color: FamPlanColors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return ManounouCard(
      onTap: () {
        if (label == 'Événements') {
          context.go('/events?child=${widget.childId}');
        } else {
          context.go('/documents?child=${widget.childId}');
        }
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: FamPlanColors.textLight,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    return ManounouCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: FamPlanColors.tealGreen.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.person_outline,
                      color: FamPlanColors.tealGreen,
                      size: 20,
                    ),
                  ),
              const SizedBox(width: 12),
              Text(
                'Informations',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: FamPlanColors.textDark,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildInfoRow(context, Icons.person, 'Prénom', _child!.firstName),
          if (_child!.age != null) ...[
            const SizedBox(height: 16),
            _buildInfoRow(
              context,
              Icons.cake,
              'Âge',
              '${_child!.age} ans',
            ),
          ],
          if (_child!.birthDate != null) ...[
            const SizedBox(height: 16),
            _buildInfoRow(
              context,
              Icons.calendar_today,
              'Date de naissance',
              DateHelper.formatFullDate(_child!.birthDate!),
            ),
          ],
          if (_child!.info != null && _child!.info!.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildInfoRow(
              context,
              Icons.note_outlined,
              'Notes',
              _child!.info!,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPlanningSection(BuildContext context) {
    return ManounouCard(
      onTap: () => context.go('/children/${widget.childId}/schedules/type'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: FamPlanColors.tealGreen.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.access_time,
                      color: FamPlanColors.tealGreen,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Planning',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: FamPlanColors.textDark,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Horaires de dépôt et récupération',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: FamPlanColors.textLight,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Icon(
                Icons.chevron_right,
                color: FamPlanColors.textLight,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEventsSection(BuildContext context) {
    if (_eventsCount == 0) {
      return ManounouCard(
        child: EmptyState(
          icon: Icons.event_outlined,
          title: 'Aucun événement',
          subtitle: 'Ajoutez des événements pour ${_child!.firstName}',
          actionLabel: 'Voir le calendrier',
          onAction: () => context.go('/events?child=${widget.childId}'),
          iconColor: FamPlanColors.orange,
        ),
      );
    }

    return ManounouCard(
      onTap: () => context.go('/events?child=${widget.childId}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: FamPlanColors.orange.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.event,
                      color: FamPlanColors.orange,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Événements',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: FamPlanColors.textDark,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$_eventsCount événement${_eventsCount > 1 ? 's' : ''}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: FamPlanColors.textLight,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
              const Icon(
                Icons.chevron_right,
                color: FamPlanColors.textLight,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsSection(BuildContext context) {
    if (_documentsCount == 0) {
      return ManounouCard(
        child: EmptyState(
          icon: Icons.description_outlined,
          title: 'Aucun document',
          subtitle: 'Ajoutez des documents pour ${_child!.firstName}',
          actionLabel: 'Voir les documents',
          onAction: () => context.go('/documents?child=${widget.childId}'),
          iconColor: FamPlanColors.blue,
        ),
      );
    }

    return ManounouCard(
      onTap: () => context.go('/documents?child=${widget.childId}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: FamPlanColors.blue.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.description,
                      color: FamPlanColors.blue,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Documents',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: FamPlanColors.textDark,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$_documentsCount document${_documentsCount > 1 ? 's' : ''}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: FamPlanColors.textLight,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
              const Icon(
                Icons.chevron_right,
                color: FamPlanColors.textLight,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteButton(BuildContext context) {
    return ManounouButton(
      label: 'Supprimer cet enfant',
      icon: Icons.delete_outline,
      isOutlined: true,
      foregroundColor: Colors.red,
      onPressed: _handleDelete,
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: FamPlanColors.tealGreen.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: FamPlanColors.tealGreen),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: FamPlanColors.textLight,
                      fontSize: 12,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: FamPlanColors.textDark,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}


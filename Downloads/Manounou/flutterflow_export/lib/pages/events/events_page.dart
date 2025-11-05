import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/services/events_service.dart';
import '../../core/services/children_service.dart';
import '../../core/services/schedules_service.dart';
import '../../core/theme/famplan_colors.dart';
import '../../core/widgets/famplan_card.dart';
import '../../core/widgets/unified_fab_menu.dart';
import '../../core/widgets/child_avatar.dart';
import '../../core/widgets/schedule_card.dart';
import '../../core/widgets/day_details_bottom_sheet.dart';
import '../../core/utils/date_helper.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  DateTime _selectedDate = DateTime.now();
  String _viewMode = 'day'; // 'day', 'week', 'month'
  String? _selectedChildId; // null = tous les enfants
  bool _showSchedules = true; // Afficher les plannings
  bool _showEvents = true; // Afficher les événements
  
  // Cache pour éviter les rechargements inutiles
  bool _dataLoaded = false;
  DateTime? _lastDataLoadDate;
  String? _lastViewMode;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData(force: true);
    });
  }

  /// Charger les données (uniquement si nécessaire)
  Future<void> _loadData({bool force = false}) async {
    // Si les données sont déjà chargées et qu'on ne force pas, ne rien faire
    if (!force && _dataLoaded && _lastDataLoadDate != null) {
      final now = DateTime.now();
      // Si les données sont récentes (moins de 5 minutes), ne pas recharger
      if (now.difference(_lastDataLoadDate!).inMinutes < 5) {
        return;
      }
    }
    
    final eventsService = context.read<EventsService>();
    final childrenService = context.read<ChildrenService>();
    final schedulesService = context.read<SchedulesService>();
    
    // Charger les événements et enfants en parallèle
    await Future.wait([
      eventsService.loadEvents(),
      childrenService.loadChildren(),
    ]);
    
    // Charger TOUS les plannings de tous les enfants en une fois (optimisation)
    if (childrenService.children.isNotEmpty) {
      final childIds = childrenService.children.map((c) => c.id).toList();
      await schedulesService.loadAllSchedules(childIds);
    }
    
    _dataLoaded = true;
    _lastDataLoadDate = DateTime.now();
    
    if (mounted) {
      setState(() {});
    }
  }

  /// Recharger les événements (force le rechargement)
  Future<void> _reloadEvents() async {
    await _loadData(force: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FamPlanColors.backgroundWhite,
      appBar: AppBar(
        title: const Text(
          'Calendrier',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: FamPlanColors.textDark,
          ),
        ),
        elevation: 0,
        backgroundColor: FamPlanColors.backgroundWhite,
        actions: [
          // Toggle affichage événements
          IconButton(
            icon: Icon(
              _showEvents ? Icons.event : Icons.event_outlined,
              color: _showEvents 
                  ? FamPlanColors.orange 
                  : FamPlanColors.textLight,
            ),
            onPressed: () {
              setState(() {
                _showEvents = !_showEvents;
              });
            },
            tooltip: _showEvents ? 'Masquer les événements' : 'Afficher les événements',
          ),
          // Toggle affichage plannings
          IconButton(
            icon: Icon(
              _showSchedules ? Icons.schedule : Icons.schedule_outlined,
              color: _showSchedules 
                  ? FamPlanColors.tealGreen 
                  : FamPlanColors.textLight,
            ),
            onPressed: () {
              setState(() {
                _showSchedules = !_showSchedules;
              });
            },
            tooltip: _showSchedules ? 'Masquer les plannings' : 'Afficher les plannings',
          ),
        ],
      ),
      body: Column(
        children: [
          // Header avec sélecteur d'enfants et calendrier
          _buildCalendarHeader(context),
          
          // Vue selon le mode
          Expanded(
            child: _viewMode == 'day'
                ? _buildDayView(context)
                : _viewMode == 'week'
                    ? _buildWeekView(context)
                    : _buildMonthView(context),
          ),
        ],
      ),
      floatingActionButton: Builder(
        builder: (context) {
          final childrenService = context.watch<ChildrenService>();
          String? childName;
          if (_selectedChildId != null) {
            try {
              final child = childrenService.children.firstWhere(
                (c) => c.id == _selectedChildId,
              );
              childName = child.firstName;
            } catch (e) {
              childName = null;
            }
          }
          return UnifiedFabMenu(
            childId: _selectedChildId,
            childName: childName,
          );
        },
      ),
    );
  }

  Widget _buildCalendarHeader(BuildContext context) {
    final childrenService = context.watch<ChildrenService>();
    final children = childrenService.children;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FamPlanColors.darkPurple,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Sélecteur d'enfants (chips)
          if (children.isNotEmpty) ...[
            SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  // Chip "Tous"
                  _buildChildChip(
                    context: context,
                    childId: null,
                    label: 'Tous',
                    isSelected: _selectedChildId == null,
                    onTap: () async {
                      setState(() {
                        _selectedChildId = null;
                      });
                      // Ne pas vider le cache, juste utiliser les données existantes
                    },
                  ),
                  const SizedBox(width: 8),
                  // Chips enfants
                  ...children.map((child) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _buildChildChip(
                        context: context,
                        childId: child.id,
                        label: child.firstName,
                        isSelected: _selectedChildId == child.id,
                        onTap: () async {
                          setState(() {
                            _selectedChildId = child.id;
                          });
                          // Ne pas recharger, utiliser le cache (déjà chargé avec loadAllSchedules)
                        },
                        avatar: ChildAvatar(
                          firstName: child.firstName,
                          photoUrl: child.photoUrl,
                          gender: child.gender,
                          radius: 12,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          // Navigation dates
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, color: FamPlanColors.white),
                onPressed: () {
                  setState(() {
                    _selectedDate = _viewMode == 'day'
                        ? _selectedDate.subtract(const Duration(days: 1))
                        : _viewMode == 'week'
                            ? _selectedDate.subtract(const Duration(days: 7))
                            : DateTime(_selectedDate.year, _selectedDate.month - 1);
                  });
                  // Ne pas recharger, utiliser le cache
                },
              ),
              Text(
                _viewMode == 'month'
                    ? DateHelper.formatMonth(_selectedDate)
                    : DateHelper.formatFullDateWithDay(_selectedDate),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: FamPlanColors.white,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, color: FamPlanColors.white),
                onPressed: () {
                  setState(() {
                    _selectedDate = _viewMode == 'day'
                        ? _selectedDate.add(const Duration(days: 1))
                        : _viewMode == 'week'
                            ? _selectedDate.add(const Duration(days: 7))
                            : DateTime(_selectedDate.year, _selectedDate.month + 1);
                  });
                  // Ne pas recharger, utiliser le cache
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Tabs de vue
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildViewTab(context, 'Jour', 'day'),
              const SizedBox(width: 8),
              _buildViewTab(context, 'Semaine', 'week'),
              const SizedBox(width: 8),
              _buildViewTab(context, 'Mois', 'month'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChildChip({
    required BuildContext context,
    required String? childId,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    Widget? avatar,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? FamPlanColors.tealGreen 
              : FamPlanColors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected 
                ? FamPlanColors.tealGreen 
                : FamPlanColors.white.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (avatar != null) ...[
              avatar,
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected 
                    ? FamPlanColors.white 
                    : FamPlanColors.white.withValues(alpha: 0.9),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViewTab(BuildContext context, String label, String mode) {
    final isActive = _viewMode == mode;
    return GestureDetector(
      onTap: () {
        setState(() {
          _lastViewMode = _viewMode;
          _viewMode = mode;
        });
        // Ne pas recharger, utiliser le cache
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? FamPlanColors.tealGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? FamPlanColors.tealGreen : FamPlanColors.white.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
          child: Text(
            label,
            style: TextStyle(
              color: isActive ? FamPlanColors.white : FamPlanColors.white.withValues(alpha: 0.7),
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
      ),
    );
  }

  Widget _buildDayView(BuildContext context) {
    final childrenService = context.read<ChildrenService>();

    return FutureBuilder<List<dynamic>>(
      future: _loadDayData(context),
      key: ValueKey('day_${_selectedDate.year}_${_selectedDate.month}_${_selectedDate.day}_$_selectedChildId'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final events = snapshot.data?.whereType<Event>().toList() ?? [];
        final schedules = snapshot.data?.whereType<Map<String, dynamic>>().toList() ?? [];

        return RefreshIndicator(
          onRefresh: _reloadEvents,
          color: FamPlanColors.tealGreen,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Plannings du jour (Horaires récurrents)
                if (_showSchedules) ...[
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: FamPlanColors.tealGreen.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.schedule,
                          color: FamPlanColors.tealGreen,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Horaires récurrents',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: FamPlanColors.textDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (schedules.isEmpty)
                    _buildEmptyState(
                      context,
                      icon: Icons.schedule_outlined,
                      title: 'Aucun horaire configuré',
                      subtitle: _selectedChildId != null 
                          ? 'Ajoutez un horaire récurrent pour cet enfant'
                          : 'Ajoutez un horaire récurrent pour vos enfants',
                      color: FamPlanColors.tealGreen,
                    )
                  else
                    ...schedules.map((scheduleData) {
                      final scheduleItem = scheduleData['item'] as ScheduleItem;
                      final childName = scheduleData['childName'] as String;
                      final scheduleType = scheduleData['type'] as ScheduleType;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: ScheduleCard(
                          scheduleItem: scheduleItem,
                          childName: childName,
                          scheduleType: scheduleType,
                          onTap: () => context.go('/schedules'),
                        ),
                      );
                    }),
                  const SizedBox(height: 32),
                ],

                // Événements du jour
                if (_showEvents) ...[
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: FamPlanColors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.event,
                          color: FamPlanColors.orange,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Événements ponctuels',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: FamPlanColors.textDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (events.isEmpty)
                    _buildEmptyState(
                      context,
                      icon: Icons.event_outlined,
                      title: 'Aucun événement aujourd\'hui',
                      subtitle: _selectedChildId != null
                          ? 'Ajoutez un événement pour cet enfant'
                          : 'Ajoutez un événement pour vos enfants',
                      color: FamPlanColors.orange,
                    )
                  else
                    ...events.map((event) {
                      Child? child;
                      try {
                        child = childrenService.children.firstWhere(
                          (c) => c.id == event.childId,
                        );
                      } catch (e) {
                        child = childrenService.children.isNotEmpty
                            ? childrenService.children.first
                            : null;
                      }
                      
                      if (child == null) return const SizedBox.shrink();
                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildEventCard(context, event, child.firstName),
                      );
                    }),
                ],
                
                // État vide si tout est masqué
                if (!_showSchedules && !_showEvents)
                  _buildEmptyState(
                    context,
                    icon: Icons.calendar_today_outlined,
                    title: 'Aucun contenu affiché',
                    subtitle: 'Activez les filtres pour voir les horaires ou événements',
                    color: FamPlanColors.textLight,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<List<dynamic>> _loadDayData(BuildContext context) async {
    if (!mounted) return [];
    
    final eventsService = context.read<EventsService>();
    final childrenService = context.read<ChildrenService>();
    final schedulesService = context.read<SchedulesService>();

    // Utiliser les événements déjà chargés (pas de requête SQL)
    final allEvents = eventsService.events;
    final events = allEvents.where((e) {
      return e.startDate.year == _selectedDate.year &&
          e.startDate.month == _selectedDate.month &&
          e.startDate.day == _selectedDate.day;
    }).toList();
    
    // Filtrer par enfant si sélectionné
    final filteredEvents = _selectedChildId == null
        ? events
        : events.where((e) => e.childId == _selectedChildId).toList();

    // Charger les plannings si activé (utilise le cache)
    final schedules = <Map<String, dynamic>>[];
    if (_showSchedules && mounted) {
      final childrenToCheck = _selectedChildId == null
          ? childrenService.children
          : childrenService.children.where((c) => c.id == _selectedChildId).toList();
      
      // Charger les plannings en parallèle pour tous les enfants (utilise le cache)
      final scheduleFutures = childrenToCheck.map((child) {
        return schedulesService.getScheduleForDate(child.id, _selectedDate).then((scheduleItem) {
          if (scheduleItem != null && mounted) {
            // Déterminer le type de planning
            ScheduleType scheduleType = ScheduleType.regular;
            if (scheduleItem.date != null) {
              scheduleType = ScheduleType.punctual;
            } else if (scheduleItem.dayOfWeek != null) {
              scheduleType = ScheduleType.daily;
            }
            
            schedules.add({
              'item': scheduleItem,
              'childName': child.firstName,
              'type': scheduleType,
            });
          }
        }).catchError((e) {
          // Ignorer les erreurs silencieusement (pas de planning = pas grave)
          // debugPrint désactivé pour les performances
        });
      }).toList();
      
      // Attendre toutes les requêtes en parallèle
      await Future.wait(scheduleFutures);
    }

    return [...filteredEvents, ...schedules];
  }

  Future<Map<String, dynamic>> _loadWeekData(BuildContext context, DateTime weekStart) async {
    if (!mounted) return {'events': [], 'schedulesByDay': {}};
    
    final eventsService = context.read<EventsService>();
    final childrenService = context.read<ChildrenService>();
    final schedulesService = context.read<SchedulesService>();

    // Utiliser les événements déjà chargés (pas de requête SQL)
    final allEvents = eventsService.events;
    final weekEnd = weekStart.add(const Duration(days: 7));
    final events = allEvents.where((e) {
      return e.startDate.isAfter(weekStart.subtract(const Duration(days: 1))) &&
          e.startDate.isBefore(weekEnd);
    }).toList();
    
    // Filtrer par enfant si sélectionné
    final filteredEvents = _selectedChildId == null
        ? events
        : events.where((e) => e.childId == _selectedChildId).toList();

    // Charger les plannings pour chaque jour de la semaine
    final schedulesByDay = <DateTime, List<Map<String, dynamic>>>{};
    if (_showSchedules && mounted) {
      final weekDays = List.generate(7, (i) => weekStart.add(Duration(days: i)));
      final childrenToCheck = _selectedChildId == null
          ? childrenService.children
          : childrenService.children.where((c) => c.id == _selectedChildId).toList();
      
      // Charger les plannings en parallèle pour tous les jours et enfants
      final scheduleFutures = <Future<void>>[];
      for (final day in weekDays) {
        if (!mounted) break;
        final dayKey = DateTime(day.year, day.month, day.day);
        
        for (final child in childrenToCheck) {
          if (!mounted) break;
          scheduleFutures.add(
            schedulesService.getScheduleForDate(child.id, day).then((scheduleItem) {
              if (scheduleItem != null && mounted) {
                // Déterminer le type de planning
                ScheduleType scheduleType = ScheduleType.regular;
                if (scheduleItem.date != null) {
                  scheduleType = ScheduleType.punctual;
                } else if (scheduleItem.dayOfWeek != null) {
                  scheduleType = ScheduleType.daily;
                }
                
                schedulesByDay.putIfAbsent(dayKey, () => []).add({
                  'item': scheduleItem,
                  'childName': child.firstName,
                  'type': scheduleType,
                });
              }
            }).catchError((e) {
              // Ignorer les erreurs silencieusement (debugPrint désactivé pour les performances)
            }),
          );
        }
      }
      
      // Attendre toutes les requêtes en parallèle
      await Future.wait(scheduleFutures);
    }

    return {
      'events': filteredEvents,
      'schedulesByDay': schedulesByDay,
    };
  }

  Future<Map<String, dynamic>> _loadDaysData(BuildContext context, List<DateTime> days) async {
    if (!mounted) return {'events': [], 'schedulesByDay': {}};
    
    final eventsService = context.read<EventsService>();
    final childrenService = context.read<ChildrenService>();
    final schedulesService = context.read<SchedulesService>();

    // Utiliser les événements déjà chargés (pas de requête SQL)
    final allEvents = eventsService.events;
    final filteredAllEvents = allEvents.where((e) {
      return days.any((day) {
        return e.startDate.year == day.year &&
            e.startDate.month == day.month &&
            e.startDate.day == day.day;
      });
    }).toList();
    
    // Filtrer par enfant si sélectionné
    final filteredEvents = _selectedChildId == null
        ? filteredAllEvents
        : filteredAllEvents.where((e) => e.childId == _selectedChildId).toList();

    // Charger les plannings pour chaque jour
    final schedulesByDay = <DateTime, List<Map<String, dynamic>>>{};
    if (_showSchedules && mounted) {
      final childrenToCheck = _selectedChildId == null
          ? childrenService.children
          : childrenService.children.where((c) => c.id == _selectedChildId).toList();
      
      // Charger les plannings en parallèle pour tous les jours et enfants
      final scheduleFutures = <Future<void>>[];
      for (final day in days) {
        if (!mounted) break;
        final dayKey = DateTime(day.year, day.month, day.day);
        
        for (final child in childrenToCheck) {
          if (!mounted) break;
          scheduleFutures.add(
            schedulesService.getScheduleForDate(child.id, day).then((scheduleItem) {
              if (scheduleItem != null && mounted) {
                // Déterminer le type de planning
                ScheduleType scheduleType = ScheduleType.regular;
                if (scheduleItem.date != null) {
                  scheduleType = ScheduleType.punctual;
                } else if (scheduleItem.dayOfWeek != null) {
                  scheduleType = ScheduleType.daily;
                }
                
                schedulesByDay.putIfAbsent(dayKey, () => []).add({
                  'item': scheduleItem,
                  'childName': child.firstName,
                  'type': scheduleType,
                });
              }
            }).catchError((e) {
              // Ignorer les erreurs silencieusement (debugPrint désactivé pour les performances)
            }),
          );
        }
      }
      
      // Attendre toutes les requêtes en parallèle
      await Future.wait(scheduleFutures);
    }

    return {
      'events': filteredEvents,
      'schedulesByDay': schedulesByDay,
    };
  }

  Widget _buildWeekView(BuildContext context) {
    final eventsService = context.read<EventsService>();
    final childrenService = context.read<ChildrenService>();

    // Calculer les 3 jours à afficher (jour précédent, jour sélectionné, jour suivant)
    final previousDay = _selectedDate.subtract(const Duration(days: 1));
    final nextDay = _selectedDate.add(const Duration(days: 1));
    final visibleDays = [previousDay, _selectedDate, nextDay];

    return FutureBuilder<Map<String, dynamic>>(
      future: _loadDaysData(context, visibleDays),
      key: ValueKey('week_${_selectedDate.year}_${_selectedDate.month}_${_selectedDate.day}_$_selectedChildId'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data ?? {};
        final events = data['events'] as List<Event>? ?? [];
        final schedulesByDay = data['schedulesByDay'] as Map<DateTime, List<Map<String, dynamic>>>? ?? {};
        
        final filteredEvents = _selectedChildId == null
            ? events
            : events.where((e) => e.childId == _selectedChildId).toList();

        return GestureDetector(
          onHorizontalDragEnd: (details) {
            // Swipe vers la gauche = aller vers le futur
            if (details.primaryVelocity! > 0) {
              setState(() {
                _selectedDate = _selectedDate.subtract(const Duration(days: 1));
              });
              // Ne pas recharger, utiliser le cache
            }
            // Swipe vers la droite = aller vers le passé
            else if (details.primaryVelocity! < 0) {
              setState(() {
                _selectedDate = _selectedDate.add(const Duration(days: 1));
              });
              // Ne pas recharger, utiliser le cache
            }
          },
          child: RefreshIndicator(
            onRefresh: _reloadEvents,
            color: FamPlanColors.tealGreen,
            child: Column(
              children: [
                // Navigation avec flèches
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left, color: FamPlanColors.textDark),
                        onPressed: () {
                          setState(() {
                            _selectedDate = _selectedDate.subtract(const Duration(days: 1));
                          });
                          // Ne pas recharger, utiliser le cache
                        },
                        style: IconButton.styleFrom(
                          backgroundColor: FamPlanColors.backgroundLight,
                          padding: const EdgeInsets.all(12),
                        ),
                        tooltip: 'Jour précédent',
                      ),
                      Expanded(
                        child: Text(
                          DateHelper.formatFullDateWithDay(_selectedDate),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: FamPlanColors.textDark,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right, color: FamPlanColors.textDark),
                        onPressed: () {
                          setState(() {
                            _selectedDate = _selectedDate.add(const Duration(days: 1));
                          });
                          // Ne pas recharger, utiliser le cache
                        },
                        style: IconButton.styleFrom(
                          backgroundColor: FamPlanColors.backgroundLight,
                          padding: const EdgeInsets.all(12),
                        ),
                        tooltip: 'Jour suivant',
                      ),
                    ],
                  ),
                ),
              
              // En-têtes des 3 jours
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: visibleDays.map((day) {
                    final isToday = day.year == DateTime.now().year &&
                        day.month == DateTime.now().month &&
                        day.day == DateTime.now().day;
                    
                    final isSelected = day.year == _selectedDate.year &&
                        day.month == _selectedDate.month &&
                        day.day == _selectedDate.day;

                    return Expanded(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedDate = day;
                          });
                          // Ne pas recharger, utiliser le cache
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? FamPlanColors.tealGreen
                                : isToday
                                    ? FamPlanColors.tealGreen.withValues(alpha: 0.15)
                                    : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Text(
                                DateHelper.formatDayShort(day),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? FamPlanColors.white
                                      : FamPlanColors.textDark,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${day.day}',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? FamPlanColors.white
                                      : FamPlanColors.textDark,
                                ),
                              ),
                              const SizedBox(height: 4),
                              // Indicateurs
                              Builder(
                                builder: (context) {
                                  final dayKey = DateTime(day.year, day.month, day.day);
                                  final daySchedules = schedulesByDay[dayKey] ?? [];
                                  final dayEvents = filteredEvents.where((e) {
                                    return e.startDate.year == day.year &&
                                        e.startDate.month == day.month &&
                                        e.startDate.day == day.day;
                                  }).toList();
                                  
                                  if (dayEvents.isEmpty && daySchedules.isEmpty) {
                                    return const SizedBox.shrink();
                                  }
                                  
                                  return Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (dayEvents.isNotEmpty)
                                        Container(
                                          width: 6,
                                          height: 6,
                                          margin: const EdgeInsets.only(right: 3),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? FamPlanColors.white
                                                : FamPlanColors.orange,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      if (daySchedules.isNotEmpty)
                                        Container(
                                          width: 6,
                                          height: 6,
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? FamPlanColors.white
                                                : FamPlanColors.tealGreen,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              
              // Grille avec colonnes pour les 3 jours (scrollable verticalement)
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: visibleDays.map((day) {
                      final dayKey = DateTime(day.year, day.month, day.day);
                      final daySchedules = schedulesByDay[dayKey] ?? [];
                      final dayEvents = filteredEvents.where((e) {
                        return e.startDate.year == day.year &&
                            e.startDate.month == day.month &&
                            e.startDate.day == day.day;
                      }).toList();
                      
                      final isToday = day.year == DateTime.now().year &&
                          day.month == DateTime.now().month &&
                          day.day == DateTime.now().day;
                      
                      final isSelected = day.year == _selectedDate.year &&
                          day.month == _selectedDate.month &&
                          day.day == _selectedDate.day;

                      return Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          constraints: const BoxConstraints(
                            minHeight: 200,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isSelected
                                  ? FamPlanColors.tealGreen
                                  : isToday
                                      ? FamPlanColors.tealGreen.withValues(alpha: 0.3)
                                      : Colors.grey[200]!,
                              width: isSelected ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Plannings du jour
                              if (_showSchedules && daySchedules.isNotEmpty) ...[
                                ...daySchedules.map((scheduleData) {
                                  final scheduleItem = scheduleData['item'] as ScheduleItem;
                                  final childName = scheduleData['childName'] as String;
                                  return Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: _buildWeekScheduleItem(
                                      context,
                                      day,
                                      scheduleItem,
                                      childName,
                                    ),
                                  );
                                }),
                              ],
                              
                              // Événements du jour
                              if (_showEvents && dayEvents.isNotEmpty) ...[
                                ...dayEvents.map((event) {
                                  Child? child;
                                  try {
                                    child = childrenService.children.firstWhere(
                                      (c) => c.id == event.childId,
                                    );
                                  } catch (e) {
                                    child = null;
                                  }
                                  return Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: _buildWeekEventItem(
                                      context,
                                      event,
                                      child?.firstName ?? '',
                                    ),
                                  );
                                }),
                              ],
                              
                              // État vide pour ce jour
                              if ((_showSchedules && daySchedules.isEmpty && _showEvents && dayEvents.isEmpty) ||
                                  (!_showSchedules && !_showEvents)) ...[
                                const SizedBox(height: 8),
                                Center(
                                  child: Text(
                                    'Aucun\névénement',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
          ),
        );
      },
    );
  }

  Widget _buildWeekScheduleItem(
    BuildContext context,
    DateTime date,
    ScheduleItem scheduleItem,
    String childName,
  ) {
    final hasDropOff = scheduleItem.dropOffTime != null;
    final hasPickUp = scheduleItem.pickUpTime != null;
    
    String timeText = '';
    if (hasDropOff && hasPickUp) {
      timeText = '↓ ${DateHelper.formatTimeOfDay(scheduleItem.dropOffTime!)} → ↑ ${DateHelper.formatTimeOfDay(scheduleItem.pickUpTime!)}';
    } else if (hasDropOff) {
      timeText = '↓ ${DateHelper.formatTimeOfDay(scheduleItem.dropOffTime!)}';
    } else if (hasPickUp) {
      timeText = '↑ ${DateHelper.formatTimeOfDay(scheduleItem.pickUpTime!)}';
    }

    return GestureDetector(
      onTap: () {
        DayDetailsBottomSheet.show(
          context: context,
          date: date,
          events: [],
          schedules: [{
            'item': scheduleItem,
            'childName': childName,
            'type': ScheduleType.regular,
          }],
          childrenService: context.read<ChildrenService>(),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: FamPlanColors.tealGreen.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: FamPlanColors.tealGreen.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              timeText,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: FamPlanColors.textDark,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (childName.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                childName,
                style: TextStyle(
                  fontSize: 10,
                  color: FamPlanColors.textLight,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWeekEventItem(
    BuildContext context,
    Event event,
    String childName,
  ) {
    final cardColor = event.conflict
        ? FamPlanColors.orange
        : FamPlanColors.getCardColor(event.hashCode % 7);

    return GestureDetector(
      onTap: () {
        DayDetailsBottomSheet.show(
          context: context,
          date: event.startDate,
          events: [event],
          schedules: [],
          childrenService: context.read<ChildrenService>(),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateHelper.formatTime(event.startDate),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: FamPlanColors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              event.title,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: FamPlanColors.white,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (childName.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                childName,
                style: TextStyle(
                  fontSize: 9,
                  color: FamPlanColors.white.withValues(alpha: 0.8),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMonthView(BuildContext context) {
    final eventsService = context.read<EventsService>();
    final childrenService = context.read<ChildrenService>();

    // Calculer le premier jour du mois
    final firstDayOfMonth = DateTime(_selectedDate.year, _selectedDate.month, 1);
    // Calculer le premier lundi de la grille (peut être le mois précédent)
    final firstMonday = firstDayOfMonth.subtract(
      Duration(days: firstDayOfMonth.weekday - 1),
    );
    // Calculer le nombre de jours dans le mois
    final daysInMonth = DateTime(_selectedDate.year, _selectedDate.month + 1, 0).day;
    // Calculer le dernier jour du mois
    final lastDayOfMonth = DateTime(_selectedDate.year, _selectedDate.month, daysInMonth);
    // Calculer le dernier dimanche de la grille (peut être le mois suivant)
    final lastSunday = lastDayOfMonth.add(
      Duration(days: 7 - lastDayOfMonth.weekday),
    );
    // Calculer le nombre de semaines à afficher
    final weeksToShow = lastSunday.difference(firstMonday).inDays ~/ 7;

    // Générer tous les jours de la grille
    final allDays = List.generate(
      weeksToShow * 7,
      (i) => firstMonday.add(Duration(days: i)),
    );

    return FutureBuilder<Map<String, dynamic>>(
      future: _loadMonthData(context),
      key: ValueKey('month_${_selectedDate.year}_${_selectedDate.month}_$_selectedChildId'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data ?? {};
        final monthEvents = data['events'] as List<Event>? ?? [];
        final schedulesByDay = data['schedulesByDay'] as Map<DateTime, List<Map<String, dynamic>>>? ?? {};
        
        final filteredMonthEvents = _selectedChildId == null
            ? monthEvents
            : monthEvents.where((e) => e.childId == _selectedChildId).toList();

    return RefreshIndicator(
      onRefresh: _reloadEvents,
      color: FamPlanColors.tealGreen,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-têtes des jours de la semaine
            Row(
              children: ['L', 'M', 'M', 'J', 'V', 'S', 'D'].map((day) {
                return Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        day,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: FamPlanColors.textLight,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            
            // Grille du calendrier
            ...List.generate(weeksToShow, (weekIndex) {
              final weekDays = allDays.sublist(weekIndex * 7, (weekIndex + 1) * 7);
              
              return Row(
                children: weekDays.map((day) {
                  final isCurrentMonth = day.month == _selectedDate.month;
                  final isToday = day.year == DateTime.now().year &&
                      day.month == DateTime.now().month &&
                      day.day == DateTime.now().day;
                  final isSelected = day.year == _selectedDate.year &&
                      day.month == _selectedDate.month &&
                      day.day == _selectedDate.day;
                  
                  // Trouver les événements de ce jour
                  final dayEvents = filteredMonthEvents.where((e) {
                    return e.startDate.year == day.year &&
                        e.startDate.month == day.month &&
                        e.startDate.day == day.day;
                  }).toList();
                  
                  // Normaliser la date pour la clé (sans heures)
                  final dayKey = DateTime(day.year, day.month, day.day);
                  final daySchedules = schedulesByDay[dayKey] ?? [];
                  
                  // Déterminer la couleur de fond selon le contenu
                  Color? backgroundColor;
                  if (isSelected) {
                    backgroundColor = FamPlanColors.tealGreen;
                  } else if (isToday) {
                    backgroundColor = FamPlanColors.tealGreen.withValues(alpha: 0.15);
                  } else if (daySchedules.isNotEmpty && dayEvents.isNotEmpty) {
                    // Les deux : mélange de couleurs
                    backgroundColor = FamPlanColors.tealGreen.withValues(alpha: 0.08);
                  } else if (daySchedules.isNotEmpty) {
                    // Seulement plannings : vert clair
                    backgroundColor = FamPlanColors.tealGreen.withValues(alpha: 0.1);
                  } else if (dayEvents.isNotEmpty) {
                    // Seulement événements : orange clair
                    backgroundColor = FamPlanColors.orange.withValues(alpha: 0.1);
                  } else {
                    backgroundColor = Colors.transparent;
                  }
                  
                  return Expanded(
                    child: InkWell(
                      onTap: () {
                        // Ouvrir le bottom sheet avec les détails du jour
                        final dayEventsList = filteredMonthEvents.where((e) {
                          return e.startDate.year == day.year &&
                              e.startDate.month == day.month &&
                              e.startDate.day == day.day;
                        }).toList();
                        
                        DayDetailsBottomSheet.show(
                          context: context,
                          date: day,
                          events: dayEventsList,
                          schedules: daySchedules,
                          childrenService: childrenService,
                        );
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        margin: const EdgeInsets.all(2),
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                        decoration: BoxDecoration(
                          color: backgroundColor,
                          borderRadius: BorderRadius.circular(12),
                          border: isSelected
                              ? Border.all(
                                  color: FamPlanColors.tealGreen,
                                  width: 2,
                                )
                              : isToday
                                  ? Border.all(
                                      color: FamPlanColors.tealGreen.withValues(alpha: 0.3),
                                      width: 1,
                                    )
                                  : null,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${day.day}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: isToday || isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isCurrentMonth
                                    ? (isSelected
                                        ? FamPlanColors.white
                                        : isToday
                                            ? FamPlanColors.tealGreen
                                            : FamPlanColors.textDark)
                                    : FamPlanColors.textLight.withValues(alpha: 0.5),
                              ),
                            ),
                            if (dayEvents.isNotEmpty || daySchedules.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (dayEvents.isNotEmpty) ...[
                                    Container(
                                      width: 4,
                                      height: 4,
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? FamPlanColors.white
                                            : (dayEvents.any((e) => e.conflict)
                                                ? FamPlanColors.orange
                                                : FamPlanColors.blue),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    if (dayEvents.length > 1 || daySchedules.isNotEmpty)
                                      const SizedBox(width: 2),
                                    if (dayEvents.length > 1)
                                      Container(
                                        width: 4,
                                        height: 4,
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? FamPlanColors.white.withValues(alpha: 0.7)
                                              : FamPlanColors.blue.withValues(alpha: 0.7),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                  ],
                                  if (daySchedules.isNotEmpty) ...[
                                    if (dayEvents.isNotEmpty) const SizedBox(width: 2),
                                    Container(
                                      width: 4,
                                      height: 4,
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? FamPlanColors.white
                                            : FamPlanColors.tealGreen,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            }),
            
            // Légende des codes couleurs
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: FamPlanColors.backgroundLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Légende',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: FamPlanColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildLegendItem(
                        color: FamPlanColors.tealGreen.withValues(alpha: 0.1),
                        label: 'Horaires',
                        dotColor: FamPlanColors.tealGreen,
                      ),
                      const SizedBox(width: 16),
                      _buildLegendItem(
                        color: FamPlanColors.orange.withValues(alpha: 0.1),
                        label: 'Événements',
                        dotColor: FamPlanColors.orange,
                      ),
                      const SizedBox(width: 16),
                      _buildLegendItem(
                        color: FamPlanColors.tealGreen.withValues(alpha: 0.08),
                        label: 'Les deux',
                        dotColor: FamPlanColors.blue,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '💡 Appuyez sur un jour pour voir les détails',
                    style: TextStyle(
                      fontSize: 12,
                      color: FamPlanColors.textLight,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
      },
    );
  }


  Future<Map<String, dynamic>> _loadMonthData(BuildContext context) async {
    if (!mounted) return {'events': [], 'schedulesByDay': {}};
    
    final eventsService = context.read<EventsService>();
    final childrenService = context.read<ChildrenService>();
    final schedulesService = context.read<SchedulesService>();

    // Utiliser les événements déjà chargés (pas de requête SQL)
    final monthEvents = eventsService.events.where((e) {
      return e.startDate.year == _selectedDate.year &&
          e.startDate.month == _selectedDate.month;
    }).toList();
    
    // Filtrer par enfant si sélectionné
    final filteredEvents = _selectedChildId == null
        ? monthEvents
        : monthEvents.where((e) => e.childId == _selectedChildId).toList();

    // Charger les plannings pour chaque jour du mois visible (utilise le cache)
    final schedulesByDay = <DateTime, List<Map<String, dynamic>>>{};
    if (_showSchedules && mounted) {
      // Calculer les jours du mois
      final firstDayOfMonth = DateTime(_selectedDate.year, _selectedDate.month, 1);
      final lastDayOfMonth = DateTime(_selectedDate.year, _selectedDate.month + 1, 0);
      
      final childrenToCheck = _selectedChildId == null
          ? childrenService.children
          : childrenService.children.where((c) => c.id == _selectedChildId).toList();
      
      // Charger les plannings en parallèle pour tous les jours du mois et enfants
      // Utilise le cache en mémoire, donc très rapide
      final scheduleFutures = <Future<void>>[];
      for (int day = 1; day <= lastDayOfMonth.day; day++) {
        if (!mounted) break;
        final date = DateTime(_selectedDate.year, _selectedDate.month, day);
        final dayKey = DateTime(date.year, date.month, date.day);
        
        for (final child in childrenToCheck) {
          if (!mounted) break;
          scheduleFutures.add(
            schedulesService.getScheduleForDate(child.id, date).then((scheduleItem) {
              if (scheduleItem != null && mounted) {
                // Déterminer le type de planning
                ScheduleType scheduleType = ScheduleType.regular;
                if (scheduleItem.date != null) {
                  scheduleType = ScheduleType.punctual;
                } else if (scheduleItem.dayOfWeek != null) {
                  scheduleType = ScheduleType.daily;
                }
                
                schedulesByDay.putIfAbsent(dayKey, () => []).add({
                  'item': scheduleItem,
                  'childName': child.firstName,
                  'type': scheduleType,
                });
              }
            }).catchError((e) {
              // Ignorer les erreurs silencieusement (debugPrint désactivé pour les performances)
            }),
          );
        }
      }
      
      // Attendre toutes les requêtes en parallèle (rapide car utilise le cache)
      await Future.wait(scheduleFutures);
    }

    return {
      'events': filteredEvents,
      'schedulesByDay': schedulesByDay,
    };
  }

  Widget _buildEmptyState(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 64,
                color: color,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: FamPlanColors.textDark,
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: FamPlanColors.textLight,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventCard(BuildContext context, Event event, String childName) {
    final cardColor = event.conflict
        ? FamPlanColors.orange
        : FamPlanColors.getCardColor(event.hashCode % 7);

    return FamPlanCard(
      backgroundColor: cardColor,
      onTap: () => context.go('/events/${event.id}'),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Icône
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: FamPlanColors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getEventIcon(event.title),
              color: FamPlanColors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          // Informations
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        event.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: FamPlanColors.white,
                        ),
                      ),
                    ),
                    if (event.conflict)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: FamPlanColors.white.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Conflit',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: FamPlanColors.white,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${childName} • ${DateHelper.formatTime(event.startDate)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: FamPlanColors.white.withValues(alpha: 0.9),
                  ),
                ),
                if (event.endDate != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Jusqu\'à ${DateHelper.formatTime(event.endDate!)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: FamPlanColors.white.withValues(alpha: 0.8),
                  ),
                  ),
                ],
              ],
            ),
          ),
          // Indicateur de date
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: FamPlanColors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text(
                  '${event.startDate.day}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: FamPlanColors.white,
                  ),
                ),
                Text(
                  DateHelper.formatMonthShort(event.startDate),
                  style: TextStyle(
                    fontSize: 10,
                    color: FamPlanColors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getEventIcon(String title) {
    final lower = title.toLowerCase();
    if (lower.contains('anniversaire') || lower.contains('birthday')) {
      return Icons.cake;
    } else if (lower.contains('médecin') || lower.contains('docteur') || lower.contains('rdv')) {
      return Icons.local_hospital;
    } else if (lower.contains('école') || lower.contains('école')) {
      return Icons.school;
    } else if (lower.contains('sport')) {
      return Icons.sports_soccer;
    } else {
      return Icons.event;
    }
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
    required Color dotColor,
  }) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: dotColor.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Center(
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: FamPlanColors.textDark,
          ),
        ),
      ],
    );
  }
}

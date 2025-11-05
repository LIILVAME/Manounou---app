import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/famplan_colors.dart';
import '../../core/utils/date_helper.dart';
import '../../core/services/schedules_service.dart';
import '../../core/services/events_service.dart';
import '../../core/services/children_service.dart';
import '../../core/widgets/schedule_card.dart';
import '../../core/widgets/famplan_card.dart';

/// Bottom sheet pour afficher le planning et les événements d'un jour
class DayDetailsBottomSheet extends StatelessWidget {
  final DateTime date;
  final List<Event> events;
  final List<Map<String, dynamic>> schedules;
  final ChildrenService childrenService;

  const DayDetailsBottomSheet({
    super.key,
    required this.date,
    required this.events,
    required this.schedules,
    required this.childrenService,
  });

  static Future<void> show({
    required BuildContext context,
    required DateTime date,
    required List<Event> events,
    required List<Map<String, dynamic>> schedules,
    required ChildrenService childrenService,
  }) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DayDetailsBottomSheet(
        date: date,
        events: events,
        schedules: schedules,
        childrenService: childrenService,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Trier les événements par heure de début
    final sortedEvents = List<Event>.from(events)
      ..sort((a, b) => a.startDate.compareTo(b.startDate));

    return Container(
      decoration: const BoxDecoration(
        color: FamPlanColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateHelper.formatFullDateWithDay(date),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: FamPlanColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${sortedEvents.length} événement${sortedEvents.length > 1 ? 's' : ''} • ${schedules.length} horaire${schedules.length > 1 ? 's' : ''}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: FamPlanColors.textLight,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: FamPlanColors.textLight),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              
              const Divider(height: 1),
              
              // Contenu scrollable
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Plannings (Horaires récurrents)
                    if (schedules.isNotEmpty) ...[
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
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Horaires récurrents',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: FamPlanColors.textDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
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
                            onTap: () {
                              Navigator.pop(context);
                              context.go('/schedules');
                            },
                          ),
                        );
                      }),
                      const SizedBox(height: 24),
                    ],
                    
                    // Événements ponctuels
                    if (sortedEvents.isNotEmpty) ...[
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
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Événements ponctuels',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: FamPlanColors.textDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...sortedEvents.map((event) {
                        Child? child;
                        try {
                          child = childrenService.children.firstWhere(
                            (c) => c.id == event.childId,
                          );
                        } catch (e) {
                          child = null;
                        }
                        
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildEventItem(context, event, child?.firstName ?? ''),
                        );
                      }),
                      const SizedBox(height: 24),
                    ],
                    
                    // État vide
                    if (schedules.isEmpty && sortedEvents.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(40),
                          child: Column(
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                size: 64,
                                color: Colors.grey[300],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Aucun événement ou horaire',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Appuyez sur le bouton + pour ajouter',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[400],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    
                    // Bouton Ajouter
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 20),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          context.go('/events/new');
                        },
                        icon: const Icon(Icons.add, color: FamPlanColors.white),
                        label: const Text(
                          'Ajouter un événement',
                          style: TextStyle(
                            color: FamPlanColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: FamPlanColors.tealGreen,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEventItem(BuildContext context, Event event, String childName) {
    final cardColor = event.conflict
        ? FamPlanColors.orange
        : FamPlanColors.getCardColor(event.hashCode % 7);

    return FamPlanCard(
      backgroundColor: cardColor,
      onTap: () {
        Navigator.pop(context);
        context.go('/events/${event.id}');
      },
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Icône
          Container(
            width: 48,
            height: 48,
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
                Text(
                  event.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: FamPlanColors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: FamPlanColors.white.withValues(alpha: 0.9),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      DateHelper.formatTime(event.startDate),
                      style: TextStyle(
                        fontSize: 14,
                        color: FamPlanColors.white.withValues(alpha: 0.9),
                      ),
                    ),
                    if (event.endDate != null) ...[
                      Text(
                        ' - ${DateHelper.formatTime(event.endDate!)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: FamPlanColors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ],
                ),
                if (childName.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 14,
                        color: FamPlanColors.white.withValues(alpha: 0.8),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        childName,
                        style: TextStyle(
                          fontSize: 12,
                          color: FamPlanColors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ],
                if (event.conflict) ...[
                  const SizedBox(height: 6),
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
              ],
            ),
          ),
          // Flèche
          Icon(
            Icons.chevron_right,
            color: FamPlanColors.white.withValues(alpha: 0.7),
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
}


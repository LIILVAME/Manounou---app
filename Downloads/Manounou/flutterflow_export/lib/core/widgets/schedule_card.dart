import 'package:flutter/material.dart';
import '../theme/famplan_colors.dart';
import '../services/schedules_service.dart';
import 'famplan_card.dart';

/// Carte pour afficher un planning dans le calendrier
class ScheduleCard extends StatelessWidget {
  final ScheduleItem scheduleItem;
  final String childName;
  final ScheduleType scheduleType;
  final VoidCallback? onTap;

  const ScheduleCard({
    super.key,
    required this.scheduleItem,
    required this.childName,
    required this.scheduleType,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = _getColorForScheduleType(scheduleType);

    return FamPlanCard(
      backgroundColor: cardColor,
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Icône de planning
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: FamPlanColors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getIconForScheduleType(scheduleType),
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
                        _getScheduleTypeLabel(scheduleType),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: FamPlanColors.white,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: FamPlanColors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        childName,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: FamPlanColors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (scheduleItem.dropOffTime != null || scheduleItem.pickUpTime != null)
                  Row(
                    children: [
                      if (scheduleItem.dropOffTime != null) ...[
                        Icon(
                          Icons.arrow_downward,
                          size: 16,
                          color: FamPlanColors.white.withValues(alpha: 0.9),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatTime(scheduleItem.dropOffTime!),
                          style: TextStyle(
                            fontSize: 14,
                            color: FamPlanColors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                      if (scheduleItem.dropOffTime != null && scheduleItem.pickUpTime != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            '→',
                            style: TextStyle(
                              fontSize: 14,
                              color: FamPlanColors.white.withValues(alpha: 0.7),
                            ),
                          ),
                        ),
                      if (scheduleItem.pickUpTime != null) ...[
                        Icon(
                          Icons.arrow_upward,
                          size: 16,
                          color: FamPlanColors.white.withValues(alpha: 0.9),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatTime(scheduleItem.pickUpTime!),
                          style: TextStyle(
                            fontSize: 14,
                            color: FamPlanColors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ],
                  )
                else
                  Text(
                    'Aucun horaire défini',
                    style: TextStyle(
                      fontSize: 14,
                      color: FamPlanColors.white.withValues(alpha: 0.7),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                if (scheduleItem.notes != null && scheduleItem.notes!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    scheduleItem.notes!,
                    style: TextStyle(
                      fontSize: 12,
                      color: FamPlanColors.white.withValues(alpha: 0.8),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorForScheduleType(ScheduleType type) {
    switch (type) {
      case ScheduleType.punctual:
        return FamPlanColors.orange;
      case ScheduleType.daily:
        return FamPlanColors.blue;
      case ScheduleType.regular:
        return FamPlanColors.tealGreen;
    }
  }

  IconData _getIconForScheduleType(ScheduleType type) {
    switch (type) {
      case ScheduleType.punctual:
        return Icons.calendar_today;
      case ScheduleType.daily:
        return Icons.view_week;
      case ScheduleType.regular:
        return Icons.repeat;
    }
  }

  String _getScheduleTypeLabel(ScheduleType type) {
    switch (type) {
      case ScheduleType.punctual:
        return 'Horaire ponctuel';
      case ScheduleType.daily:
        return 'Horaire variable';
      case ScheduleType.regular:
        return 'Horaire régulier';
    }
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}


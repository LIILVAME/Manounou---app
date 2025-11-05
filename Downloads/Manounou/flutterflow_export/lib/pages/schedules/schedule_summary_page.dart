import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme/famplan_colors.dart';
import '../../core/services/schedules_service.dart';
import '../../core/widgets/famplan_card.dart';
import '../../core/utils/date_helper.dart';

class ScheduleSummaryPage extends StatelessWidget {
  final String childId;
  final String scheduleId;

  const ScheduleSummaryPage({
    super.key,
    required this.childId,
    required this.scheduleId,
  });

  @override
  Widget build(BuildContext context) {
    final schedulesService = context.watch<SchedulesService>();
    
    Schedule? schedule;
    try {
      schedule = schedulesService.schedules.firstWhere(
        (s) => s.id == scheduleId,
      );
    } catch (e) {
      if (schedulesService.schedules.isNotEmpty) {
        schedule = schedulesService.schedules.first;
      }
    }
    
    if (schedule == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Horaires')),
        body: const Center(child: Text('Planning non trouvé')),
      );
    }

    return Scaffold(
      backgroundColor: FamPlanColors.backgroundWhite,
      appBar: AppBar(
        title: const Text(
          'Horaires',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: FamPlanColors.textDark,
          ),
        ),
        backgroundColor: FamPlanColors.backgroundWhite,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: FamPlanColors.textDark),
            onPressed: () => context.go('/children/$childId/schedules/input?scheduleId=$scheduleId'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titre
            const Text(
              'Résumé des horaires',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: FamPlanColors.textDark,
              ),
            ),
            const SizedBox(height: 24),

            // Vue hebdomadaire
            if (schedule.type == ScheduleType.regular || schedule.type == ScheduleType.daily)
              ..._buildWeeklyView(schedule)
            else
              _buildPunctualView(schedule),

            const SizedBox(height: 24),

            // Bouton Enregistrer
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Horaires enregistrés ✅'),
                      backgroundColor: FamPlanColors.tealGreen,
                    ),
                  );
                  context.go('/children/$childId');
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Enregistrer'),
              ),
            ),
            const SizedBox(height: 8),

            // Bouton Modifier
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => context.go('/children/$childId/schedules/input?scheduleId=$scheduleId'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Modifier'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildWeeklyView(Schedule schedule) {
    final dayNames = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi'];
    final itemsByDay = <int, ScheduleItem>{};

    for (var item in schedule.items) {
      if (item.dayOfWeek != null) {
        itemsByDay[item.dayOfWeek!] = item;
      }
    }

    return List.generate(5, (index) {
      final day = index + 1;
      final item = itemsByDay[day];
      final cardColor = FamPlanColors.getCardColor(index);

      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: FamPlanCard(
          backgroundColor: cardColor,
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                dayNames[index],
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: FamPlanColors.white,
                ),
              ),
              if (item != null)
                Text(
                  _formatScheduleTime(item.dropOffTime, item.pickUpTime),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: FamPlanColors.white,
                  ),
                )
              else
                Text(
                  'Aucun horaire',
                  style: TextStyle(
                    fontSize: 14,
                    color: FamPlanColors.white.withOpacity(0.7),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildPunctualView(Schedule schedule) {
    final item = schedule.items.isNotEmpty ? schedule.items.first : null;
    final cardColor = FamPlanColors.orange;

    if (item == null || item.date == null) {
      return const Text('Aucun horaire configuré');
    }

    return FamPlanCard(
      backgroundColor: cardColor,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DateHelper.formatFullDateWithDay(item.date!),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: FamPlanColors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _formatScheduleTime(item.dropOffTime, item.pickUpTime),
            style: const TextStyle(
              fontSize: 18,
              color: FamPlanColors.white,
            ),
          ),
        ],
      ),
    );
  }

  String _formatScheduleTime(TimeOfDay? dropOff, TimeOfDay? pickUp) {
    if (dropOff == null && pickUp == null) {
      return 'Aucun horaire';
    } else if (dropOff != null && pickUp != null) {
      return '${_formatTime(dropOff)} - ${_formatTime(pickUp)}';
    } else if (dropOff != null) {
      return 'Dépôt : ${_formatTime(dropOff)}';
    } else {
      return 'Récup : ${_formatTime(pickUp!)}';
    }
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}


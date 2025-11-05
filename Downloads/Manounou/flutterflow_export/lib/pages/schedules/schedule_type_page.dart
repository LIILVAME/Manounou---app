import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/famplan_colors.dart';
import '../../core/widgets/famplan_card.dart';
import '../../core/services/schedules_service.dart';

class ScheduleTypePage extends StatelessWidget {
  final String childId;
  final String childName;

  const ScheduleTypePage({
    super.key,
    required this.childId,
    required this.childName,
  });

  @override
  Widget build(BuildContext context) {
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titre
            Text(
              'Quel type d\'horaire pour $childName ?',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: FamPlanColors.textDark,
              ),
            ),
            const SizedBox(height: 24),

            // Carte Régulier
            FamPlanCard(
              backgroundColor: FamPlanColors.tealGreen,
              onTap: () => context.go('/children/$childId/schedules/input?type=regular'),
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 40,
                    color: FamPlanColors.white,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Régulier',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: FamPlanColors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Horaires identiques chaque semaine',
                          style: TextStyle(
                            fontSize: 14,
                            color: FamPlanColors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: FamPlanColors.white,
                    size: 28,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Carte Par jour
            FamPlanCard(
              backgroundColor: FamPlanColors.blue,
              onTap: () => context.go('/children/$childId/schedules/input?type=daily'),
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const Icon(
                    Icons.view_week,
                    size: 40,
                    color: FamPlanColors.white,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Par jour',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: FamPlanColors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Horaires différents selon les jours',
                          style: TextStyle(
                            fontSize: 14,
                            color: FamPlanColors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: FamPlanColors.white,
                    size: 28,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Carte Ponctuel
            FamPlanCard(
              backgroundColor: FamPlanColors.orange,
              onTap: () => context.go('/children/$childId/schedules/input?type=punctual'),
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const Icon(
                    Icons.event,
                    size: 40,
                    color: FamPlanColors.white,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Ponctuel',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: FamPlanColors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Exception ou date spécifique',
                          style: TextStyle(
                            fontSize: 14,
                            color: FamPlanColors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: FamPlanColors.white,
                    size: 28,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


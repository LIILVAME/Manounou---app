import 'package:flutter/material.dart';
import '../theme/famplan_colors.dart';
import 'manounou_time_picker.dart';

class DayScheduleCard extends StatelessWidget {
  final String dayName;
  final TimeOfDay? dropOffTime;
  final TimeOfDay? pickUpTime;
  final bool hasException;
  final bool hasConflict;
  final Function(TimeOfDay?) onDropOffChanged;
  final Function(TimeOfDay?) onPickUpChanged;
  final VoidCallback? onAddException;

  const DayScheduleCard({
    super.key,
    required this.dayName,
    this.dropOffTime,
    this.pickUpTime,
    this.hasException = false,
    this.hasConflict = false,
    required this.onDropOffChanged,
    required this.onPickUpChanged,
    this.onAddException,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: hasConflict
              ? FamPlanColors.orange
              : Colors.grey[200]!,
          width: hasConflict ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header jour
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dayName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: FamPlanColors.textDark,
                  ),
                ),
                if (hasException)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: FamPlanColors.blue.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Exception',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: FamPlanColors.blue,
                      ),
                    ),
                  ),
                if (hasConflict)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: FamPlanColors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Conflit',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: FamPlanColors.orange,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Boutons Dépôt / Récup
            Row(
              children: [
                Expanded(
                  child: _buildTimeButton(
                    context,
                    label: 'Dépot',
                    time: dropOffTime,
                    color: FamPlanColors.tealGreen,
                    onTap: () async {
                      final time = await showManounouTimePicker(
                        context: context,
                        label: 'Heure de dépôt',
                        initialTime: dropOffTime,
                        color: FamPlanColors.tealGreen,
                      );
                      if (time != null) {
                        onDropOffChanged(time);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTimeButton(
                    context,
                    label: 'Récup',
                    time: pickUpTime,
                    color: FamPlanColors.orange,
                    onTap: () async {
                      final time = await showManounouTimePicker(
                        context: context,
                        label: 'Heure de récupération',
                        initialTime: pickUpTime,
                        color: FamPlanColors.orange,
                      );
                      if (time != null) {
                        onPickUpChanged(time);
                      }
                    },
                  ),
                ),
              ],
            ),

            // Bouton exception
            if (onAddException != null) ...[
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: onAddException,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Ajouter exception'),
                style: TextButton.styleFrom(
                  foregroundColor: FamPlanColors.textLight,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTimeButton(
    BuildContext context, {
    required String label,
    required TimeOfDay? time,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: time != null ? color.withOpacity(0.1) : Colors.transparent,
          border: Border.all(
            color: time != null ? color : Colors.grey[300]!,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: time != null ? color : FamPlanColors.textLight,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time != null
                  ? '${time!.hour.toString().padLeft(2, '0')}:${time!.minute.toString().padLeft(2, '0')}'
                  : '--:--',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: time != null ? color : FamPlanColors.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/famplan_colors.dart';

/// Time Picker mobile avec design doux (iOS style)
class ManounouTimePicker extends StatefulWidget {
  final TimeOfDay? initialTime;
  final String label;
  final Color? color;
  final Function(TimeOfDay) onTimeSelected;

  const ManounouTimePicker({
    super.key,
    this.initialTime,
    required this.label,
    this.color,
    required this.onTimeSelected,
  });

  @override
  State<ManounouTimePicker> createState() => _ManounouTimePickerState();
}

class _ManounouTimePickerState extends State<ManounouTimePicker>
    with SingleTickerProviderStateMixin {
  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  int _selectedHour = 8;
  int _selectedMinute = 0;

  @override
  void initState() {
    super.initState();
    _selectedHour = widget.initialTime?.hour ?? 8;
    _selectedMinute = widget.initialTime?.minute ?? 0;

    _hourController = FixedExtentScrollController(initialItem: _selectedHour);
    _minuteController = FixedExtentScrollController(initialItem: _selectedMinute ~/ 5);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _slideAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _handleTimeChange() {
    HapticFeedback.selectionClick();
    widget.onTimeSelected(TimeOfDay(
      hour: _selectedHour,
      minute: _selectedMinute,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? FamPlanColors.tealGreen;

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(_slideAnimation),
      child: Container(
        decoration: BoxDecoration(
          color: FamPlanColors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey[200]!,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.label,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: FamPlanColors.textDark,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.check, color: FamPlanColors.tealGreen),
                    onPressed: () {
                      _handleTimeChange();
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),

            // Time picker wheels
            Container(
              height: 200,
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Hours
                  SizedBox(
                    width: 80,
                    child: ListWheelScrollView.useDelegate(
                      controller: _hourController,
                      itemExtent: 50,
                      physics: const FixedExtentScrollPhysics(),
                      onSelectedItemChanged: (index) {
                        setState(() {
                          _selectedHour = index;
                        });
                        _handleTimeChange();
                      },
                      childDelegate: ListWheelChildBuilderDelegate(
                        builder: (context, index) {
                          final hour = index;
                          final isSelected = hour == _selectedHour;
                          return Center(
                            child: Text(
                              hour.toString().padLeft(2, '0'),
                              style: TextStyle(
                                fontSize: isSelected ? 28 : 20,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected ? color : FamPlanColors.textLight,
                              ),
                            ),
                          );
                        },
                        childCount: 24,
                      ),
                    ),
                  ),
                  const Text(
                    ':',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: FamPlanColors.textDark,
                    ),
                  ),
                  // Minutes (par pas de 5)
                  SizedBox(
                    width: 80,
                    child: ListWheelScrollView.useDelegate(
                      controller: _minuteController,
                      itemExtent: 50,
                      physics: const FixedExtentScrollPhysics(),
                      onSelectedItemChanged: (index) {
                        setState(() {
                          _selectedMinute = index * 5;
                        });
                        _handleTimeChange();
                      },
                      childDelegate: ListWheelChildBuilderDelegate(
                        builder: (context, index) {
                          final minute = index * 5;
                          final isSelected = minute == _selectedMinute;
                          return Center(
                            child: Text(
                              minute.toString().padLeft(2, '0'),
                              style: TextStyle(
                                fontSize: isSelected ? 28 : 20,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected ? color : FamPlanColors.textLight,
                              ),
                            ),
                          );
                        },
                        childCount: 12, // 0, 5, 10, ..., 55
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Selection indicator
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              height: 50,
              decoration: BoxDecoration(
                border: Border.all(
                  color: color.withOpacity(0.3),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Fonction helper pour afficher le TimePicker
Future<TimeOfDay?> showManounouTimePicker({
  required BuildContext context,
  required String label,
  TimeOfDay? initialTime,
  Color? color,
}) async {
  TimeOfDay? selectedTime = initialTime;

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => ManounouTimePicker(
      initialTime: initialTime,
      label: label,
      color: color,
      onTimeSelected: (time) {
        selectedTime = time;
      },
    ),
  );

  return selectedTime;
}


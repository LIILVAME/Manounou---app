import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/famplan_colors.dart';
import '../../core/widgets/day_schedule_card.dart';
import '../../core/services/schedules_service.dart';
import '../../core/utils/date_helper.dart';

class ScheduleInputPage extends StatefulWidget {
  final String childId;
  final String? scheduleType;

  const ScheduleInputPage({
    super.key,
    required this.childId,
    this.scheduleType,
  });

  @override
  State<ScheduleInputPage> createState() => _ScheduleInputPageState();
}

class _ScheduleInputPageState extends State<ScheduleInputPage> {
  ScheduleType? _selectedType;
  bool _applyToAll = false;
  
  // Horaires par jour (Lundi = 1, Mardi = 2, etc.)
  final Map<int, TimeOfDay?> _dropOffTimes = {};
  final Map<int, TimeOfDay?> _pickUpTimes = {};
  
  // Pour ponctuel
  DateTime? _selectedDate;
  TimeOfDay? _punctualDropOff;
  TimeOfDay? _punctualPickUp;
  
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.scheduleType != null) {
      _selectedType = ScheduleType.values.firstWhere(
        (e) => e.name == widget.scheduleType,
        orElse: () => ScheduleType.regular,
      );
    }
  }

  Future<void> _handleSave() async {
    if (_selectedType == null) {
      setState(() {
        _errorMessage = 'Veuillez sélectionner un type de planning';
      });
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final schedulesService = context.read<SchedulesService>();
      final items = <ScheduleItem>[];

      if (_selectedType == ScheduleType.punctual) {
        // Ponctuel : un seul item avec date
        if (_selectedDate == null) {
          throw Exception('Veuillez sélectionner une date');
        }
        items.add(ScheduleItem(
          id: '',
          scheduleId: '',
          date: _selectedDate,
          dropOffTime: _punctualDropOff,
          pickUpTime: _punctualPickUp,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ));
      } else if (_selectedType == ScheduleType.regular) {
        // Régulier : un seul item pour tous les jours
        final dropOff = _applyToAll && _dropOffTimes.isNotEmpty
            ? _dropOffTimes.values.first
            : null;
        final pickUp = _applyToAll && _pickUpTimes.isNotEmpty
            ? _pickUpTimes.values.first
            : null;

        if (dropOff == null && pickUp == null) {
          throw Exception('Veuillez saisir au moins un horaire');
        }

        // Créer un item pour chaque jour (Lundi-Vendredi = 1-5)
        for (int day = 1; day <= 5; day++) {
          items.add(ScheduleItem(
            id: '',
            scheduleId: '',
            dayOfWeek: day,
            dropOffTime: dropOff,
            pickUpTime: pickUp,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ));
        }
      } else {
        // Par jour : un item par jour avec horaires spécifiques
        for (int day = 1; day <= 5; day++) {
          final dropOff = _dropOffTimes[day];
          final pickUp = _pickUpTimes[day];

          if (dropOff != null || pickUp != null) {
            items.add(ScheduleItem(
              id: '',
              scheduleId: '',
              dayOfWeek: day,
              dropOffTime: dropOff,
              pickUpTime: pickUp,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ));
          }
        }

        if (items.isEmpty) {
          throw Exception('Veuillez saisir au moins un horaire');
        }
      }

      // Créer le planning
      final schedule = await schedulesService.createSchedule(
        childId: widget.childId,
        type: _selectedType!,
        items: items,
      );

      if (mounted) {
        // Naviguer vers résumé
        context.go('/children/${widget.childId}/schedules/summary?scheduleId=${schedule.id}');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors de l\'enregistrement: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dayNames = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi'];

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
            // Checkbox "Appliquer à tous" (si régulier)
            if (_selectedType == ScheduleType.regular)
              CheckboxListTile(
                title: const Text('Appliquer à tous'),
                value: _applyToAll,
                onChanged: (value) {
                  setState(() {
                    _applyToAll = value ?? false;
                  });
                },
                activeColor: FamPlanColors.tealGreen,
              ),

            // Sélection date (si ponctuel)
            if (_selectedType == ScheduleType.punctual) ...[
              const SizedBox(height: 16),
              InkWell(
                onTap: () async {
                  final date = await DateHelper.showScheduleDatePicker(
                    context,
                    initialDate: _selectedDate,
                  );
                  if (date != null) {
                    setState(() {
                      _selectedDate = date;
                    });
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date *',
                    prefixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                  ),
                  child: Text(
                    _selectedDate != null
                        ? DateHelper.formatFullDateWithDay(_selectedDate!)
                        : 'Sélectionner une date',
                    style: TextStyle(
                      color: _selectedDate != null
                          ? Theme.of(context).textTheme.bodyLarge?.color
                          : Colors.grey[600],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Horaires ponctuel
              DayScheduleCard(
                dayName: _selectedDate != null
                    ? DateHelper.formatDayAndDate(_selectedDate!)
                    : 'Date sélectionnée',
                dropOffTime: _punctualDropOff,
                pickUpTime: _punctualPickUp,
                onDropOffChanged: (time) {
                  setState(() {
                    _punctualDropOff = time;
                  });
                },
                onPickUpChanged: (time) {
                  setState(() {
                    _punctualPickUp = time;
                  });
                },
              ),
            ] else ...[
              // Cartes jour (régulier ou par jour)
              ...List.generate(5, (index) {
                final day = index + 1; // Lundi = 1
                final dropOff = _applyToAll && _dropOffTimes.isNotEmpty
                    ? _dropOffTimes.values.first
                    : _dropOffTimes[day];
                final pickUp = _applyToAll && _pickUpTimes.isNotEmpty
                    ? _pickUpTimes.values.first
                    : _pickUpTimes[day];

                return DayScheduleCard(
                  dayName: dayNames[index],
                  dropOffTime: dropOff,
                  pickUpTime: pickUp,
                  onDropOffChanged: (time) {
                    setState(() {
                      if (_applyToAll) {
                        // Appliquer à tous les jours
                        for (int d = 1; d <= 5; d++) {
                          _dropOffTimes[d] = time;
                        }
                      } else {
                        _dropOffTimes[day] = time;
                      }
                    });
                  },
                  onPickUpChanged: (time) {
                    setState(() {
                      if (_applyToAll) {
                        // Appliquer à tous les jours
                        for (int d = 1; d <= 5; d++) {
                          _pickUpTimes[d] = time;
                        }
                      } else {
                        _pickUpTimes[day] = time;
                      }
                    });
                  },
                );
              }),
            ],

            const SizedBox(height: 24),

            // Message d'erreur
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),

            // Bouton Suivant
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _handleSave,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSaving
                    ? const CircularProgressIndicator()
                    : const Text('Suivant'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/services/events_service.dart';
import '../../core/services/children_service.dart';
import '../../core/theme/famplan_colors.dart';
import '../../core/utils/date_helper.dart';

class EventFormPage extends StatefulWidget {
  final String? eventId;

  const EventFormPage({super.key, this.eventId});

  @override
  State<EventFormPage> createState() => _EventFormPageState();
}

class _EventFormPageState extends State<EventFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  String? _selectedChildId;
  DateTime? _startDate;
  TimeOfDay? _startTime;
  DateTime? _endDate;
  TimeOfDay? _endTime;
  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;
  Event? _existingEvent;

  @override
  void initState() {
    super.initState();
    if (widget.eventId != null) {
      _loadEvent();
    }
  }

  Future<void> _loadEvent() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final eventsService = context.read<EventsService>();
      final event = await eventsService.getEventById(widget.eventId!);

      if (event != null && mounted) {
        setState(() {
          _existingEvent = event;
          _titleController.text = event.title;
          _selectedChildId = event.childId;
          _startDate = event.startDate;
          _startTime = TimeOfDay.fromDateTime(event.startDate);
          _endDate = event.endDate;
          _endTime = event.endDate != null
              ? TimeOfDay.fromDateTime(event.endDate!)
              : null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Erreur lors du chargement: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await DateHelper.showEventDatePicker(
      context,
      initialDate: _startDate,
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  Future<void> _selectStartTime(BuildContext context) async {
    final TimeOfDay? picked = await DateHelper.showTimePickerStandard(
      context,
      initialTime: _startTime,
    );
    if (picked != null && picked != _startTime) {
      setState(() {
        _startTime = picked;
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await DateHelper.showEventDatePicker(
      context,
      initialDate: _endDate ?? _startDate,
      minDate: _startDate,
    );
    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  Future<void> _selectEndTime(BuildContext context) async {
    final TimeOfDay? picked = await DateHelper.showTimePickerStandard(
      context,
      initialTime: _endTime,
    );
    if (picked != null && picked != _endTime) {
      setState(() {
        _endTime = picked;
      });
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedChildId == null) {
      setState(() {
        _errorMessage = 'Veuillez sélectionner un enfant';
      });
      return;
    }

    if (_startDate == null || _startTime == null) {
      setState(() {
        _errorMessage = 'Veuillez sélectionner une date et une heure de début';
      });
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final eventsService = context.read<EventsService>();

      // Combiner date et heure
      final startDateTime = DateTime(
        _startDate!.year,
        _startDate!.month,
        _startDate!.day,
        _startTime!.hour,
        _startTime!.minute,
      );

      DateTime? endDateTime;
      if (_endDate != null && _endTime != null) {
        endDateTime = DateTime(
          _endDate!.year,
          _endDate!.month,
          _endDate!.day,
          _endTime!.hour,
          _endTime!.minute,
        );
      }

      if (widget.eventId != null) {
        // Mise à jour
        await eventsService.updateEvent(
          eventId: widget.eventId!,
          title: _titleController.text.trim(),
          startDate: startDateTime,
          endDate: endDateTime,
        );
      } else {
        // Création
        await eventsService.createEvent(
          childId: _selectedChildId!,
          title: _titleController.text.trim(),
          startDate: startDateTime,
          endDate: endDateTime,
        );
      }

      if (mounted) {
        if (Navigator.canPop(context)) {
          context.pop();
        } else {
          context.go('/events');
        }
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
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.eventId != null;
    final childrenService = context.watch<ChildrenService>();

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(isEditing ? 'Modifier événement' : 'Nouvel événement'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Modifier événement' : 'Nouvel événement'),
        backgroundColor: FamPlanColors.backgroundWhite,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Titre
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Titre *',
                  prefixIcon: Icon(Icons.event),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Le titre est obligatoire';
                  }
                  return null;
                },
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 16),

              // Enfant
              DropdownButtonFormField<String>(
                value: _selectedChildId,
                decoration: const InputDecoration(
                  labelText: 'Enfant *',
                  prefixIcon: Icon(Icons.child_care),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
                items: childrenService.children.map((child) {
                  return DropdownMenuItem(
                    value: child.id,
                    child: Text(child.firstName),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedChildId = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez sélectionner un enfant';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Date de début
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectStartDate(context),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Date de début *',
                          prefixIcon: Icon(Icons.calendar_today),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                        ),
                        child: Text(
                          _startDate != null
                              ? DateHelper.formatFullDate(_startDate!)
                              : 'Sélectionner une date',
                          style: TextStyle(
                            color: _startDate != null
                                ? Theme.of(context).textTheme.bodyLarge?.color
                                : Colors.grey[600],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectStartTime(context),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Heure *',
                          prefixIcon: Icon(Icons.access_time),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                        ),
                        child: Text(
                          _startTime != null
                              ? _startTime!.format(context)
                              : 'Sélectionner une heure',
                          style: TextStyle(
                            color: _startTime != null
                                ? Theme.of(context).textTheme.bodyLarge?.color
                                : Colors.grey[600],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Date de fin (optionnelle)
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectEndDate(context),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Date de fin (optionnel)',
                          prefixIcon: Icon(Icons.calendar_today),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                        ),
                        child: Text(
                          _endDate != null
                              ? DateHelper.formatFullDate(_endDate!)
                              : 'Sélectionner une date',
                          style: TextStyle(
                            color: _endDate != null
                                ? Theme.of(context).textTheme.bodyLarge?.color
                                : Colors.grey[600],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectEndTime(context),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Heure de fin',
                          prefixIcon: Icon(Icons.access_time),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                        ),
                        child: Text(
                          _endTime != null
                              ? _endTime!.format(context)
                              : 'Sélectionner une heure',
                          style: TextStyle(
                            color: _endTime != null
                                ? Theme.of(context).textTheme.bodyLarge?.color
                                : Colors.grey[600],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
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

              // Bouton Enregistrer
              ElevatedButton(
                onPressed: _isSaving ? null : _handleSave,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSaving
                    ? const CircularProgressIndicator()
                    : Text(isEditing ? 'Enregistrer' : 'Créer'),
              ),
              const SizedBox(height: 8),

              // Bouton Annuler
              TextButton(
                onPressed: _isSaving
                    ? null
                    : () {
                        if (Navigator.canPop(context)) {
                          context.pop();
                        } else {
                          context.go('/events');
                        }
                      },
                child: const Text('Annuler'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


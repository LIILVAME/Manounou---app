import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Event {
  final String id;
  final String childId;
  final String title;
  final DateTime startDate;
  final DateTime? endDate;
  final bool conflict;
  final DateTime createdAt;
  final DateTime updatedAt;

  Event({
    required this.id,
    required this.childId,
    required this.title,
    required this.startDate,
    this.endDate,
    this.conflict = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] as String,
      childId: json['child_id'] as String,
      title: json['title'] as String,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'] as String)
          : null,
      conflict: json['conflict'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'child_id': childId,
      'title': title,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'conflict': conflict,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Vérifier si l'événement est aujourd'hui
  bool get isToday {
    final now = DateTime.now();
    return startDate.year == now.year &&
        startDate.month == now.month &&
        startDate.day == now.day;
  }

  /// Vérifier si l'événement est cette semaine
  bool get isThisWeek {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return startDate.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
        startDate.isBefore(endOfWeek.add(const Duration(days: 1)));
  }

  /// Obtenir la durée de l'événement
  Duration? get duration {
    if (endDate == null) return null;
    return endDate!.difference(startDate);
  }
}

class EventsService extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<Event> _events = [];
  bool _isLoading = false;

  List<Event> get events => _events;
  bool get isLoading => _isLoading;

  /// Charger tous les événements de l'utilisateur
  Future<void> loadEvents() async {
    _isLoading = true;
    notifyListeners();

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        _events = [];
        notifyListeners();
        return;
      }

      // Récupérer les enfants de l'utilisateur d'abord
      final childrenResponse = await _supabase
          .from('children')
          .select('id')
          .eq('parent_id', userId);

      final childrenIds = (childrenResponse as List<dynamic>)
          .map((c) => c['id'] as String)
          .toList();

      if (childrenIds.isEmpty) {
        _events = [];
        notifyListeners();
        return;
      }

      // Récupérer les événements de ces enfants
      // Faire plusieurs requêtes et les combiner (RLS filtre automatiquement)
      List<dynamic> allEvents = [];
      for (final childId in childrenIds) {
        try {
          final childEvents = await _supabase
              .from('events')
              .select('*')
              .eq('child_id', childId)
              .order('start_date', ascending: true);
          allEvents.addAll(childEvents as List<dynamic>);
        } catch (e) {
          debugPrint('Erreur chargement événements pour enfant $childId: $e');
        }
      }

      // Trier par date
      allEvents.sort((a, b) {
        final aDate = DateTime.parse(a['start_date'] as String);
        final bDate = DateTime.parse(b['start_date'] as String);
        return aDate.compareTo(bDate);
      });

      _events = allEvents
          .map((json) => Event.fromJson(json as Map<String, dynamic>))
          .toList();

      // Détecter les conflits
      _detectConflicts();
    } catch (e) {
      debugPrint('Erreur loadEvents: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Charger les événements d'un jour spécifique
  Future<List<Event>> loadEventsForDay(DateTime date) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return [];

      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      // Récupérer les enfants de l'utilisateur d'abord
      final childrenResponse = await _supabase
          .from('children')
          .select('id')
          .eq('parent_id', userId);

      final childrenIds = (childrenResponse as List<dynamic>)
          .map((c) => c['id'] as String)
          .toList();

      if (childrenIds.isEmpty) {
        return [];
      }

      // Récupérer les événements de ces enfants pour le jour
      List<dynamic> allEvents = [];
      for (final childId in childrenIds) {
        try {
          final childEvents = await _supabase
              .from('events')
              .select('*')
              .eq('child_id', childId)
              .gte('start_date', startOfDay.toIso8601String())
              .lt('start_date', endOfDay.toIso8601String())
              .order('start_date', ascending: true);
          allEvents.addAll(childEvents as List<dynamic>);
        } catch (e) {
          debugPrint('Erreur chargement événements pour enfant $childId: $e');
        }
      }

      // Trier par date
      allEvents.sort((a, b) {
        final aDate = DateTime.parse(a['start_date'] as String);
        final bDate = DateTime.parse(b['start_date'] as String);
        return aDate.compareTo(bDate);
      });

      final events = allEvents
          .map((json) => Event.fromJson(json as Map<String, dynamic>))
          .toList();

      return events;
    } catch (e) {
      debugPrint('Erreur loadEventsForDay: $e');
      return [];
    }
  }

  /// Charger les événements d'une semaine
  Future<List<Event>> loadEventsForWeek(DateTime weekStart) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return [];

      final startOfWeek = DateTime(weekStart.year, weekStart.month, weekStart.day);
      final endOfWeek = startOfWeek.add(const Duration(days: 7));

      // Récupérer les enfants de l'utilisateur d'abord
      final childrenResponse = await _supabase
          .from('children')
          .select('id')
          .eq('parent_id', userId);

      final childrenIds = (childrenResponse as List<dynamic>)
          .map((c) => c['id'] as String)
          .toList();

      if (childrenIds.isEmpty) {
        return [];
      }

      // Récupérer les événements de ces enfants pour la semaine
      List<dynamic> allEvents = [];
      for (final childId in childrenIds) {
        try {
          final childEvents = await _supabase
              .from('events')
              .select('*')
              .eq('child_id', childId)
              .gte('start_date', startOfWeek.toIso8601String())
              .lt('start_date', endOfWeek.toIso8601String())
              .order('start_date', ascending: true);
          allEvents.addAll(childEvents as List<dynamic>);
        } catch (e) {
          debugPrint('Erreur chargement événements pour enfant $childId: $e');
        }
      }

      // Trier par date
      allEvents.sort((a, b) {
        final aDate = DateTime.parse(a['start_date'] as String);
        final bDate = DateTime.parse(b['start_date'] as String);
        return aDate.compareTo(bDate);
      });

      final events = allEvents
          .map((json) => Event.fromJson(json as Map<String, dynamic>))
          .toList();

      return events;
    } catch (e) {
      debugPrint('Erreur loadEventsForWeek: $e');
      return [];
    }
  }

  /// Détecter les conflits horaires
  void _detectConflicts() {
    // Grouper les événements par enfant
    final eventsByChild = <String, List<Event>>{};
    for (var event in _events) {
      eventsByChild.putIfAbsent(event.childId, () => []).add(event);
    }

    // Pour chaque enfant, détecter les chevauchements
    for (var childEvents in eventsByChild.values) {
      childEvents.sort((a, b) => a.startDate.compareTo(b.startDate));

      for (int i = 0; i < childEvents.length; i++) {
        bool hasConflict = false;
        final event = childEvents[i];
        final eventEnd = event.endDate ?? event.startDate.add(const Duration(hours: 1));

        for (int j = i + 1; j < childEvents.length; j++) {
          final otherEvent = childEvents[j];
          if (otherEvent.startDate.isBefore(eventEnd)) {
            hasConflict = true;
            break;
          }
        }

        if (hasConflict != event.conflict) {
          // Mettre à jour le conflit si nécessaire
          _updateConflict(event.id, hasConflict);
        }
      }
    }
  }

  /// Mettre à jour le flag de conflit
  Future<void> _updateConflict(String eventId, bool hasConflict) async {
    try {
      await _supabase
          .from('events')
          .update({'conflict': hasConflict})
          .eq('id', eventId);
    } catch (e) {
      debugPrint('Erreur _updateConflict: $e');
    }
  }

  /// Créer un événement
  Future<Event> createEvent({
    required String childId,
    required String title,
    required DateTime startDate,
    DateTime? endDate,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('Utilisateur non connecté');
      }

      // Vérifier que l'enfant appartient à l'utilisateur
      final child = await _supabase
          .from('children')
          .select('id')
          .eq('id', childId)
          .eq('parent_id', userId)
          .single();

      if (child == null) {
        throw Exception('Enfant non trouvé');
      }

      // Vérifier les conflits avant création
      final conflicts = await _checkConflicts(childId, startDate, endDate);
      final hasConflict = conflicts.isNotEmpty;

      final response = await _supabase
          .from('events')
          .insert({
            'child_id': childId,
            'title': title,
            'start_date': startDate.toIso8601String(),
            'end_date': endDate?.toIso8601String(),
            'conflict': hasConflict,
          })
          .select()
          .single();

      final event = Event.fromJson(response);
      _events.add(event);
      _events.sort((a, b) => a.startDate.compareTo(b.startDate));
      notifyListeners();

      return event;
    } catch (e) {
      debugPrint('Erreur createEvent: $e');
      rethrow;
    }
  }

  /// Vérifier les conflits pour un événement
  Future<List<Event>> _checkConflicts(
    String childId,
    DateTime startDate,
    DateTime? endDate,
  ) async {
    try {
      final eventEnd = endDate ?? startDate.add(const Duration(hours: 1));

      // Récupérer tous les événements de l'enfant
      final allEvents = await _supabase
          .from('events')
          .select('*')
          .eq('child_id', childId);

      final conflicts = <Event>[];
      for (var eventJson in allEvents as List<dynamic>) {
        final event = Event.fromJson(eventJson as Map<String, dynamic>);
        final otherStart = event.startDate;
        final otherEnd = event.endDate ?? otherStart.add(const Duration(hours: 1));

        // Vérifier chevauchement
        if ((startDate.isBefore(otherEnd) && eventEnd.isAfter(otherStart)) ||
            (otherStart.isBefore(eventEnd) && otherEnd.isAfter(startDate))) {
          conflicts.add(event);
        }
      }

      return conflicts;
    } catch (e) {
      debugPrint('Erreur _checkConflicts: $e');
      return [];
    }
  }

  /// Mettre à jour un événement
  Future<void> updateEvent({
    required String eventId,
    String? title,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('Utilisateur non connecté');
      }

      final updates = <String, dynamic>{};
      if (title != null) updates['title'] = title;
      if (startDate != null) updates['start_date'] = startDate.toIso8601String();
      if (endDate != null) updates['end_date'] = endDate.toIso8601String();

      await _supabase
          .from('events')
          .update(updates)
          .eq('id', eventId);

      await loadEvents();
    } catch (e) {
      debugPrint('Erreur updateEvent: $e');
      rethrow;
    }
  }

  /// Supprimer un événement
  Future<void> deleteEvent(String eventId) async {
    try {
      await _supabase
          .from('events')
          .delete()
          .eq('id', eventId);

      _events.removeWhere((e) => e.id == eventId);
      notifyListeners();
    } catch (e) {
      debugPrint('Erreur deleteEvent: $e');
      rethrow;
    }
  }

  /// Obtenir un événement par ID
  Future<Event?> getEventById(String eventId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return null;

      // Vérifier que l'événement appartient à un enfant de l'utilisateur
      final eventResponse = await _supabase
          .from('events')
          .select('child_id')
          .eq('id', eventId)
          .single();

      final childId = eventResponse['child_id'] as String;

      final childResponse = await _supabase
          .from('children')
          .select('id')
          .eq('id', childId)
          .eq('parent_id', userId)
          .single();

      if (childResponse == null) {
        return null;
      }

      // Récupérer l'événement complet
      final response = await _supabase
          .from('events')
          .select('*')
          .eq('id', eventId)
          .single();

      return Event.fromJson(response);
    } catch (e) {
      debugPrint('Erreur getEventById: $e');
      return null;
    }
  }
}


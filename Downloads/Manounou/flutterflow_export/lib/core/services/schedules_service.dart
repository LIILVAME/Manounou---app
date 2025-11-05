import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum ScheduleType {
  regular, // Horaires identiques chaque semaine
  daily, // Horaires différents selon les jours
  punctual, // Exception ou date spécifique
}

class Schedule {
  final String id;
  final String childId;
  final ScheduleType type;
  final String? name;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<ScheduleItem> items;

  Schedule({
    required this.id,
    required this.childId,
    required this.type,
    this.name,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.items = const [],
  });

  factory Schedule.fromJson(Map<String, dynamic> json, {List<ScheduleItem>? items}) {
    return Schedule(
      id: json['id'] as String,
      childId: json['child_id'] as String,
      type: ScheduleType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ScheduleType.regular,
      ),
      name: json['name'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      items: items ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'child_id': childId,
      'type': type.name,
      'name': name,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class ScheduleItem {
  final String id;
  final String scheduleId;
  final int? dayOfWeek; // 0 = Dimanche, 1 = Lundi, etc.
  final DateTime? date; // Date spécifique pour ponctuel
  final TimeOfDay? dropOffTime;
  final TimeOfDay? pickUpTime;
  final String? notes;
  final bool isException;
  final String? parentScheduleItemId;
  final DateTime createdAt;
  final DateTime updatedAt;

  ScheduleItem({
    required this.id,
    required this.scheduleId,
    this.dayOfWeek,
    this.date,
    this.dropOffTime,
    this.pickUpTime,
    this.notes,
    this.isException = false,
    this.parentScheduleItemId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ScheduleItem.fromJson(Map<String, dynamic> json) {
    return ScheduleItem(
      id: json['id'] as String,
      scheduleId: json['schedule_id'] as String,
      dayOfWeek: json['day_of_week'] as int?,
      date: json['date'] != null ? DateTime.parse(json['date'] as String) : null,
      dropOffTime: json['drop_off_time'] != null
          ? _parseTime(json['drop_off_time'] as String)
          : null,
      pickUpTime: json['pick_up_time'] != null
          ? _parseTime(json['pick_up_time'] as String)
          : null,
      notes: json['notes'] as String?,
      isException: json['is_exception'] as bool? ?? false,
      parentScheduleItemId: json['parent_schedule_item_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'schedule_id': scheduleId,
      'day_of_week': dayOfWeek,
      'date': date?.toIso8601String().split('T')[0],
      'drop_off_time': dropOffTime != null
          ? '${dropOffTime!.hour.toString().padLeft(2, '0')}:${dropOffTime!.minute.toString().padLeft(2, '0')}'
          : null,
      'pick_up_time': pickUpTime != null
          ? '${pickUpTime!.hour.toString().padLeft(2, '0')}:${pickUpTime!.minute.toString().padLeft(2, '0')}'
          : null,
      'notes': notes,
      'is_exception': isException,
      'parent_schedule_item_id': parentScheduleItemId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  static TimeOfDay _parseTime(String time) {
    final parts = time.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }
}

class SchedulesService extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<Schedule> _schedules = [];
  bool _isLoading = false;

  // Cache par enfant pour éviter les requêtes répétées
  final Map<String, List<Schedule>> _schedulesByChild = {};
  
  // Cache des résultats getScheduleForDate pour éviter les recalculs
  final Map<String, ScheduleItem?> _scheduleCache = {};
  
  // Cache des plannings chargés pour tous les enfants
  bool _allSchedulesLoaded = false;

  List<Schedule> get schedules => _schedules;
  bool get isLoading => _isLoading;

  /// Vider le cache des plannings
  void clearCache() {
    _schedules.clear();
    _schedulesByChild.clear();
    _scheduleCache.clear();
    _allSchedulesLoaded = false;
    notifyListeners();
  }
  
  /// Charger tous les plannings de tous les enfants (optimisation)
  Future<void> loadAllSchedules(List<String> childIds) async {
    if (_allSchedulesLoaded && _schedulesByChild.keys.length == childIds.length) {
      return; // Déjà chargé
    }
    
    _isLoading = true;
    notifyListeners();
    
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        _schedules = [];
        _allSchedulesLoaded = true;
        notifyListeners();
        return;
      }
      
      // Charger tous les plannings en une seule requête
      // Utiliser plusieurs requêtes en parallèle car .inFilter() peut ne pas être disponible
      final scheduleFutures = childIds.map((childId) {
        return _supabase
            .from('schedules')
            .select('*')
            .eq('child_id', childId)
            .eq('is_active', true)
            .order('created_at', ascending: false);
      });
      
      final scheduleResponses = await Future.wait(scheduleFutures);
      final schedulesList = scheduleResponses
          .expand((response) => response as List<dynamic>)
          .map((json) => json as Map<String, dynamic>)
          .toList();
      
      // Charger tous les items en une seule requête
      if (schedulesList.isNotEmpty) {
        final scheduleIds = schedulesList.map((s) => s['id'] as String).toList();
        
        // Utiliser plusieurs requêtes en parallèle pour les items
        final itemFutures = scheduleIds.map((scheduleId) {
          return _supabase
              .from('schedule_items')
              .select('*')
              .eq('schedule_id', scheduleId)
              .order('day_of_week', ascending: true)
              .order('date', ascending: true);
        });
        
        final itemResponses = await Future.wait(itemFutures);
        final allItems = itemResponses
            .expand((response) => response as List<dynamic>)
            .map((json) => ScheduleItem.fromJson(json as Map<String, dynamic>))
            .toList();
        
        // Grouper les items par schedule_id
        final itemsBySchedule = <String, List<ScheduleItem>>{};
        for (var item in allItems) {
          itemsBySchedule.putIfAbsent(item.scheduleId, () => []).add(item);
        }
        
        // Construire les schedules avec leurs items
        final schedulesWithItems = <Schedule>[];
        for (var scheduleJson in schedulesList) {
          final scheduleId = scheduleJson['id'] as String;
          final items = itemsBySchedule[scheduleId] ?? [];
          schedulesWithItems.add(Schedule.fromJson(scheduleJson, items: items));
        }
        
        // Grouper par enfant
        _schedulesByChild.clear();
        for (var schedule in schedulesWithItems) {
          _schedulesByChild.putIfAbsent(schedule.childId, () => []).add(schedule);
        }
        
        _schedules = schedulesWithItems;
      }
      
      _allSchedulesLoaded = true;
    } catch (e) {
      debugPrint('Erreur loadAllSchedules: $e');
      _allSchedulesLoaded = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Charger tous les plannings d'un enfant
  Future<void> loadSchedulesForChild(String childId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        _schedules = [];
        notifyListeners();
        return;
      }

      // Vérifier que l'enfant appartient à l'utilisateur
      final child = await _supabase
          .from('children')
          .select('id')
          .eq('id', childId)
          .eq('parent_id', userId)
          .single();

      if (child == null) {
        _schedules = [];
        notifyListeners();
        return;
      }

      // Récupérer les plannings
      final schedulesResponse = await _supabase
          .from('schedules')
          .select('*')
          .eq('child_id', childId)
          .eq('is_active', true)
          .order('created_at', ascending: false);

      final schedulesList = (schedulesResponse as List<dynamic>)
          .map((json) => Schedule.fromJson(json as Map<String, dynamic>))
          .toList();

      // Récupérer les items pour chaque planning
      final schedulesWithItems = <Schedule>[];
      for (var scheduleJson in schedulesList) {
        final schedule = Schedule.fromJson(scheduleJson.toJson());
        final itemsResponse = await _supabase
            .from('schedule_items')
            .select('*')
            .eq('schedule_id', schedule.id)
            .order('day_of_week', ascending: true)
            .order('date', ascending: true);

        final items = (itemsResponse as List<dynamic>)
            .map((json) => ScheduleItem.fromJson(json as Map<String, dynamic>))
            .toList();

        schedulesWithItems.add(Schedule.fromJson(schedule.toJson(), items: items));
      }

      _schedules = schedulesWithItems;
    } catch (e) {
      debugPrint('Erreur loadSchedulesForChild: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Obtenir les horaires pour une date donnée (avec priorité) - VERSION OPTIMISÉE
  Future<ScheduleItem?> getScheduleForDate(String childId, DateTime date) async {
    // Utiliser le cache si disponible
    final cacheKey = '${childId}_${date.year}_${date.month}_${date.day}';
    if (_scheduleCache.containsKey(cacheKey)) {
      return _scheduleCache[cacheKey];
    }
    
    ScheduleItem? result;
    
    try {
      // Utiliser le cache en mémoire si disponible
      final childSchedules = _schedulesByChild[childId] ?? _schedules.where((s) => s.childId == childId).toList();
      
      if (childSchedules.isNotEmpty) {
        // Chercher dans le cache en mémoire (priorité : Ponctuel > Par jour > Régulier)
        final dateStr = date.toIso8601String().split('T')[0];
        final weekday = date.weekday;
      
      // 1. Chercher ponctuel (date exacte)
        for (var schedule in childSchedules) {
          if (schedule.type == ScheduleType.punctual) {
            for (var item in schedule.items) {
              if (item.date != null && item.date!.toIso8601String().split('T')[0] == dateStr) {
                result = item;
                break;
              }
            }
            if (result != null) break;
          }
        }

      // 2. Chercher par jour (day_of_week)
        if (result == null) {
          for (var schedule in childSchedules) {
            if (schedule.type == ScheduleType.daily) {
              for (var item in schedule.items) {
                if (item.dayOfWeek == weekday) {
                  result = item;
                  break;
                }
              }
              if (result != null) break;
            }
          }
        }

      // 3. Chercher régulier (tous les jours)
        if (result == null) {
          for (var schedule in childSchedules) {
            if (schedule.type == ScheduleType.regular && schedule.items.isNotEmpty) {
              result = schedule.items.first;
              break;
            }
          }
        }
      } else {
        // Fallback : requête SQL si pas dans le cache (pour compatibilité)
        final punctual = await _getPunctualSchedule(childId, date);
        if (punctual != null) {
          result = punctual;
        } else {
          final daily = await _getDailySchedule(childId, date.weekday);
          if (daily != null) {
            result = daily;
          } else {
            result = await _getRegularSchedule(childId);
          }
        }
      }
      
      // Mettre en cache
      _scheduleCache[cacheKey] = result;
      
      // Limiter la taille du cache (garder les 1000 dernières entrées)
      if (_scheduleCache.length > 1000) {
        final keys = _scheduleCache.keys.toList();
        for (var i = 0; i < 200; i++) {
          _scheduleCache.remove(keys[i]);
        }
      }
      
      return result;
    } catch (e) {
      debugPrint('Erreur getScheduleForDate: $e');
      return null;
    }
  }

  Future<ScheduleItem?> _getPunctualSchedule(String childId, DateTime date) async {
    try {
      // Chercher d'abord un planning ponctuel actif pour cet enfant
      final schedulesResponse = await _supabase
          .from('schedules')
          .select('id')
          .eq('child_id', childId)
          .eq('type', 'punctual')
          .eq('is_active', true)
          .limit(1);

      if (schedulesResponse == null || (schedulesResponse as List).isEmpty) {
        return null;
      }

      final scheduleId = (schedulesResponse as List).first['id'] as String;
      final dateStr = date.toIso8601String().split('T')[0];

      // Chercher l'item pour cette date
      final itemsResponse = await _supabase
          .from('schedule_items')
          .select('*')
          .eq('schedule_id', scheduleId)
          .eq('date', dateStr)
          .limit(1);

      if (itemsResponse == null || (itemsResponse as List).isEmpty) {
        return null;
      }
      
      return ScheduleItem.fromJson((itemsResponse as List).first as Map<String, dynamic>);
    } catch (e) {
      // Ignorer silencieusement les erreurs (pas de planning = normal)
      debugPrint('⚠️ Erreur _getPunctualSchedule: $e');
      return null;
    }
  }

  Future<ScheduleItem?> _getDailySchedule(String childId, int weekday) async {
    try {
      // Chercher d'abord un planning quotidien actif pour cet enfant
      final schedulesResponse = await _supabase
          .from('schedules')
          .select('id')
          .eq('child_id', childId)
          .eq('type', 'daily')
          .eq('is_active', true)
          .limit(1);

      if (schedulesResponse == null || (schedulesResponse as List).isEmpty) {
        return null;
      }

      final scheduleId = (schedulesResponse as List).first['id'] as String;

      // Chercher l'item pour ce jour de la semaine
      final itemsResponse = await _supabase
          .from('schedule_items')
          .select('*')
          .eq('schedule_id', scheduleId)
          .eq('day_of_week', weekday)
          .limit(1);

      if (itemsResponse == null || (itemsResponse as List).isEmpty) {
        return null;
      }
      
      return ScheduleItem.fromJson((itemsResponse as List).first as Map<String, dynamic>);
    } catch (e) {
      // Ignorer silencieusement les erreurs (pas de planning = normal)
      debugPrint('⚠️ Erreur _getDailySchedule: $e');
      return null;
    }
  }

  Future<ScheduleItem?> _getRegularSchedule(String childId) async {
    try {
      // Chercher d'abord un planning régulier actif pour cet enfant
      final schedulesResponse = await _supabase
          .from('schedules')
          .select('id')
          .eq('child_id', childId)
          .eq('type', 'regular')
          .eq('is_active', true)
          .limit(1);

      if (schedulesResponse == null || (schedulesResponse as List).isEmpty) {
        return null;
      }

      final scheduleId = (schedulesResponse as List).first['id'] as String;

      // Chercher le premier item du planning régulier
      final itemsResponse = await _supabase
          .from('schedule_items')
          .select('*')
          .eq('schedule_id', scheduleId)
          .limit(1);

      if (itemsResponse == null || (itemsResponse as List).isEmpty) {
        return null;
      }
      
      return ScheduleItem.fromJson((itemsResponse as List).first as Map<String, dynamic>);
    } catch (e) {
      // Ignorer silencieusement les erreurs (pas de planning = normal)
      debugPrint('⚠️ Erreur _getRegularSchedule: $e');
      return null;
    }
  }

  /// Créer un planning
  Future<Schedule> createSchedule({
    required String childId,
    required ScheduleType type,
    String? name,
    List<ScheduleItem>? items,
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

      // Créer le planning
      final scheduleResponse = await _supabase
          .from('schedules')
          .insert({
            'child_id': childId,
            'type': type.name,
            'name': name,
            'is_active': true,
          })
          .select()
          .single();

      final schedule = Schedule.fromJson(scheduleResponse);

      // Créer les items si fournis
      if (items != null && items.isNotEmpty) {
        for (var item in items) {
          await createScheduleItem(
            scheduleId: schedule.id,
            dayOfWeek: item.dayOfWeek,
            date: item.date,
            dropOffTime: item.dropOffTime,
            pickUpTime: item.pickUpTime,
            notes: item.notes,
            isException: item.isException,
            parentScheduleItemId: item.parentScheduleItemId,
          );
        }
      }

      await loadSchedulesForChild(childId);
      
      // Retourner le planning mis à jour avec items
      final updatedSchedule = _schedules.firstWhere((s) => s.id == schedule.id);
      return updatedSchedule;
    } catch (e) {
      debugPrint('Erreur createSchedule: $e');
      rethrow;
    }
  }

  /// Créer un item de planning
  Future<ScheduleItem> createScheduleItem({
    required String scheduleId,
    int? dayOfWeek,
    DateTime? date,
    TimeOfDay? dropOffTime,
    TimeOfDay? pickUpTime,
    String? notes,
    bool isException = false,
    String? parentScheduleItemId,
  }) async {
    try {
      // Validation
      if (dropOffTime != null && pickUpTime != null) {
        final dropOffMinutes = dropOffTime.hour * 60 + dropOffTime.minute;
        final pickUpMinutes = pickUpTime.hour * 60 + pickUpTime.minute;
        if (dropOffMinutes >= pickUpMinutes) {
          throw Exception('L\'heure de récupération doit être après le dépôt');
        }
      }

      final itemResponse = await _supabase
          .from('schedule_items')
          .insert({
            'schedule_id': scheduleId,
            'day_of_week': dayOfWeek,
            'date': date?.toIso8601String().split('T')[0],
            'drop_off_time': dropOffTime != null
                ? '${dropOffTime.hour.toString().padLeft(2, '0')}:${dropOffTime.minute.toString().padLeft(2, '0')}'
                : null,
            'pick_up_time': pickUpTime != null
                ? '${pickUpTime.hour.toString().padLeft(2, '0')}:${pickUpTime.minute.toString().padLeft(2, '0')}'
                : null,
            'notes': notes,
            'is_exception': isException,
            'parent_schedule_item_id': parentScheduleItemId,
          })
          .select()
          .single();

      return ScheduleItem.fromJson(itemResponse);
    } catch (e) {
      debugPrint('Erreur createScheduleItem: $e');
      rethrow;
    }
  }

  /// Mettre à jour un item de planning
  Future<void> updateScheduleItem({
    required String itemId,
    TimeOfDay? dropOffTime,
    TimeOfDay? pickUpTime,
    String? notes,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (dropOffTime != null) {
        updates['drop_off_time'] =
            '${dropOffTime.hour.toString().padLeft(2, '0')}:${dropOffTime.minute.toString().padLeft(2, '0')}';
      }
      if (pickUpTime != null) {
        updates['pick_up_time'] =
            '${pickUpTime.hour.toString().padLeft(2, '0')}:${pickUpTime.minute.toString().padLeft(2, '0')}';
      }
      if (notes != null) updates['notes'] = notes;

      await _supabase
          .from('schedule_items')
          .update(updates)
          .eq('id', itemId);
    } catch (e) {
      debugPrint('Erreur updateScheduleItem: $e');
      rethrow;
    }
  }

  /// Supprimer un planning
  Future<void> deleteSchedule(String scheduleId) async {
    try {
      await _supabase
          .from('schedules')
          .delete()
          .eq('id', scheduleId);
      
      _schedules.removeWhere((s) => s.id == scheduleId);
      notifyListeners();
    } catch (e) {
      debugPrint('Erreur deleteSchedule: $e');
      rethrow;
    }
  }

  /// Détecter les conflits pour une date
  Future<List<ScheduleItem>> detectConflicts(String childId, DateTime date, TimeOfDay? dropOff, TimeOfDay? pickUp) async {
    try {
      if (dropOff == null || pickUp == null) return [];

      final existingSchedule = await getScheduleForDate(childId, date);
      if (existingSchedule == null) return [];

      final existingDropOff = existingSchedule.dropOffTime;
      final existingPickUp = existingSchedule.pickUpTime;

      if (existingDropOff == null || existingPickUp == null) return [];

      // Vérifier chevauchement
      final dropOffMinutes = dropOff.hour * 60 + dropOff.minute;
      final pickUpMinutes = pickUp.hour * 60 + pickUp.minute;
      final existingDropOffMinutes = existingDropOff.hour * 60 + existingDropOff.minute;
      final existingPickUpMinutes = existingPickUp.hour * 60 + existingPickUp.minute;

      final hasConflict = (dropOffMinutes < existingPickUpMinutes && pickUpMinutes > existingDropOffMinutes);

      return hasConflict ? [existingSchedule] : [];
    } catch (e) {
      debugPrint('Erreur detectConflicts: $e');
      return [];
    }
  }

  /// Copier un planning vers un autre enfant
  Future<Schedule> copyScheduleToChild(String scheduleId, String targetChildId) async {
    try {
      final schedule = _schedules.firstWhere((s) => s.id == scheduleId);
      
      final newSchedule = await createSchedule(
        childId: targetChildId,
        type: schedule.type,
        name: schedule.name != null ? '${schedule.name} (copie)' : null,
      );

      // Copier les items
      for (var item in schedule.items) {
        await createScheduleItem(
          scheduleId: newSchedule.id,
          dayOfWeek: item.dayOfWeek,
          date: item.date,
          dropOffTime: item.dropOffTime,
          pickUpTime: item.pickUpTime,
          notes: item.notes,
        );
      }

      return newSchedule;
    } catch (e) {
      debugPrint('Erreur copyScheduleToChild: $e');
      rethrow;
    }
  }
}


import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Helper centralisé pour la gestion des dates dans Manounou
/// Assure la cohérence des formats et des limites de date dans toute l'application
class DateHelper {
  // Locale française par défaut
  static const Locale frenchLocale = Locale('fr', 'FR');

  // ============================================================================
  // FORMATS DE DATE STANDARDISÉS
  // ============================================================================

  /// Format complet : "15 janvier 2025"
  static String formatFullDate(DateTime date) {
    return DateFormat('dd MMMM yyyy', 'fr_FR').format(date);
  }

  /// Format court : "15 jan 2025"
  static String formatShortDate(DateTime date) {
    return DateFormat('dd MMM yyyy', 'fr_FR').format(date);
  }

  /// Format avec jour : "lundi 15 janvier 2025"
  static String formatFullDateWithDay(DateTime date) {
    return DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(date);
  }

  /// Format jour sans année : "lundi 15 janvier"
  static String formatDayAndDate(DateTime date) {
    return DateFormat('EEEE d MMMM', 'fr_FR').format(date);
  }

  /// Format date sans année : "15 janvier"
  static String formatDateWithoutYear(DateTime date) {
    return DateFormat('dd MMMM', 'fr_FR').format(date);
  }

  /// Format date avec heure : "15 janvier 2025 à 14:30"
  static String formatDateWithTime(DateTime date) {
    return DateFormat('dd MMMM yyyy \'à\' HH:mm', 'fr_FR').format(date);
  }

  /// Format heure seule : "14:30"
  static String formatTime(DateTime date) {
    return DateFormat('HH:mm', 'fr_FR').format(date);
  }

  /// Format TimeOfDay en string : "14:30"
  static String formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Format pour date de naissance : "Né(e) le 15 janvier 2025"
  static String formatBirthDate(DateTime date) {
    final isFirstDay = date.day == 1;
    final genderSuffix = isFirstDay ? 'e' : '';
    return 'Né$genderSuffix le ${formatFullDate(date)}';
  }

  /// Format pour date de naissance courte : "Né(e) le 15 janvier"
  static String formatBirthDateShort(DateTime date) {
    final isFirstDay = date.day == 1;
    final genderSuffix = isFirstDay ? 'e' : '';
    return 'Né$genderSuffix le ${formatDateWithoutYear(date)}';
  }

  /// Format mois complet : "janvier 2025"
  static String formatMonth(DateTime date) {
    return DateFormat('MMMM yyyy', 'fr_FR').format(date);
  }

  /// Format jour de la semaine court : "Lun", "Mar", etc.
  static String formatDayShort(DateTime date) {
    return DateFormat('E', 'fr_FR').format(date);
  }

  /// Format mois court : "jan"
  static String formatMonthShort(DateTime date) {
    return DateFormat('MMM', 'fr_FR').format(date);
  }

  // ============================================================================
  // LIMITES DE DATE STANDARDISÉES
  // ============================================================================

  /// Limites pour date de naissance (passé uniquement)
  static DateTimeRange getBirthDateRange() {
    return DateTimeRange(
      start: DateTime(1900),
      end: DateTime.now(),
    );
  }

  /// Limites pour événements (passé et futur)
  static DateTimeRange getEventDateRange() {
    return DateTimeRange(
      start: DateTime.now().subtract(const Duration(days: 365)),
      end: DateTime.now().add(const Duration(days: 365)),
    );
  }

  /// Limites pour horaires ponctuels (futur uniquement)
  static DateTimeRange getScheduleDateRange() {
    return DateTimeRange(
      start: DateTime.now(),
      end: DateTime.now().add(const Duration(days: 365)),
    );
  }

  /// Limites pour documents (large range)
  static DateTimeRange getDocumentDateRange() {
    return DateTimeRange(
      start: DateTime(2000),
      end: DateTime.now().add(const Duration(days: 365)),
    );
  }

  // ============================================================================
  // HELPERS POUR DatePicker
  // ============================================================================

  /// Afficher un DatePicker pour date de naissance
  static Future<DateTime?> showBirthDatePicker(
    BuildContext context, {
    DateTime? initialDate,
  }) {
    final range = getBirthDateRange();
    return showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: range.start,
      lastDate: range.end,
      locale: frenchLocale,
      helpText: 'Sélectionner la date de naissance',
      cancelText: 'Annuler',
      confirmText: 'Confirmer',
    );
  }

  /// Afficher un DatePicker pour événements
  static Future<DateTime?> showEventDatePicker(
    BuildContext context, {
    DateTime? initialDate,
    DateTime? minDate,
  }) {
    final range = getEventDateRange();
    return showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: minDate ?? range.start,
      lastDate: range.end,
      locale: frenchLocale,
      helpText: 'Sélectionner la date',
      cancelText: 'Annuler',
      confirmText: 'Confirmer',
    );
  }

  /// Afficher un DatePicker pour horaires ponctuels
  static Future<DateTime?> showScheduleDatePicker(
    BuildContext context, {
    DateTime? initialDate,
  }) {
    final range = getScheduleDateRange();
    return showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: range.start,
      lastDate: range.end,
      locale: frenchLocale,
      helpText: 'Sélectionner la date',
      cancelText: 'Annuler',
      confirmText: 'Confirmer',
    );
  }

  // ============================================================================
  // HELPERS POUR TimePicker
  // ============================================================================

  /// Afficher un TimePicker standard
  static Future<TimeOfDay?> showTimePickerStandard(
    BuildContext context, {
    TimeOfDay? initialTime,
  }) {
    return showTimePicker(
      context: context,
      initialTime: initialTime ?? TimeOfDay.now(),
      helpText: 'Sélectionner l\'heure',
      cancelText: 'Annuler',
      confirmText: 'Confirmer',
      builder: (context, child) {
        return Localizations.override(
          context: context,
          locale: frenchLocale,
          child: child,
        );
      },
    );
  }

  // ============================================================================
  // HELPERS UTILITAIRES
  // ============================================================================

  /// Vérifier si une date est aujourd'hui
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Vérifier si une date est dans le passé
  static bool isPast(DateTime date) {
    final now = DateTime.now();
    final dateOnly = DateTime(date.year, date.month, date.day);
    final nowOnly = DateTime(now.year, now.month, now.day);
    return dateOnly.isBefore(nowOnly);
  }

  /// Vérifier si une date est dans le futur
  static bool isFuture(DateTime date) {
    final now = DateTime.now();
    final dateOnly = DateTime(date.year, date.month, date.day);
    final nowOnly = DateTime(now.year, now.month, now.day);
    return dateOnly.isAfter(nowOnly);
  }

  /// Obtenir le début de la journée (00:00:00)
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Obtenir la fin de la journée (23:59:59)
  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59);
  }

  /// Obtenir le début de la semaine (lundi)
  static DateTime startOfWeek(DateTime date) {
    final weekday = date.weekday;
    final daysFromMonday = weekday - 1;
    return startOfDay(date.subtract(Duration(days: daysFromMonday)));
  }

  /// Obtenir la fin de la semaine (dimanche)
  static DateTime endOfWeek(DateTime date) {
    final weekday = date.weekday;
    final daysToSunday = 7 - weekday;
    return endOfDay(date.add(Duration(days: daysToSunday)));
  }

  /// Obtenir le début du mois
  static DateTime startOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  /// Obtenir la fin du mois
  static DateTime endOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0, 23, 59, 59);
  }

  /// Nombre de jours entre deux dates
  static int daysBetween(DateTime start, DateTime end) {
    final startDate = startOfDay(start);
    final endDate = startOfDay(end);
    return endDate.difference(startDate).inDays;
  }

  /// Formater une durée en texte lisible
  static String formatDuration(Duration duration) {
    if (duration.inDays > 365) {
      final years = (duration.inDays / 365).floor();
      return '$years an${years > 1 ? 's' : ''}';
    } else if (duration.inDays > 30) {
      final months = (duration.inDays / 30).floor();
      return '$months mois';
    } else if (duration.inDays > 0) {
      return '${duration.inDays} jour${duration.inDays > 1 ? 's' : ''}';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} heure${duration.inHours > 1 ? 's' : ''}';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes} minute${duration.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'Quelques secondes';
    }
  }
}


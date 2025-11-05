import 'package:flutter/material.dart';

/// Palette de couleurs Manounou
class AppColors {
  // Couleurs primaires (pastel)
  static const Color primary = Color(0xFFFFB6C1); // Pastel Pink
  static const Color primaryLight = Color(0xFFFFE4E1); // Light Pink
  static const Color primaryDark = Color(0xFFFF69B4); // Hot Pink

  // Couleurs secondaires
  static const Color secondary = Color(0xFFB0E0E6); // Powder Blue
  static const Color secondaryLight = Color(0xFFE0F7FA); // Light Blue
  static const Color secondaryDark = Color(0xFF87CEEB); // Sky Blue

  // Couleurs accent
  static const Color accent = Color(0xFFFFD700); // Gold
  static const Color accentLight = Color(0xFFFFF8DC); // Cornsilk
  static const Color accentDark = Color(0xFFFFA500); // Orange

  // Couleurs texte
  static const Color textPrimary = Color(0xFF2C3E50); // Dark Blue Grey
  static const Color textSecondary = Color(0xFF7F8C8D); // Grey
  static const Color textLight = Color(0xFF95A5A6); // Light Grey

  // Couleurs de fond
  static const Color background = Color(0xFFFAFAFA); // Off White
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFF5F5F5); // Light Grey

  // Couleurs d'état
  static const Color success = Color(0xFF4CAF50); // Green
  static const Color warning = Color(0xFFFFC107); // Amber
  static const Color error = Color(0xFFE53935); // Red
  static const Color info = Color(0xFF2196F3); // Blue

  // Couleurs pour enfants (pastel)
  static const List<Color> childColors = [
    Color(0xFFFFB6C1), // Pink
    Color(0xFFB0E0E6), // Blue
    Color(0xFFFFD700), // Gold
    Color(0xFF98D8C8), // Mint
    Color(0xFFFFA07A), // Light Salmon
    Color(0xFFDDA0DD), // Plum
    Color(0xFF87CEEB), // Sky Blue
    Color(0xFFFFE4B5), // Moccasin
  ];

  /// Obtenir une couleur pour un enfant basée sur son index
  static Color getChildColor(int index) {
    return childColors[index % childColors.length];
  }
}


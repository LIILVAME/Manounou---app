import 'package:flutter/material.dart';

/// Palette de couleurs inspirée de FamPlan
class FamPlanColors {
  // Couleurs principales
  static const Color darkPurple = Color(0xFF2D1B4E); // Fond onboarding
  static const Color tealGreen = Color(0xFF4ECDC4); // Boutons primaires, cartes
  static const Color orange = Color(0xFFFF6B6B); // Cartes, accents
  static const Color blue = Color(0xFF4A90E2); // Cartes, accents
  static const Color white = Color(0xFFFFFFFF);
  static const Color yellow = Color(0xFFFFD93D); // Accents

  // Couleurs de texte
  static const Color textDark = Color(0xFF2C3E50);
  static const Color textLight = Color(0xFF7F8C8D);
  static const Color textWhite = Color(0xFFFFFFFF);

  // Couleurs de fond
  static const Color backgroundWhite = Color(0xFFFFFFFF);
  static const Color backgroundLight = Color(0xFFF5F5F5);

  // Couleurs pour cartes d'enfants (variations)
  static const List<Color> cardColors = [
    tealGreen,
    orange,
    blue,
    yellow,
    Color(0xFF95E1D3), // Mint
    Color(0xFFFFA07A), // Light Salmon
    Color(0xFFDDA0DD), // Plum
  ];

  /// Obtenir une couleur pour une carte basée sur l'index
  static Color getCardColor(int index) {
    return cardColors[index % cardColors.length];
  }

  /// Gradient pour fond onboarding
  static const LinearGradient onboardingGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [darkPurple, Color(0xFF1A0F35)],
  );
}


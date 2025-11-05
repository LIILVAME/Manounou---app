import 'package:flutter/material.dart';

/// Styles de texte réutilisables pour Manounou
class AppTextStyles {
  // Headings
  static TextStyle h1(BuildContext context) {
    return Theme.of(context).textTheme.headlineLarge?.copyWith(
          fontWeight: FontWeight.bold,
          fontSize: 32,
        ) ?? const TextStyle(fontSize: 32, fontWeight: FontWeight.bold);
  }

  static TextStyle h2(BuildContext context) {
    return Theme.of(context).textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ) ?? const TextStyle(fontSize: 24, fontWeight: FontWeight.bold);
  }

  static TextStyle h3(BuildContext context) {
    return Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ) ?? const TextStyle(fontSize: 20, fontWeight: FontWeight.bold);
  }

  // Body
  static TextStyle bodyLarge(BuildContext context) {
    return Theme.of(context).textTheme.bodyLarge ?? const TextStyle(fontSize: 16);
  }

  static TextStyle bodyMedium(BuildContext context) {
    return Theme.of(context).textTheme.bodyMedium ?? const TextStyle(fontSize: 14);
  }

  static TextStyle bodySmall(BuildContext context) {
    return Theme.of(context).textTheme.bodySmall ?? const TextStyle(fontSize: 12);
  }

  // Caption
  static TextStyle caption(BuildContext context) {
    return Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Colors.grey[600],
          fontSize: 12,
        ) ?? TextStyle(fontSize: 12, color: Colors.grey[600]);
  }

  // Labels
  static TextStyle label(BuildContext context) {
    return Theme.of(context).textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w500,
        ) ?? const TextStyle(fontWeight: FontWeight.w500);
  }
}


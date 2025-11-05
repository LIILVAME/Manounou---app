import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Enum pour le genre de l'enfant
enum ChildGender { male, female }

/// Service pour gérer les avatars Studio Ghibli des enfants
class AvatarService {
  static final Random _random = Random();

  /// Liste des origines disponibles pour chaque genre (pour sélection aléatoire)
  static const List<String> _maleOrigins = ['chinese', 'ivorian', 'french'];
  static const List<String> _femaleOrigins = ['chinese', 'ivorian', 'french'];

  /// Sélectionne aléatoirement un avatar selon le genre
  /// Format: 'assets/avatars/{gender}_{origin}.svg'
  static String getRandomAvatarPath(ChildGender? gender) {
    // Valeur par défaut si non spécifié
    final g = gender ?? ChildGender.male;
    final genderStr = g == ChildGender.male ? 'male' : 'female';
    
    // Sélection aléatoire parmi les 3 origines disponibles
    final origins = g == ChildGender.male ? _maleOrigins : _femaleOrigins;
    final randomOrigin = origins[_random.nextInt(origins.length)];

    return 'assets/avatars/${genderStr}_$randomOrigin.svg';
  }

  /// Obtient un avatar spécifique (pour affichage si déjà assigné)
  /// Format: 'assets/avatars/{gender}_{origin}.svg'
  static String getAvatarPath(ChildGender? gender, String? origin) {
    final g = gender ?? ChildGender.male;
    final genderStr = g == ChildGender.male ? 'male' : 'female';
    
    // Si une origine est spécifiée, l'utiliser, sinon choisir aléatoirement
    String originStr;
    if (origin != null && origin.isNotEmpty) {
      originStr = origin;
    } else {
      final origins = g == ChildGender.male ? _maleOrigins : _femaleOrigins;
      originStr = origins[_random.nextInt(origins.length)];
    }

    return 'assets/avatars/${genderStr}_$originStr.svg';
  }

  /// Convertir une string en ChildGender
  static ChildGender? genderFromString(String? value) {
    if (value == null || value.isEmpty) return null;
    switch (value.toUpperCase()) {
      case 'M':
      case 'MALE':
      case 'MASCULIN':
        return ChildGender.male;
      case 'F':
      case 'FEMALE':
      case 'FÉMININ':
        return ChildGender.female;
      default:
        return null;
    }
  }

  /// Convertir ChildGender en string pour la base de données
  static String? genderToString(ChildGender? gender) {
    if (gender == null) return null;
    return gender == ChildGender.male ? 'M' : 'F';
  }

  /// Widget pour afficher un avatar SVG
  static Widget buildAvatarWidget({
    required String assetPath,
    required double size,
    Color? backgroundColor,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        shape: BoxShape.circle,
      ),
      child: ClipOval(
        child: SvgPicture.asset(
          assetPath,
          width: size,
          height: size,
          fit: BoxFit.cover,
          placeholderBuilder: (context) => Container(
            width: size,
            height: size,
            color: Colors.grey[300],
            child: const Icon(Icons.face, size: 24),
          ),
        ),
      ),
    );
  }
}


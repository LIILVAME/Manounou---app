import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/avatar_service.dart';

/// Widget réutilisable pour afficher l'avatar d'un enfant
/// Affiche la photo si disponible, sinon l'avatar Studio Ghibli selon genre/origine
class ChildAvatar extends StatefulWidget {
  final String firstName;
  final String? photoUrl;
  final String? gender; // 'M' ou 'F'
  final double radius;
  final Color? backgroundColor;
  final Color? textColor;

  const ChildAvatar({
    super.key,
    required this.firstName,
    this.photoUrl,
    this.gender,
    this.radius = 30,
    this.backgroundColor,
    this.textColor,
  });

  @override
  State<ChildAvatar> createState() => _ChildAvatarState();
}

class _ChildAvatarState extends State<ChildAvatar> {
  bool _imageError = false;
  bool _svgError = false;

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.backgroundColor ??
        Theme.of(context).colorScheme.primary.withOpacity(0.2);
    final txtColor = widget.textColor ?? Theme.of(context).colorScheme.primary;

    // Si photo disponible et pas d'erreur, afficher la photo ou l'avatar
    if (widget.photoUrl != null && 
        widget.photoUrl!.isNotEmpty && 
        !_imageError) {
      // Détecter si c'est un avatar (préfixe "avatar:") ou une vraie photo
      if (widget.photoUrl!.startsWith('avatar:')) {
        // C'est un avatar SVG local
        final avatarPath = widget.photoUrl!.substring(7); // Retirer "avatar:"
        return CircleAvatar(
          radius: widget.radius,
          backgroundColor: bgColor,
          child: ClipOval(
            child: SvgPicture.asset(
              avatarPath,
              width: widget.radius * 2,
              height: widget.radius * 2,
              fit: BoxFit.cover,
              placeholderBuilder: (context) => _buildInitial(context, bgColor, txtColor),
            ),
          ),
        );
      } else {
        // C'est une vraie photo réseau
        return CircleAvatar(
          radius: widget.radius,
          backgroundImage: NetworkImage(widget.photoUrl!),
          onBackgroundImageError: (exception, stackTrace) {
            // En cas d'erreur, afficher l'avatar SVG selon le genre
            if (mounted) {
              setState(() {
                _imageError = true;
              });
            }
          },
          child: null,
        );
      }
    }

    // Sinon, afficher l'avatar Studio Ghibli ou l'initiale en fallback
    return CircleAvatar(
      radius: widget.radius,
      backgroundColor: bgColor,
      child: _buildAvatarOrInitial(context, bgColor, txtColor),
    );
  }

  Widget _buildAvatarOrInitial(BuildContext context, Color bgColor, Color txtColor) {
    // Si on a un genre, essayer d'afficher un avatar SVG aléatoire
    if (widget.gender != null && !_svgError) {
      final genderEnum = AvatarService.genderFromString(widget.gender);
      
      if (genderEnum != null) {
        final avatarPath = AvatarService.getRandomAvatarPath(genderEnum);
        
        return ClipOval(
          child: SvgPicture.asset(
            avatarPath,
            width: widget.radius * 2,
            height: widget.radius * 2,
            fit: BoxFit.cover,
            placeholderBuilder: (context) => _buildInitial(context, bgColor, txtColor),
            semanticsLabel: 'Avatar ${widget.firstName}',
          ),
        );
      }
    }

    // Fallback : afficher l'initiale
    return _buildInitial(context, bgColor, txtColor);
  }

  Widget _buildInitial(BuildContext context, Color bgColor, Color txtColor) {
    return Text(
      widget.firstName[0].toUpperCase(),
      style: TextStyle(
        fontSize: widget.radius * 0.8,
        fontWeight: FontWeight.bold,
        color: txtColor,
      ),
    );
  }
}

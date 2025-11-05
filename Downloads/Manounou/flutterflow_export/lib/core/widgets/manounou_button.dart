import 'package:flutter/material.dart';
import 'animated_button.dart';

/// Bouton réutilisable avec design cohérent et animations
class ManounouButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isOutlined;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const ManounouButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isOutlined = false,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final buttonStyle = isOutlined
        ? OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            foregroundColor: foregroundColor,
          )
        : ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor,
          );

    final button = isOutlined
        ? OutlinedButton.icon(
            onPressed: isLoading ? null : onPressed,
            style: buttonStyle,
            icon: icon != null
                ? Icon(icon, size: 20)
                : isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const SizedBox.shrink(),
            label: Text(label),
          )
        : ElevatedButton.icon(
            onPressed: isLoading ? null : onPressed,
            style: buttonStyle,
            icon: icon != null
                ? Icon(icon, size: 20)
                : isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const SizedBox.shrink(),
            label: Text(label),
          );

    // Envelopper le bouton avec animation si onPressed est disponible
    if (onPressed != null && !isLoading) {
      return AnimatedButton(
        onPressed: onPressed,
        child: button,
      );
    }

    return button;
  }
}


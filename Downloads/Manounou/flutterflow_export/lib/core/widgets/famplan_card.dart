import 'package:flutter/material.dart';
import '../theme/famplan_colors.dart';

/// Carte colorée inspirée de FamPlan
class FamPlanCard extends StatelessWidget {
  final Widget? child;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final Widget? leadingIcon;
  final Widget? trailingIcon;
  final String? title;
  final String? subtitle;

  const FamPlanCard({
    super.key,
    this.child,
    this.backgroundColor,
    this.onTap,
    this.padding,
    this.leadingIcon,
    this.trailingIcon,
    this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? FamPlanColors.tealGreen;
    final content = child ??
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (leadingIcon != null || trailingIcon != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (leadingIcon != null) leadingIcon!,
                  if (trailingIcon != null) trailingIcon!,
                ],
              ),
            if (title != null) ...[
              const SizedBox(height: 8),
              Text(
                title!,
                style: const TextStyle(
                  color: FamPlanColors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: TextStyle(
                  color: FamPlanColors.white.withOpacity(0.9),
                  fontSize: 14,
                ),
              ),
            ],
          ],
        );

    return Card(
      elevation: 0,
      color: bgColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16.0),
          child: content,
        ),
      ),
    );
  }
}


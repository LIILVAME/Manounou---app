import 'package:flutter/material.dart';
import 'dart:math';
import '../theme/famplan_colors.dart';

/// Fond avec étoiles/disques pour pages onboarding (style FamPlan)
class OnboardingBackground extends StatelessWidget {
  final Widget child;

  const OnboardingBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: FamPlanColors.onboardingGradient,
      ),
      child: Stack(
        children: [
          // Étoiles/disques décoratifs
          ...List.generate(20, (index) {
            final random = Random(index);
            return Positioned(
              left: random.nextDouble() * MediaQuery.of(context).size.width,
              top: random.nextDouble() * MediaQuery.of(context).size.height,
              child: Container(
                width: random.nextDouble() * 4 + 2,
                height: random.nextDouble() * 4 + 2,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
              ),
            );
          }),
          // Contenu
          child,
        ],
      ),
    );
  }
}


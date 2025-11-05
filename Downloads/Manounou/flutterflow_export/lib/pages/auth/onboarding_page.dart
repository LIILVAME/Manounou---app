import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/famplan_colors.dart';
import '../../core/widgets/onboarding_background.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OnboardingBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Header avec nom de l'app
                const Text(
                  'Manounou',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: FamPlanColors.white,
                  ),
                ),
                
                // Contenu principal
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Titre principal
                      const Text(
                        'Planifiez la vie\nde vos enfants\nensemble',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: FamPlanColors.white,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 48),
                      
                      // Bouton CTA
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => context.go('/dashboard'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: FamPlanColors.tealGreen,
                            foregroundColor: FamPlanColors.white,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'COMMENÇONS !',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Illustration en bas (placeholder - peut être remplacé par une vraie illustration)
                const Icon(
                  Icons.family_restroom,
                  size: 120,
                  color: FamPlanColors.white,
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

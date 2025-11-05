import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'famplan_card.dart';
import 'animated_avatar.dart';
import '../theme/famplan_colors.dart';
import '../services/children_service.dart';
import '../utils/date_helper.dart';

/// Carte d'enfant avec animations et swipe-to-delete
class AnimatedChildCard extends StatelessWidget {
  final Child child;
  final int index;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const AnimatedChildCard({
    super.key,
    required this.child,
    required this.index,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = FamPlanColors.getCardColor(index);
    
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 300),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: onDelete != null
          ? _buildSlidableCard(context, cardColor)
          : _buildSimpleCard(context, cardColor),
    );
  }

  Widget _buildSlidableCard(BuildContext context, Color cardColor) {
    return Slidable(
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.25,
        children: [
          SlidableAction(
            onPressed: (_) => _confirmDelete(context),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Supprimer',
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
          ),
        ],
      ),
      child: _buildCardContent(context, cardColor),
    );
  }

  Widget _buildSimpleCard(BuildContext context, Color cardColor) {
    return _buildCardContent(context, cardColor);
  }

  Widget _buildCardContent(BuildContext context, Color cardColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: FamPlanCard(
        backgroundColor: cardColor,
        onTap: () {
          // Animation de tap
          HapticFeedback.lightImpact();
          onTap();
        },
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Avatar avec animation de scale au tap
            Hero(
              tag: 'child_avatar_${child.id}',
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: FamPlanColors.white.withOpacity(0.5),
                    width: 3,
                  ),
                ),
                child: AnimatedAvatar(
                  firstName: child.firstName,
                  photoUrl: child.photoUrl,
                  gender: child.gender,
                  radius: 40,
                  enableScaleAnimation: true,
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Informations
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    child.firstName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: FamPlanColors.white,
                    ),
                  ),
                  if (child.age != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${child.age} ans',
                      style: TextStyle(
                        fontSize: 14,
                        color: FamPlanColors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                  if (child.birthDate != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      DateHelper.formatBirthDate(child.birthDate!),
                      style: TextStyle(
                        fontSize: 12,
                        color: FamPlanColors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: FamPlanColors.white,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer l\'enfant'),
        content: Text('Êtes-vous sûr de vouloir supprimer ${child.firstName} ?'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              HapticFeedback.mediumImpact();
              onDelete?.call();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}


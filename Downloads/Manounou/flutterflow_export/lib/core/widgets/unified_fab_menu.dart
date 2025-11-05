import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../theme/famplan_colors.dart';

/// FloatingActionButton avec menu contextuel pour choisir entre Horaire et Événement
class UnifiedFabMenu extends StatefulWidget {
  final String? childId;
  final String? childName;

  const UnifiedFabMenu({
    super.key,
    this.childId,
    this.childName,
  });

  @override
  State<UnifiedFabMenu> createState() => _UnifiedFabMenuState();
}

class _UnifiedFabMenuState extends State<UnifiedFabMenu>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.125).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
        HapticFeedback.mediumImpact();
      } else {
        _controller.reverse();
        HapticFeedback.lightImpact();
      }
    });
  }

  void _closeMenu() {
    if (_isExpanded) {
      setState(() {
        _isExpanded = false;
        _controller.reverse();
      });
    }
  }

  void _handleAddSchedule() {
    _closeMenu();
    HapticFeedback.mediumImpact();
    // Naviguer vers la page de création de planning
    if (widget.childId != null) {
      // Si un enfant est sélectionné, aller directement à la sélection du type
      context.go('/children/${widget.childId}/schedules/type');
    } else {
      // Sinon, aller à la liste des enfants pour sélectionner
      context.go('/children');
    }
  }

  void _handleAddEvent() {
    _closeMenu();
    HapticFeedback.mediumImpact();
    // Naviguer vers la page de création d'événement
    context.go('/events/new');
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Menu contextuel (options)
        if (_isExpanded) ...[
          // Backdrop
          Positioned.fill(
            child: GestureDetector(
              onTap: _closeMenu,
              child: Container(
                color: Colors.black.withValues(alpha: 0.3),
              ),
            ),
          ),
          // Option "Horaire"
          Positioned(
            bottom: 80,
            right: 16,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: _buildMenuOption(
                icon: Icons.schedule,
                label: 'Horaire récurrent',
                color: FamPlanColors.tealGreen,
                onTap: _handleAddSchedule,
              ),
            ),
          ),
          // Option "Événement"
          Positioned(
            bottom: 150,
            right: 16,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: _buildMenuOption(
                icon: Icons.event,
                label: 'Événement ponctuel',
                color: FamPlanColors.orange,
                onTap: _handleAddEvent,
              ),
            ),
          ),
        ],
        // Bouton principal
        Positioned(
          bottom: 16,
          right: 16,
          child: RotationTransition(
            turns: _rotationAnimation,
            child: FloatingActionButton(
              onPressed: _toggleMenu,
              backgroundColor: FamPlanColors.tealGreen,
              foregroundColor: FamPlanColors.white,
              child: Icon(
                _isExpanded ? Icons.close : Icons.add,
                size: 28,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: FamPlanColors.textDark,
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}


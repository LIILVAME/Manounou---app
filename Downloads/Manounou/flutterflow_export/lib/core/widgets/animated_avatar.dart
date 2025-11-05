import 'package:flutter/material.dart';
import 'child_avatar.dart';

/// Avatar avec animations de fade et scale
class AnimatedAvatar extends StatefulWidget {
  final String firstName;
  final String? photoUrl;
  final String? gender;
  final double radius;
  final Color? backgroundColor;
  final Color? textColor;
  final Duration fadeDuration;
  final bool enableScaleAnimation;

  const AnimatedAvatar({
    super.key,
    required this.firstName,
    this.photoUrl,
    this.gender,
    this.radius = 30,
    this.backgroundColor,
    this.textColor,
    this.fadeDuration = const Duration(milliseconds: 300),
    this.enableScaleAnimation = true,
  });

  @override
  State<AnimatedAvatar> createState() => _AnimatedAvatarState();
}

class _AnimatedAvatarState extends State<AnimatedAvatar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.fadeDuration,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: widget.enableScaleAnimation ? 0.8 : 1.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: ChildAvatar(
          firstName: widget.firstName,
          photoUrl: widget.photoUrl,
          gender: widget.gender,
          radius: widget.radius,
          backgroundColor: widget.backgroundColor,
          textColor: widget.textColor,
        ),
      ),
    );
  }
}


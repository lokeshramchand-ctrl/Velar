
// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';

class AnimationControllerPage extends StatefulWidget {
  final Function(Animation<Offset>) onAnimationCreated;
  final Function(Animation<double>) onFadeAnimationCreated;

  const AnimationControllerPage({super.key, required this.onAnimationCreated, required this.onFadeAnimationCreated, required Center child});

  @override
  _AnimationControllerPageState createState() => _AnimationControllerPageState();
}

class _AnimationControllerPageState extends State<AnimationControllerPage> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    // Start animations
    _fadeController.forward();
    _slideController.forward();

    widget.onAnimationCreated(_slideAnimation);
    widget.onFadeAnimationCreated(_fadeAnimation);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Container(
              width: 200,
              height: 200,
              color: Colors.blue,
            ),
          ),
        ),
      ),
    );
  }
}

// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:monarch/other_pages/colors.dart';

class TransactionButtons extends StatelessWidget {
  final Animation<double> scaleAnimation;
  final VoidCallback onEmailPressed;
  final VoidCallback onVoicePressed;

  const TransactionButtons({
    super.key,
    required this.scaleAnimation,
    required this.onEmailPressed,
    required this.onVoicePressed,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: scaleAnimation.value,
          child: Row(
            children: [
              _buildButton(
                icon: Icons.mail_outline,
                onPressed: onEmailPressed,
              ),
              const SizedBox(width: 12),
              _buildButton(
                icon: Icons.mic_outlined,
                onPressed: onVoicePressed,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildButton({required IconData icon, required VoidCallback onPressed}) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: accentColor.withOpacity(0.08),
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onPressed,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              color: accentColor,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }
}

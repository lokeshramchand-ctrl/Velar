// ignore_for_file: use_super_parameters, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monarch/main_pages/HomePage/Components/Home/transaction_button.dart';
import 'package:monarch/other_pages/colors.dart';

class GreetingHeader extends StatelessWidget {
  final String greetingText;
  final Animation<double> scaleAnimation;
  final VoidCallback onEmailPressed;
  final VoidCallback onVoicePressed;
  final VoidCallback onManualPressed;

  const GreetingHeader({
    Key? key,
    required this.greetingText,
    required this.scaleAnimation,
    required this.onEmailPressed,
    required this.onVoicePressed,
    required this.onManualPressed,
  }) : super(key: key);

  String _getFormattedDate() {
    final now = DateTime.now();
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${weekdays[now.weekday - 1]}, ${now.day} ${months[now.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date at the top
          Text(
            _getFormattedDate(),
            style: GoogleFonts.inter(
              color: accentColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 26),

          // Greeting below the date
          AnimatedBuilder(
            animation: scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: scaleAnimation.value,
                alignment: Alignment.centerLeft,
                child: Text(
                  greetingText,
                  style: GoogleFonts.inter(
                    color: primaryColor,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                    letterSpacing: -0.5,
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 36),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TransactionButtons(
                scaleAnimation: scaleAnimation,
                onManualPressed: onManualPressed,
                onEmailPressed: onEmailPressed,
                onVoicePressed: onVoicePressed,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ignore_for_file: use_super_parameters, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monarch/main_pages/HomePage/transaction_button.dart';
import 'package:monarch/other_pages/colors.dart';

class GreetingHeader extends StatelessWidget {
  final String greetingText;
  final Animation<double> scaleAnimation;
  final VoidCallback onEmailPressed;
  final VoidCallback onVoicePressed;

  const GreetingHeader({
    Key? key,
    required this.greetingText,
    required this.scaleAnimation,
    required this.onEmailPressed,
    required this.onVoicePressed,
  }) : super(key: key);

  String _getFormattedDate() {
    final now = DateTime.now();
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];

    return '${weekdays[now.weekday - 1]}, ${now.day} ${months[now.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 28),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: AnimatedBuilder(
              animation: scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: scaleAnimation.value,
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '$greetingText ',
                            style: GoogleFonts.inter(
                              color: primaryColor,
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              height: 1.1,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: accentColor.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: accentColor.withOpacity(0.15),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          _getFormattedDate(),
                          style: GoogleFonts.inter(
                            color: accentColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 16),
          TransactionButtons(
            scaleAnimation: scaleAnimation,
            onEmailPressed: onEmailPressed,
            onVoicePressed: onVoicePressed,
          ),
        ],
      ),
    );
  }
}

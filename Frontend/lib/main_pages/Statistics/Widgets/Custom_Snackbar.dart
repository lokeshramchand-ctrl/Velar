// ignore_for_file: file_names, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../other_pages/reponsive.dart';

class CustomSnackBar {
  static void show(
    BuildContext context, {
    required String message,
    required IconData icon,
    required Color backgroundColor,
    required Color iconColor,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: EdgeInsets.symmetric(vertical: context.responsiveHeight(4)),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(context.responsiveWidth(8)),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(
                    context.responsiveWidth(8),
                  ),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: context.responsiveText(20),
                ),
              ),
              SizedBox(width: context.responsiveWidth(12)),
              Expanded(
                child: Text(
                  message,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    fontSize: context.responsiveText(14),
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(context.responsiveWidth(12)),
        ),
        margin: EdgeInsets.all(context.responsiveWidth(16)),
        duration: duration,
        elevation: 8,
      ),
    );
  }
}

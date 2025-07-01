// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monarch/utils/responsive_utils.dart';

void showCustomSnackBar({
    required BuildContext context,
    required String message,
    required IconData icon,
    required Color backgroundColor,
    required Color iconColor,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: EdgeInsets.symmetric(vertical: ResponsiveUtils.responsiveHeight(4, context)),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(ResponsiveUtils.responsiveWidth(8, context)),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(ResponsiveUtils.responsiveWidth(8, context)),
                ),
                child: Icon(icon, color: iconColor, size: ResponsiveUtils.responsiveText(20, context)),
              ),
              SizedBox(width: ResponsiveUtils.responsiveWidth(12, context)),
              Expanded(
                child: Text(
                  message,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    fontSize: ResponsiveUtils.responsiveText(14, context),
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
          borderRadius: BorderRadius.circular(ResponsiveUtils.responsiveWidth(12, context)),
        ),
        margin: EdgeInsets.all(ResponsiveUtils.responsiveWidth(16, context)),
        duration: duration,
        elevation: 8,
      ),
    );
  }



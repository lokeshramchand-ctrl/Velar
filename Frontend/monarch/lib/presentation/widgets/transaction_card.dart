// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monarch/data/models/transcation.dart';
import 'package:monarch/utils/overall_colors.dart';
import 'package:monarch/utils/responsive_utils.dart';

class TransactionCard extends StatelessWidget {
  final Transaction tx;
final List<String> categories = [
    'Food',
    'Shopping',
    'Bills',
    'Travel',
    'Entertainment',
    'Other',
  ];
   TransactionCard({super.key, required this.tx});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.responsiveWidth(24 , context),
        vertical: ResponsiveUtils.responsiveHeight(8, context),
      ),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(ResponsiveUtils.responsiveWidth(20, context)),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.04),
            blurRadius: ResponsiveUtils.responsiveWidth(20, context),
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: ResponsiveUtils.responsiveWidth(20, context),
          vertical: ResponsiveUtils.responsiveHeight(8, context),
        ),
        leading: Container(
          width: ResponsiveUtils.responsiveWidth(48, context),
          height: ResponsiveUtils.responsiveWidth(48, context),
          decoration: BoxDecoration(
            color: _getCategoryColor(tx.category),
            borderRadius: BorderRadius.circular(ResponsiveUtils.responsiveWidth(14, context)),
          ),
          child: Icon(
            _getCategoryIcon(tx.category),
            color: cardColor,
            size: ResponsiveUtils.responsiveText(24, context),
          ),
        ),
        title: Text(
          tx.description,
          style: GoogleFonts.inter(
            color: primaryColor,
            fontWeight: FontWeight.w600,
            fontSize: ResponsiveUtils.responsiveText(16, context),
          ),
        ),
        subtitle: Padding(
          padding: EdgeInsets.only(top: ResponsiveUtils.responsiveHeight(4, context)),
          child: Text(
            '${tx.category.toUpperCase()} • ${_formatTime(tx.date)}',
            style: GoogleFonts.inter(
              color: textSecondary,
              fontSize: ResponsiveUtils.responsiveText(13, context),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        trailing: Text(
          '₹${tx.amount.toStringAsFixed(1)}',
          style: GoogleFonts.inter(
            color: primaryColor,
            fontWeight: FontWeight.w700,
            fontSize: ResponsiveUtils.responsiveText(17, context),
          ),
        ),
      ),
    );
  }
  Color _getCategoryColor(String category) {
    final colors = [
      const Color(0xFF6C5CE7),
      const Color(0xFFE17055),
      const Color(0xFF00B894),
      const Color(0xFF0984E3),
      const Color(0xFFE84393),
      const Color(0xFFFD79A8),
      const Color(0xFF6C5CE7),
    ];
    return colors[categories.indexOf(category) % colors.length];
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Food':
        return Icons.restaurant_rounded;
      case 'Shopping':
        return Icons.shopping_bag_rounded;
      case 'Bills':
        return Icons.receipt_rounded;
      case 'Travel':
        return Icons.flight_rounded;
      case 'Entertainment':
        return Icons.movie_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inDays == 0) {
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else {
      return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}';
    }
  }

}

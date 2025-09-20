// ignore_for_file: file_names, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monarch/main_pages/Statistics/statistics.dart';
import 'package:monarch/main_pages/Statistics/Widgets/category/category_icons.dart';
import 'package:monarch/other_pages/colors.dart';
import 'package:monarch/main_pages/Statistics/Widgets/category/category_colors.dart';
import '../../../other_pages/reponsive.dart';

class TransactionCard extends StatelessWidget {
  final Transaction tx;
  final List<String> categories;

  const TransactionCard({
    super.key,
    required this.tx,
    required this.categories,
  });

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inDays == 0) {
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else {
      return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: context.responsiveWidth(24),
        vertical: context.responsiveHeight(6),
      ),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(context.responsiveWidth(20)),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.04),
            blurRadius: context.responsiveWidth(20),
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: context.responsiveWidth(20),
          vertical: context.responsiveHeight(8),
        ),
        leading: Container(
          width: context.responsiveWidth(48),
          height: context.responsiveWidth(48),
          decoration: BoxDecoration(
            color: getCategoryColor(tx.category),
            borderRadius: BorderRadius.circular(context.responsiveWidth(14)),
          ),
          child: Icon(
            getCategoryIcon(tx.category),
            color: cardColor,
            size: context.responsiveText(24),
          ),
        ),
        title: Text(
          tx.description,
          style: GoogleFonts.inter(
            color: primaryColor,
            fontWeight: FontWeight.w600,
            fontSize: context.responsiveText(16),
          ),
        ),
        subtitle: Padding(
          padding: EdgeInsets.only(top: context.responsiveHeight(4)),
          child: Text(
            '${tx.category.toUpperCase()} • ${_formatTime(tx.date)}',
            style: GoogleFonts.inter(
              color: textSecondary,
              fontSize: context.responsiveText(13),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        trailing: Text(
          '₹${tx.amount.toStringAsFixed(1)}',
          style: GoogleFonts.inter(
            color: primaryColor,
            fontWeight: FontWeight.w700,
            fontSize: context.responsiveText(17),
          ),
        ),
      ),
    );
  }
}

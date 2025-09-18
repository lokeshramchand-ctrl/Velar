// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monarch/main_pages/Statistics/Widgets/buildTransactionCard.dart';
import 'package:monarch/main_pages/Statistics/Widgets/category/category_colors.dart';
import 'package:monarch/other_pages/colors.dart';

import '../../../other_pages/reponsive.dart';

class CategoryRow extends StatelessWidget {
  final String category;
  final double amount;
  final double total;

  const CategoryRow({
    super.key,
    required this.category,
    required this.amount,
    required this.total,
  });

  double _calculatePercentage() {
    return total > 0 ? (amount / total) : 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final percentage = _calculatePercentage();

    return Padding(
      padding: EdgeInsets.only(bottom: context.responsiveHeight(12)),
      child: Row(
        children: [
          Container(
            width: context.responsiveWidth(8),
            height: context.responsiveWidth(8),
            decoration: BoxDecoration(
              color: getCategoryColor(category), // from utils
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: context.responsiveWidth(12)),
          Expanded(
            child: Text(
              category,
              style: GoogleFonts.inter(
                fontSize: context.responsiveText(14),
                fontWeight: FontWeight.w500,
                color: primaryColor,
              ),
            ),
          ),
          Text(
            '${(percentage * 100).toInt()}%',
            style: GoogleFonts.inter(
              fontSize: context.responsiveText(14),
              fontWeight: FontWeight.w600,
              color: textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

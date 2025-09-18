import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monarch/other_pages/colors.dart';
import '../../../other_pages/reponsive.dart';
import 'category_row.dart';

class CategoryBreakdown extends StatelessWidget {
  final Map<String, double> totalAmountPerCategory;

  const CategoryBreakdown({super.key, required this.totalAmountPerCategory});

  @override
  Widget build(BuildContext context) {
    final sortedCategories =
        totalAmountPerCategory.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
    final topCategories = sortedCategories.take(3).toList();

    // Calculate the overall total for percentage calculation
    final total = totalAmountPerCategory.values.fold<double>(
      0,
      (sum, val) => sum + val,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TOP CATEGORIES',
          style: GoogleFonts.inter(
            fontSize: context.responsiveText(11),
            fontWeight: FontWeight.w600,
            color: textSecondary,
            letterSpacing: 1,
          ),
        ),
        SizedBox(height: context.responsiveHeight(16)),

        // Build category rows
        ...topCategories.map(
          (entry) => CategoryRow(
            category: entry.key,
            amount: entry.value,
            total: total,
          ),
        ),
      ],
    );
  }
}

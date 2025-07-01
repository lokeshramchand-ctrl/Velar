import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monarch/presentation/widgets/category_row.dart';
import 'package:monarch/utils/overall_colors.dart';
import 'package:monarch/utils/responsive_utils.dart';

class CategoryBreakdown extends StatelessWidget {
  final Map<String, double> totalAmountPerCategory;

  const CategoryBreakdown({super.key, required this.totalAmountPerCategory});

  @override
  Widget build(BuildContext context) {
    final sortedCategories =
        totalAmountPerCategory.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
    final topCategories = sortedCategories.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TOP CATEGORIES',
          style: GoogleFonts.inter(
            fontSize: ResponsiveUtils.responsiveText(11 , context),
            fontWeight: FontWeight.w600,
            color: textSecondary,
            letterSpacing: 1,
          ),
        ),
        SizedBox(height: ResponsiveUtils.responsiveHeight(16 , context)),
        ...topCategories.map(
          (entry) => CategoryRow(category: entry.key, amount: entry.value),
        ),
      ],
    );
  }
}

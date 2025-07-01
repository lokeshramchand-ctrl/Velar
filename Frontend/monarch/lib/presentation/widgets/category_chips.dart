import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monarch/utils/responsive_utils.dart';
import 'package:monarch/utils/overall_colors.dart';

import '../../data/services/fetch_transcation.dart';


class CategoryChips extends StatefulWidget {
  const CategoryChips({super.key});
  @override
  State<CategoryChips> createState() => _CategoryChipsState();
}

class _CategoryChipsState extends State<CategoryChips> {
  final List<String> categories = [
    'Food',
    'Shopping',
    'Bills',
    'Travel',
    'Entertainment',
    'Other',
  ];
  String selectedCategory = 'All';
  @override
  Widget build(BuildContext context) {
    return Container(
      height: ResponsiveUtils.responsiveHeight(50, context),
      margin: EdgeInsets.only(bottom: ResponsiveUtils.responsiveHeight(16, context)),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: ResponsiveUtils.responsiveWidth(20, context)),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final bool isSelected = cat == selectedCategory;
          return Container(
            margin: EdgeInsets.only(right: ResponsiveUtils.responsiveWidth(12, context)),
            child: FilterChip(
              label: Text(cat),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() => selectedCategory = cat);
                    TransactionApi.fetchTransactions(category: cat, context: context);
                }
              },
              backgroundColor: surfaceColor,
              selectedColor: primaryColor,
              checkmarkColor: cardColor,
              labelStyle: GoogleFonts.inter(
                color: isSelected ? cardColor : textSecondary,
                fontWeight: FontWeight.w500,
                fontSize: ResponsiveUtils.responsiveText(14, context),
              ),
              side: BorderSide.none,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(ResponsiveUtils.responsiveWidth(20, context)),
              ),
            ),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../other_pages/colors.dart';
import '../../../../other_pages/reponsive.dart';

class CategoryChips extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final Function(String) onCategorySelected;

  const CategoryChips({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: context.responsiveHeight(50),
      margin: EdgeInsets.only(bottom: context.responsiveHeight(16)),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: context.responsiveWidth(20)),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final bool isSelected = cat == selectedCategory;

          return Container(
            margin: EdgeInsets.only(right: context.responsiveWidth(12)),
            child: FilterChip(
              label: Text(cat),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  onCategorySelected(cat); // ✅ notify parent
                }
              },
              backgroundColor: surfaceColor,
              selectedColor: primaryColor,
              checkmarkColor: cardColor,
              labelStyle: GoogleFonts.inter(
                color: isSelected ? cardColor : textSecondary,
                fontWeight: FontWeight.w500,
                fontSize: context.responsiveText(14),
              ),
              side: BorderSide.none,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  context.responsiveWidth(20),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

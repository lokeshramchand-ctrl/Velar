import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monarch/utils/overall_colors.dart';
import 'package:monarch/data/models/transcation.dart';
import 'package:monarch/utils/category_colors.dart';
import 'package:monarch/utils/responsive_utils.dart';

class CategoryRow extends StatelessWidget {
  final String category;
  final double amount;
  final List<Transaction> transactions = []; 

   CategoryRow({super.key, required this.category, required this.amount});
  double get total => transactions.fold<double>(0, (sum, tx) => sum + tx.amount);
  double get percentage => total > 0 ? (amount / total) : 0.0;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: ResponsiveUtils.responsiveHeight(12 , context)),
      child: Row(
        children: [
          Container(
              width: ResponsiveUtils.responsiveWidth(8, context),
              height: ResponsiveUtils.responsiveWidth(8, context),
              decoration: BoxDecoration(
                color: CategoryUtils.getCategoryColor(category, [category]),
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: ResponsiveUtils.responsiveWidth(12, context)),
            Expanded(
              child: Text(
                category,
                style: GoogleFonts.inter(
                  fontSize: ResponsiveUtils.responsiveText(14, context),
                  fontWeight: FontWeight.w500,
                  color: primaryColor,
                ),
              ),
            ),
            Text(
              '${(percentage * 100).toInt()}%',
              style: GoogleFonts.inter(
                fontSize: ResponsiveUtils.responsiveText(14, context),
                fontWeight: FontWeight.w600,
                color: textSecondary,
              ),
            ),
          ],
        ),
      );
    }
  }


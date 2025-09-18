// ignore_for_file: sized_box_for_whitespace, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monarch/other_pages/colors.dart';
import 'package:monarch/other_pages/reponsive.dart';

import 'category_breakdown.dart';

class TotalSpentCard extends StatelessWidget {
  final double budget;
  final List<dynamic>
  transactions; // Replace `dynamic` with your `Transaction` model
  final Animation<Offset> slideAnimation;
  final Animation<double> fadeAnimation;
  final Map<String, double> totalAmountPerCategory;

  const TotalSpentCard({
    super.key,
    required this.budget,
    required this.transactions,
    required this.slideAnimation,
    required this.fadeAnimation,
    required this.totalAmountPerCategory,
  });

  @override
  Widget build(BuildContext context) {
    final totalSpent = transactions.fold<double>(
      0,
      (sum, tx) => sum + tx.amount,
    );
    final progress = totalSpent / budget;

    return SlideTransition(
      position: slideAnimation,
      child: FadeTransition(
        opacity: fadeAnimation,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: context.responsiveWidth(24)),
          padding: EdgeInsets.all(context.responsiveWidth(32)),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(context.responsiveWidth(28)),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.06),
                blurRadius: context.responsiveWidth(30),
                offset: const Offset(0, 8),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TOTAL SPENT',
                style: GoogleFonts.inter(
                  fontSize: context.responsiveText(13),
                  fontWeight: FontWeight.w500,
                  color: textSecondary,
                  letterSpacing: 1.2,
                ),
              ),
              SizedBox(height: context.responsiveHeight(12)),
              Text(
                '₹${totalSpent.toStringAsFixed(1)}',
                style: GoogleFonts.inter(
                  fontSize: context.responsiveText(42),
                  fontWeight: FontWeight.w700,
                  color: primaryColor,
                  height: 1.1,
                ),
              ),
              SizedBox(height: context.responsiveHeight(32)),
              Center(
                child: Container(
                  width: context.responsiveWidth(160),
                  height: context.responsiveWidth(160),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: context.responsiveWidth(160),
                        height: context.responsiveWidth(160),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: surfaceColor,
                            width: context.responsiveWidth(8),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: context.responsiveWidth(160),
                        height: context.responsiveWidth(160),
                        child: CircularProgressIndicator(
                          value: progress > 1 ? 1 : progress,
                          strokeWidth: context.responsiveWidth(8),
                          backgroundColor: Colors.transparent,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            progress > 0.8
                                ? const Color(0xFFE74C3C)
                                : progress > 0.6
                                ? const Color(0xFFF39C12)
                                : accentColor,
                          ),
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${(progress * 100).toInt()}%',
                            style: GoogleFonts.inter(
                              fontSize: context.responsiveText(24),
                              fontWeight: FontWeight.w700,
                              color: primaryColor,
                            ),
                          ),
                          SizedBox(height: context.responsiveHeight(4)),
                          Text(
                            'of ₹${budget.toInt()}',
                            style: GoogleFonts.inter(
                              fontSize: context.responsiveText(12),
                              fontWeight: FontWeight.w500,
                              color: textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: context.responsiveHeight(24)),
              if (totalAmountPerCategory.isNotEmpty)
                CategoryBreakdown(
                  totalAmountPerCategory: totalAmountPerCategory,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

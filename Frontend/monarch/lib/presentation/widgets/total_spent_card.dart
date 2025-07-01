// ignore_for_file: deprecated_member_use, sized_box_for_whitespace, no_leading_underscores_for_local_identifiers, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monarch/data/models/transcation.dart';
import 'package:monarch/data/services/fetch_transcation.dart';
import 'package:monarch/presentation/widgets/header.dart';
import 'package:monarch/utils/overall_colors.dart';
import 'package:monarch/utils/responsive_utils.dart';
import 'package:monarch/presentation/widgets/category_breakdown.dart';

class TotalSpentCard extends StatefulWidget {
  final List<Transaction> transactions;
  final double budget;
  final Map<String, double> totalAmountPerCategory;

  const TotalSpentCard({
    super.key,
    required this.transactions,
    required this.budget,
    required this.totalAmountPerCategory,
  });

  @override
  _TotalSpentCardState createState() => _TotalSpentCardState();
}

class _TotalSpentCardState extends State<TotalSpentCard> with TickerProviderStateMixin {
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    TransactionApi.fetchTransactions(context: context);
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final totalSpent = widget.transactions.fold<double>(
      0,
      (sum, tx) => sum + tx.amount,
    );
    final progress = totalSpent / widget.budget;

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: ResponsiveUtils.responsiveWidth(24 , context)),
          padding: EdgeInsets.all(ResponsiveUtils.responsiveWidth(32 , context)),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(ResponsiveUtils.responsiveWidth(28 , context)),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.06),
                blurRadius: ResponsiveUtils.responsiveWidth(30 , context),
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
                  fontSize: ResponsiveUtils.responsiveText(13 , context),
                  fontWeight: FontWeight.w500,
                  color: textSecondary,
                  letterSpacing: 1.2,
                ),
              ),
              SizedBox(height: ResponsiveUtils.responsiveHeight(12 , context)),
              Text(
                '₹${totalSpent.toStringAsFixed(1)}',
                style: GoogleFonts.inter(
                  fontSize: ResponsiveUtils.responsiveText(42 , context),
                  fontWeight: FontWeight.w700,
                  color: primaryColor,
                  height: 1.1,
                ),
              ),
              SizedBox(height: ResponsiveUtils.responsiveHeight(32 , context)),
              Center(
                child: Container(
                  width: ResponsiveUtils.responsiveWidth(160 , context),
                  height: ResponsiveUtils.responsiveWidth(160 , context),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: ResponsiveUtils.responsiveWidth(160 , context),
                        height: ResponsiveUtils.responsiveWidth(160 , context),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: surfaceColor,
                            width: ResponsiveUtils.responsiveWidth(8 , context),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: ResponsiveUtils.responsiveWidth(160 , context),
                        height: ResponsiveUtils.responsiveWidth(160 , context),
                        child: CircularProgressIndicator(
                          value: progress > 1 ? 1 : progress,
                          strokeWidth: ResponsiveUtils.responsiveWidth(8 , context),
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
                              fontSize: ResponsiveUtils.responsiveText(24 , context),
                              fontWeight: FontWeight.w700,
                              color: primaryColor,
                            ),
                          ),
                          SizedBox(height: ResponsiveUtils.responsiveHeight(4 , context)),
                          Text(
                            'of ₹${budget.toInt()}',
                            style: GoogleFonts.inter(
                              fontSize: ResponsiveUtils.responsiveText(12 , context),
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
              SizedBox(height: ResponsiveUtils.responsiveHeight(24 , context)),
             if (widget.totalAmountPerCategory.isNotEmpty)
  CategoryBreakdown(totalAmountPerCategory: widget.totalAmountPerCategory),
            ],
          ),
        ),
      ),
    );
  }
}

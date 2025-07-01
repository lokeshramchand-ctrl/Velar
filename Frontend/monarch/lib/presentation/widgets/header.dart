// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monarch/add_expense.dart';
import 'package:monarch/budget_manager.dart';
import 'package:monarch/utils/overall_colors.dart';
import 'package:monarch/update_budget.dart';
import 'package:monarch/utils/responsive_utils.dart';
import 'package:monarch/utils/custom_snack_bar.dart';
class Header extends StatefulWidget {
  const Header({super.key});

  @override
  State<Header> createState() => _HeaderState();
}
class _HeaderState extends State<Header> {
  double budget = 10000.0 > 0 ? 10000.0 : 0.0;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        ResponsiveUtils.responsiveWidth(24, context),
        ResponsiveUtils.responsiveHeight(60, context),
        ResponsiveUtils.responsiveWidth(24, context),
        ResponsiveUtils.responsiveHeight(20, context),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: ResponsiveUtils.responsiveWidth(44, context),
            height: ResponsiveUtils.responsiveWidth(44, context),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(
                ResponsiveUtils.responsiveWidth(22, context),
              ),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.08),
                  blurRadius: ResponsiveUtils.responsiveWidth(20, context),
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(
                ResponsiveUtils.responsiveWidth(22, context),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(
                  ResponsiveUtils.responsiveWidth(22, context),
                ),
                onTap:
                    () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddExpenseScreen(),
                      ),
                    ),
                child: Icon(
                  Icons.arrow_back_ios_rounded,
                  color: primaryColor,
                  size: ResponsiveUtils.responsiveText(20, context),
                ),
              ),
            ),
          ),
          Container(
            width: ResponsiveUtils.responsiveWidth(44, context),
            height: ResponsiveUtils.responsiveWidth(44, context),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(
                ResponsiveUtils.responsiveWidth(22, context),
              ),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.08),
                  blurRadius: ResponsiveUtils.responsiveWidth(20, context),
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: PopupMenuButton<String>(
              onSelected: (String value) async {
                final updatedBudget = await Navigator.push<double>(
                  context,
                  MaterialPageRoute(builder: (context) => const UpdateBudget()),
                );
                if (updatedBudget != null) {
                  setState(() => budget = updatedBudget);
                  await BudgetManager.setBudget(updatedBudget);
                  showCustomSnackBar(
                    context: context,
                    message: 'Budget updated to ₹${updatedBudget.toInt()}',
                    icon: Icons.check_circle_rounded,
                    backgroundColor: const Color(0xFF00B894),
                    iconColor: Colors.white,
                  );
                }
              },
              itemBuilder:
                  (BuildContext context) => [
                    PopupMenuItem<String>(
                      value: 'update_budget',
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: ResponsiveUtils.responsiveHeight(8,context),
                          horizontal: ResponsiveUtils.responsiveWidth(12,context),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.edit_rounded,
                              color: primaryColor,
                              size: ResponsiveUtils.responsiveText(18, context),
                            ),
                            SizedBox(width: ResponsiveUtils.responsiveWidth(12, context)),
                            Text(
                              'Update Budget',
                              style: GoogleFonts.inter(
                                color: primaryColor,
                                fontSize: ResponsiveUtils.responsiveText(14, context),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'Update Income',
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: ResponsiveUtils.responsiveHeight(8, context),
                          horizontal: ResponsiveUtils.responsiveWidth(12, context),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.visibility_rounded,
                              color: primaryColor,
                              size: ResponsiveUtils.responsiveText(18, context),
                            ),
                            SizedBox(width: ResponsiveUtils.responsiveWidth(12, context)),
                            Text(
                              'View Budget',
                              style: GoogleFonts.inter(
                                color: primaryColor,
                                fontSize: ResponsiveUtils.responsiveText(14, context),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
              offset: Offset(0, ResponsiveUtils.responsiveHeight(50, context)),
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(ResponsiveUtils.responsiveWidth(16, context)),
              ),
              color: cardColor,
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(ResponsiveUtils.responsiveWidth(22, context)),
                child: InkWell(
                  borderRadius: BorderRadius.circular(ResponsiveUtils.responsiveWidth(22, context)),
                  child: Container(
                    padding: EdgeInsets.all(ResponsiveUtils.responsiveWidth(10, context)),
                    child: Icon(
                      Icons.more_horiz_rounded,
                      color: primaryColor,
                      size: ResponsiveUtils.responsiveText(24, context),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
  var budget = 10000.0 > 0 ? 10000.0 : 0.0;

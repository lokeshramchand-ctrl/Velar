// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monarch/colors.dart';
  final double totalBalance = 5847.32;
  final double monthlyIncome = 8500.00;
  final double monthlyExpenses = 2652.68;


class BalanceCardPage extends StatelessWidget {
  const BalanceCardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [accentColor, accentColor.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Balance',
                style: GoogleFonts.inter(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(
                Icons.visibility_outlined,
                color: Colors.white.withOpacity(0.9),
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '\$${totalBalance.toStringAsFixed(2)}',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.w700,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Income',
                      style: GoogleFonts.inter(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${monthlyIncome.toStringAsFixed(0)}',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withOpacity(0.3),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Expenses',
                        style: GoogleFonts.inter(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${monthlyExpenses.toStringAsFixed(0)}',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ignore_for_file: sort_child_properties_last, use_build_context_synchronously, deprecated_member_use, unnecessary_import, unused_local_variable, unused_import, sized_box_for_whitespace

import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:monarch/add_expense.dart';
import 'package:monarch/data/models/transcation.dart';
import 'package:monarch/data/services/fetch_transcation.dart';
import 'package:monarch/presentation/widgets/category_breakdown.dart';
import 'package:monarch/presentation/widgets/category_chips.dart';
import 'package:monarch/presentation/widgets/header.dart';
import 'package:monarch/presentation/widgets/total_spent_card.dart';
import 'package:monarch/presentation/widgets/transaction_card.dart';
import 'package:monarch/update_budget.dart';
import 'package:monarch/budget_manager.dart';
import 'package:monarch/homepage.dart';
import 'package:monarch/navbar.dart';
import 'package:monarch/utils/custom_snack_bar.dart';
import 'package:monarch/utils/overall_colors.dart';

// ...

class Statistics extends StatefulWidget {
  const Statistics({super.key});

  @override
  State<Statistics> createState() => StatisticsState();
}

class StatisticsState extends State<Statistics> with TickerProviderStateMixin {
  List<Transaction> transactions = [];
  bool isLoading = false;
  late AnimationController _animationController;
  Map<String, double> totalAmountPerCategory = {};

  Future<void> fetchTransactions({String category = 'All'}) async {
    setState(() => isLoading = true);
    try {
      final uri = Uri.parse('http://192.168.1.9:3000/api/transactions').replace(
        queryParameters: category == 'All' ? null : {'category': category},
      );
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> list = data['data'];
        final fetched = list.map((json) => Transaction.fromJson(json)).toList();
        final totals = <String, double>{};
        for (var tx in fetched) {
          totals[tx.category] = (totals[tx.category] ?? 0) + tx.amount;
        }
        setState(() {
          transactions = fetched;
          totalAmountPerCategory = totals;
        });
      } else {
        throw Exception('Failed to load transactions');
      }
    } catch (e) {
      showCustomSnackBar(
        context: context,
        message: 'Error fetching transactions',
        icon: Icons.data_exploration_rounded,
        backgroundColor: const Color(0xFFFF9F43),
        iconColor: Colors.white,
        duration: const Duration(seconds: 4),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  double responsiveWidth(double size) =>
      size * (MediaQuery.of(context).size.width / 375);
  double responsiveHeight(double size) =>
      size * (MediaQuery.of(context).size.height / 812);
  double responsiveText(double size) {
    final width = MediaQuery.of(context).size.width;
    if (width < 350) return size * 0.9;
    if (width > 600) return size * 1.2;
    return size;
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    fetchTransactions();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          Header(),
          TotalSpentCard(
            transactions: transactions,
            budget: budget,
            totalAmountPerCategory: totalAmountPerCategory,
          ),
          CategoryChips(),
          Expanded(
            child: isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                      strokeWidth: 2,
                    ),
                  )
                : transactions.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.analytics_outlined,
                              size: responsiveWidth(64),
                              color: textSecondary.withOpacity(0.5),
                            ),
                            SizedBox(height: responsiveHeight(16)),
                            Text(
                              'No transactions found',
                              style: GoogleFonts.inter(
                                color: textSecondary,
                                fontSize: responsiveText(16),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.only(
                          top: responsiveHeight(8),
                          bottom: responsiveHeight(120),
                        ),
                        itemCount: transactions.length,
                        itemBuilder: (context, index) => TransactionCard(tx: transactions[index]),
                      ),
          ),
        ],
      ),
      floatingActionButton: CustomNavBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        backgroundColor: backgroundColor,
        accentColor: accentColor,
        primaryColor: primaryColor,
        cardColor: cardColor,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }
}

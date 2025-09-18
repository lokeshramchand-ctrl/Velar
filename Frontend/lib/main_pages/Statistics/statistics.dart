// ignore_for_file: sort_child_properties_last, use_build_context_synchronously, deprecated_member_use, unnecessary_import, unused_local_variable, unused_import, sized_box_for_whitespace, avoid_print

import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:monarch/main_pages/Statistics/Widgets/buildTransactionCard.dart';
import 'package:monarch/main_pages/Statistics/Widgets/category_breakdown.dart';
import 'package:monarch/main_pages/Statistics/Widgets/category_row.dart';
import 'package:monarch/other_pages/colors.dart';
import 'package:monarch/main_pages/HomePage/Components/Manual/add_expense.dart';
import 'package:monarch/other_pages/enviroment.dart';
import 'package:monarch/main_pages/Statistics/Budget/update_budget.dart';
import 'package:monarch/main_pages/Statistics/Budget/budget_manager.dart';
import 'package:monarch/main_pages/HomePage/homepage.dart';
import 'package:monarch/main_pages/HomePage/Components/Home/navbar.dart';
import 'package:monarch/other_pages/reponsive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:monarch/main_pages/Statistics/Widgets/Custom_Snackbar.dart';

class Transaction {
  final String description;
  final double amount;
  final String category;
  final DateTime date;

  Transaction({
    required this.description,
    required this.amount,
    required this.category,
    required this.date,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      description: json['description'],
      amount: (json['amount'] as num).toDouble(),
      category: json['category'],
      date: DateTime.parse(json['date']),
    );
  }
}

class Statistics extends StatefulWidget {
  const Statistics({super.key});

  @override
  State<Statistics> createState() => StatisticsState();
}

class StatisticsState extends State<Statistics> with TickerProviderStateMixin {
  List<Transaction> transactions = [];
  bool isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  final List<String> categories = [
    'Food',
    'Shopping',
    'Bills',
    'Travel',
    'Entertainment',
    'Other',
  ];
  String selectedCategory = 'All';
  Map<String, double> totalAmountPerCategory = {};
  // Color Scheme

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
    fetchTransactions();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> fetchTransactions({String category = 'All'}) async {
    setState(() => isLoading = true);
    try {
      // 1. Get the saved userId from SharedPreferences or secure storage
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId == null) {
        throw Exception('User ID not found. Please log in again.');
      }

      // 2. Build query parameters
      final queryParams = {
        'userId': userId,
        if (category != 'All') 'category': category,
      };

      // 3. Build URI
      final uri = Uri.parse(
        '${Environment.baseUrl}/api/transactions',
      ).replace(queryParameters: queryParams);

      // 4. Send GET request
      final response = await http.get(uri);
      print('Request URL: $uri');
      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> list = data['data'] ?? [];
        final fetched = list.map((json) => Transaction.fromJson(json)).toList();

        // Calculate totals
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
      CustomSnackBar.show(
        context,
        message: 'Error fetching transactions: ${e.toString()}',
        icon: Icons.data_exploration_rounded,
        backgroundColor: const Color(0xFFFF9F43),
        iconColor: Colors.white,
        duration: const Duration(seconds: 4),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  var budget = 100000.0 > 0 ? 100000.0 : 0.0;
  Widget _buildTotalSpentCard() {
    final totalSpent = transactions.fold<double>(
      0,
      (sum, tx) => sum + tx.amount,
    );
    final progress = totalSpent / budget;

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
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

  Widget buildCategoryChips() {
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
                  setState(() => selectedCategory = cat);
                  fetchTransactions(category: cat);
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

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          // _buildHeader(),
          _buildTotalSpentCard(),
          buildCategoryChips(),
          Expanded(
            child:
                isLoading
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
                            size: context.responsiveWidth(64),
                            color: textSecondary.withOpacity(0.5),
                          ),
                          SizedBox(height: context.responsiveHeight(16)),
                          Text(
                            'No transactions found',
                            style: GoogleFonts.inter(
                              color: textSecondary,
                              fontSize: context.responsiveText(16),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      padding: EdgeInsets.only(
                        top: context.responsiveHeight(8),
                        bottom: context.responsiveHeight(120),
                      ),
                      itemCount: transactions.length,
                      itemBuilder:
                          (context, index) => TransactionCard(
                            tx: transactions[index],
                            categories: [],
                          ),
                    ),
          ),
        ],
      ),
      bottomNavigationBar: CustomNavBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        backgroundColor: backgroundColor,
        accentColor: accentColor,
        primaryColor: primaryColor,
        cardColor: cardColor,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerTop,
      ),
    );
  }
}

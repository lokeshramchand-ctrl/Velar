// ignore_for_file: sort_child_properties_last, use_build_context_synchronously, deprecated_member_use, unnecessary_import, unused_local_variable, unused_import, sized_box_for_whitespace

import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:monarch/add.dart';
import 'package:monarch/budget.dart';
import 'package:monarch/budget_manager.dart';
import 'package:monarch/homepage.dart';
import 'package:monarch/navbar.dart';

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
  var budget = 10000.0;
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
  final Color backgroundColor = const Color(0xFFF8F9FA);
  final Color primaryColor = const Color(0xFF2D3436);
  final Color accentColor = const Color(0xFF00B894);
  final Color cardColor = const Color(0xFFFFFFFF);
  final Color textSecondary = const Color(0xFF636E72);
  final Color surfaceColor = const Color(0xFFF1F2F6);

  // Responsive methods
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
      _showCustomSnackBar(
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

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        responsiveWidth(24),
        responsiveHeight(60),
        responsiveWidth(24),
        responsiveHeight(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: responsiveWidth(44),
            height: responsiveWidth(44),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(responsiveWidth(22)),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.08),
                  blurRadius: responsiveWidth(20),
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(responsiveWidth(22)),
              child: InkWell(
                borderRadius: BorderRadius.circular(responsiveWidth(22)),
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
                  size: responsiveText(20),
                ),
              ),
            ),
          ),
          Container(
            width: responsiveWidth(44),
            height: responsiveWidth(44),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(responsiveWidth(22)),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.08),
                  blurRadius: responsiveWidth(20),
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: PopupMenuButton<String>(
              onSelected: (String value) async {
                final updatedBudget = await Navigator.push<double>(
                  context,
                  MaterialPageRoute(builder: (context) => const BudgetScreen()),
                );
                if (updatedBudget != null) {
                  setState(() => budget = updatedBudget);
                  await BudgetManager.setBudget(updatedBudget);
                  _showCustomSnackBar(
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
                          vertical: responsiveHeight(8),
                          horizontal: responsiveWidth(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.edit_rounded,
                              color: primaryColor,
                              size: responsiveText(18),
                            ),
                            SizedBox(width: responsiveWidth(12)),
                            Text(
                              'Update Budget',
                              style: GoogleFonts.inter(
                                color: primaryColor,
                                fontSize: responsiveText(14),
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
                          vertical: responsiveHeight(8),
                          horizontal: responsiveWidth(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.visibility_rounded,
                              color: primaryColor,
                              size: responsiveText(18),
                            ),
                            SizedBox(width: responsiveWidth(12)),
                            Text(
                              'View Budget',
                              style: GoogleFonts.inter(
                                color: primaryColor,
                                fontSize: responsiveText(14),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
              offset: Offset(0, responsiveHeight(50)),
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(responsiveWidth(16)),
              ),
              color: cardColor,
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(responsiveWidth(22)),
                child: InkWell(
                  borderRadius: BorderRadius.circular(responsiveWidth(22)),
                  child: Container(
                    padding: EdgeInsets.all(responsiveWidth(10)),
                    child: Icon(
                      Icons.more_horiz_rounded,
                      color: primaryColor,
                      size: responsiveText(24),
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
          margin: EdgeInsets.symmetric(horizontal: responsiveWidth(24)),
          padding: EdgeInsets.all(responsiveWidth(32)),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(responsiveWidth(28)),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.06),
                blurRadius: responsiveWidth(30),
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
                  fontSize: responsiveText(13),
                  fontWeight: FontWeight.w500,
                  color: textSecondary,
                  letterSpacing: 1.2,
                ),
              ),
              SizedBox(height: responsiveHeight(12)),
              Text(
                '₹${totalSpent.toStringAsFixed(1)}',
                style: GoogleFonts.inter(
                  fontSize: responsiveText(42),
                  fontWeight: FontWeight.w700,
                  color: primaryColor,
                  height: 1.1,
                ),
              ),
              SizedBox(height: responsiveHeight(32)),
              Center(
                child: Container(
                  width: responsiveWidth(160),
                  height: responsiveWidth(160),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: responsiveWidth(160),
                        height: responsiveWidth(160),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: surfaceColor,
                            width: responsiveWidth(8),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: responsiveWidth(160),
                        height: responsiveWidth(160),
                        child: CircularProgressIndicator(
                          value: progress > 1 ? 1 : progress,
                          strokeWidth: responsiveWidth(8),
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
                              fontSize: responsiveText(24),
                              fontWeight: FontWeight.w700,
                              color: primaryColor,
                            ),
                          ),
                          SizedBox(height: responsiveHeight(4)),
                          Text(
                            'of ₹${budget.toInt()}',
                            style: GoogleFonts.inter(
                              fontSize: responsiveText(12),
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
              SizedBox(height: responsiveHeight(24)),
              if (totalAmountPerCategory.isNotEmpty) _buildCategoryBreakdown(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryBreakdown() {
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
            fontSize: responsiveText(11),
            fontWeight: FontWeight.w600,
            color: textSecondary,
            letterSpacing: 1,
          ),
        ),
        SizedBox(height: responsiveHeight(16)),
        ...topCategories.map(
          (entry) => _buildCategoryRow(entry.key, entry.value),
        ),
      ],
    );
  }

  Widget _buildCategoryRow(String category, double amount) {
    final total = transactions.fold<double>(0, (sum, tx) => sum + tx.amount);
    final percentage = total > 0 ? (amount / total) : 0.0;

    return Padding(
      padding: EdgeInsets.only(bottom: responsiveHeight(12)),
      child: Row(
        children: [
          Container(
            width: responsiveWidth(8),
            height: responsiveWidth(8),
            decoration: BoxDecoration(
              color: _getCategoryColor(category),
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: responsiveWidth(12)),
          Expanded(
            child: Text(
              category,
              style: GoogleFonts.inter(
                fontSize: responsiveText(14),
                fontWeight: FontWeight.w500,
                color: primaryColor,
              ),
            ),
          ),
          Text(
            '${(percentage * 100).toInt()}%',
            style: GoogleFonts.inter(
              fontSize: responsiveText(14),
              fontWeight: FontWeight.w600,
              color: textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCategoryChips() {
    return Container(
      height: responsiveHeight(50),
      margin: EdgeInsets.only(bottom: responsiveHeight(16)),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: responsiveWidth(20)),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final bool isSelected = cat == selectedCategory;
          return Container(
            margin: EdgeInsets.only(right: responsiveWidth(12)),
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
                fontSize: responsiveText(14),
              ),
              side: BorderSide.none,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(responsiveWidth(20)),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildTransactionCard(Transaction tx) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: responsiveWidth(24),
        vertical: responsiveHeight(6),
      ),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(responsiveWidth(20)),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.04),
            blurRadius: responsiveWidth(20),
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: responsiveWidth(20),
          vertical: responsiveHeight(8),
        ),
        leading: Container(
          width: responsiveWidth(48),
          height: responsiveWidth(48),
          decoration: BoxDecoration(
            color: _getCategoryColor(tx.category),
            borderRadius: BorderRadius.circular(responsiveWidth(14)),
          ),
          child: Icon(
            _getCategoryIcon(tx.category),
            color: cardColor,
            size: responsiveText(24),
          ),
        ),
        title: Text(
          tx.description,
          style: GoogleFonts.inter(
            color: primaryColor,
            fontWeight: FontWeight.w600,
            fontSize: responsiveText(16),
          ),
        ),
        subtitle: Padding(
          padding: EdgeInsets.only(top: responsiveHeight(4)),
          child: Text(
            '${tx.category.toUpperCase()} • ${_formatTime(tx.date)}',
            style: GoogleFonts.inter(
              color: textSecondary,
              fontSize: responsiveText(13),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        trailing: Text(
          '₹${tx.amount.toStringAsFixed(1)}',
          style: GoogleFonts.inter(
            color: primaryColor,
            fontWeight: FontWeight.w700,
            fontSize: responsiveText(17),
          ),
        ),
      ),
    );
  }

  void _showCustomSnackBar({
    required String message,
    required IconData icon,
    required Color backgroundColor,
    required Color iconColor,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: EdgeInsets.symmetric(vertical: responsiveHeight(4)),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(responsiveWidth(8)),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(responsiveWidth(8)),
                ),
                child: Icon(icon, color: iconColor, size: responsiveText(20)),
              ),
              SizedBox(width: responsiveWidth(12)),
              Expanded(
                child: Text(
                  message,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    fontSize: responsiveText(14),
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(responsiveWidth(12)),
        ),
        margin: EdgeInsets.all(responsiveWidth(16)),
        duration: duration,
        elevation: 8,
      ),
    );
  }

  Color _getCategoryColor(String category) {
    final colors = [
      const Color(0xFF6C5CE7),
      const Color(0xFFE17055),
      const Color(0xFF00B894),
      const Color(0xFF0984E3),
      const Color(0xFFE84393),
      const Color(0xFFFD79A8),
      const Color(0xFF6C5CE7),
    ];
    return colors[categories.indexOf(category) % colors.length];
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Food':
        return Icons.restaurant_rounded;
      case 'Shopping':
        return Icons.shopping_bag_rounded;
      case 'Bills':
        return Icons.receipt_rounded;
      case 'Travel':
        return Icons.flight_rounded;
      case 'Entertainment':
        return Icons.movie_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inDays == 0) {
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else {
      return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}';
    }
  }

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          _buildHeader(),
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
                      itemBuilder:
                          (context, index) =>
                              buildTransactionCard(transactions[index]),
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

// ignore_for_file: sort_child_properties_last, use_build_context_synchronously, deprecated_member_use

import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

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

class StatisticsState extends State<Statistics> {
  List<Transaction> transactions = [];
  bool isLoading = false;

  final List<String> categories = [
    'All',
    'Food',
    'Shopping',
    'Bills',
    'Travel',
    'Entertainment',
    'Other',
  ];

  String selectedCategory = 'All';
  String _selectedPlan = 'Monthly';

  Map<String, double> totalAmountPerCategory = {};

  final Color backgroundColor = Color(0xFF121212); // Deep black
  final Color accentColor = Color(0xFF00FF88); // Modern green
  final Color cardColor = Color(0xFF1F1F1F); // Darker gray

  @override
  void initState() {
    super.initState();
    fetchTransactions();
  }

  //API Call for Fetch
  Future<void> fetchTransactions({String category = 'All'}) async {
    setState(() {
      isLoading = true;
    });

    try {
      final uri = Uri.parse('http://192.168.1.5:3000/api/transactions').replace(
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading transactions: $e')));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget buildCategoryChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children:
            categories.map((cat) {
              final bool isSelected = cat == selectedCategory;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(cat),
                  selected: isSelected,
                  selectedColor: backgroundColor,
                  backgroundColor: accentColor,
                  labelStyle: GoogleFonts.poppins(
                    color: isSelected ? accentColor : cardColor,
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        selectedCategory = cat;
                      });
                      fetchTransactions(category: cat);
                    }
                  },
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget buildTransactionCard(Transaction tx) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: cardColor.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 10,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: ListTile(
        title: Text(
          tx.description,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          '${tx.category} • ${tx.date.toLocal().toString().split(' ')[0]}',
          style: GoogleFonts.poppins(color: Colors.white60, fontSize: 12),
        ),
        trailing: Text(
          '₹${tx.amount.toStringAsFixed(2)}',
          style: GoogleFonts.poppins(
            color: accentColor,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildToggleButton(String label) {
    final bool isSelected = _selectedPlan == label;

    return GestureDetector(
      onTap: () => setState(() => _selectedPlan = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? accentColor : cardColor,
          borderRadius: BorderRadius.circular(18),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: accentColor.withOpacity(0.4),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                  ]
                  : [],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.poppins(
            color: isSelected ? backgroundColor : Colors.white70,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  int _selectedIndex = 0;

  Widget buildBarChart() {
    final barData = totalAmountPerCategory.entries.toList();

    if (barData.isEmpty) {
      return Center(
        child: Text(
          'No data to display',
          style: GoogleFonts.poppins(color: Colors.white70),
        ),
      );
    }

    double maxY = barData.map((e) => e.value).reduce((a, b) => a > b ? a : b);

    return AspectRatio(
      aspectRatio: 1.7,
      child: BarChart(
        BarChartData(
          backgroundColor: backgroundColor,
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY + 20,
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),

            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) {
                  if (value.toInt() < barData.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        barData[value.toInt()].key,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                },
                reservedSize: 30,
              ),
            ),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          barGroups: List.generate(barData.length, (i) {
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: barData[i].value,
                  gradient: LinearGradient(
                    colors: [accentColor, accentColor.withOpacity(0.6)],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                  width: 20,
                  borderRadius: BorderRadius.circular(30),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: Text(
          'Statistics',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(child: _buildToggleButton('Monthly')),
                const SizedBox(width: 10),
                Expanded(child: _buildToggleButton('Yearly')),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Text(
              '₹ ${transactions.fold<double>(0, (sum, tx) => sum + tx.amount).toStringAsFixed(2)}',
              style: GoogleFonts.poppins(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: accentColor,
              ),
            ),
          ),
          Padding(padding: const EdgeInsets.all(16.0), child: buildBarChart()),
          buildCategoryChips(),
          const SizedBox(height: 10),
          Expanded(
            child:
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : transactions.isEmpty
                    ? Center(
                      child: Text(
                        'No transactions found.',
                        style: GoogleFonts.poppins(color: Colors.white70),
                      ),
                    )
                    : ListView.builder(
                      itemCount: transactions.length,
                      itemBuilder:
                          (context, index) =>
                              buildTransactionCard(transactions[index]),
                    ),
          ),

          CustomNavBar(
            currentIndex: _selectedIndex,
            onTap: (index) {
              setState(() => _selectedIndex = index);
            },
            backgroundColor: backgroundColor.withOpacity(0.0),
            accentColor: accentColor,
          ),
        ],
      ),
    );
  }
}

class CustomNavBar extends StatelessWidget {
  final int currentIndex;
  final void Function(int) onTap;
  final Color backgroundColor;
  final Color accentColor;

  const CustomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.backgroundColor,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Align(
      alignment: Alignment.bottomLeft,
      child: SizedBox(
        width: screenWidth,
        height: 100, // enough space, but no visible background
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Translucent nav bar
            Positioned(
              left: 20,
              bottom: 20,
              child: Container(
                width: screenWidth * 0.5,
                height: 70,
                decoration: BoxDecoration(
                  color: backgroundColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      spreadRadius: 2,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildNavItem(Icons.home, 0),
                        _buildNavItem(Icons.pie_chart, 1),
                        _buildNavItem(Icons.settings, 2),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Floating Add Button
            Positioned(
              right: 20,
              bottom: 12,
              child: Material(
                color: Colors.transparent,
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: () => onTap(4),
                  customBorder: const CircleBorder(),
                  splashColor: Colors.white.withOpacity(0.2),
                  child: Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: accentColor,
                      boxShadow: [
                        BoxShadow(
                          color: accentColor.withOpacity(0.6),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.add, color: Colors.black, size: 30),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    final isActive = currentIndex == index;

    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: () => onTap(index),
        customBorder: const CircleBorder(),
        splashColor: accentColor.withOpacity(0.2),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: isActive ? 56 : 50,
          height: isActive ? 56 : 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? accentColor.withOpacity(0.1) : Colors.transparent,
            border:
                isActive
                    ? Border.all(color: accentColor.withOpacity(0.5), width: 2)
                    : null,
          ),
          child: Icon(
            icon,
            color: isActive ? accentColor : Colors.white70,
            size: 24,
          ),
        ),
      ),
    );
  }
}

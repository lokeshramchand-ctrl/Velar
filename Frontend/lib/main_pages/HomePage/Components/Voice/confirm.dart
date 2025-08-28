// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:monarch/other_pages/reponsive.dart';
import 'package:monarch/other_pages/colors.dart';
import 'package:monarch/other_pages/enviroment.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConfirmTransactionPage extends StatelessWidget {
  final Map<String, dynamic> data;

  const ConfirmTransactionPage({super.key, required this.data});

  Future<void> _saveTransaction(BuildContext context) async {
    const String saveUrl =
        '${Environment.baseUrl}/api/transaction/add'; // ✅ make sure this matches backend

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId == null) {
        throw Exception('User ID not found. Please log in again.');
      }

      final response = await http.post(
        Uri.parse(saveUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'description': data['description'] ?? '',
          'amount':
              double.tryParse(data['amount'].toString()) ??
              0.0, // ✅ force number
          'category': data['category'] ?? 'Uncategorized',
          'date': data['date'] ?? DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        _showCustomSnackBar(
          context: context,
          message: '✅ Transaction saved successfully!',
          icon: Icons.check_circle,
          backgroundColor: const Color(0xFF4CAF50),
          iconColor: Colors.white,
          duration: const Duration(seconds: 3),
        );
        Navigator.popUntil(context, (route) => route.isFirst);
      } else {
        // 👇 Log backend response
        throw Exception('Save failed: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      _showCustomSnackBar(
        context: context,
        message: 'Error saving transaction: ${e.toString()}',
        icon: Icons.error_outline,
        backgroundColor: const Color(0xFFFF6B6B),
        iconColor: Colors.white,
        duration: const Duration(seconds: 4),
      );
    }
  }

  void _showCustomSnackBar({
    required String message,
    required IconData icon,
    required Color backgroundColor,
    required Color iconColor,
    Duration duration = const Duration(seconds: 3),
    required BuildContext context,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: EdgeInsets.symmetric(vertical: context.responsiveHeight(4)),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(context.responsiveWidth(8)),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(
                    context.responsiveWidth(8),
                  ),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: context.responsiveText(20),
                ),
              ),
              SizedBox(width: context.responsiveWidth(12)),
              Expanded(
                child: Text(
                  message,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    fontSize: context.responsiveText(14),
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
          borderRadius: BorderRadius.circular(context.responsiveWidth(12)),
        ),
        margin: EdgeInsets.all(context.responsiveWidth(16)),
        duration: duration,
        elevation: 8,
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
    bool isAmount = false,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: accentColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: accentColor, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  color: primaryColor.withOpacity(0.6),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.inter(
                  color: isAmount ? Colors.green : primaryColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final amount = data['amount'];
    final description = data['description'];
    final category = data['category'];
    final date =
        data['date'] != null
            ? DateTime.parse(data['date']).toLocal()
            : DateTime.now();

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: primaryColor.withOpacity(0.1), width: 1),
          ),
          child: IconButton(
            icon: Icon(Icons.arrow_back, color: primaryColor),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Text(
          'Confirm Transaction',
          style: GoogleFonts.inter(
            color: primaryColor,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                  border: Border.all(
                    color: accentColor.withOpacity(0.1),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.green.withOpacity(0.2),
                              width: 1.5,
                            ),
                          ),
                          child: const Icon(
                            Icons.check_circle_outline,
                            color: Colors.green,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Review Transaction',
                                style: GoogleFonts.inter(
                                  color: primaryColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                'Please confirm the details below',
                                style: GoogleFonts.inter(
                                  color: primaryColor.withOpacity(0.6),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Transaction Details
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: primaryColor.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    _buildDetailItem(
                      icon: Icons.description_outlined,
                      label: 'Description',
                      value: description?.toString() ?? 'No description',
                    ),

                    const SizedBox(height: 20),

                    _buildDetailItem(
                      icon: Icons.payments_outlined,
                      label: 'Amount',
                      value: '₹$amount',
                      isAmount: true,
                    ),

                    const SizedBox(height: 20),

                    _buildDetailItem(
                      icon: Icons.category_outlined,
                      label: 'Category',
                      value: category?.toString() ?? 'Uncategorized',
                    ),

                    const SizedBox(height: 20),

                    _buildDetailItem(
                      icon: Icons.calendar_today_outlined,
                      label: 'Date',
                      value: '${date.day}/${date.month}/${date.year}',
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Action Buttons
              Column(
                children: [
                  // Confirm Button
                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.green, Colors.green.shade600],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => _saveTransaction(context),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Confirm & Save Transaction',
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Cancel Button
                  Container(
                    width: double.infinity,
                    height: 48,
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: primaryColor.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Edit or Cancel',
                        style: GoogleFonts.inter(
                          color: primaryColor.withOpacity(0.7),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:monarch/other_pages/reponsive.dart';
import 'package:monarch/other_pages/colors.dart';
import 'package:monarch/other_pages/enviroment.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConfirmTransactionPage extends StatefulWidget {
  final Map<String, dynamic> data;

  const ConfirmTransactionPage({super.key, required this.data});

  @override
  State<ConfirmTransactionPage> createState() => _ConfirmTransactionPageState();
}

class _ConfirmTransactionPageState extends State<ConfirmTransactionPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _saveTransaction(BuildContext context) async {
    const String saveUrl = '${Environment.baseUrl}/api/transaction/add';

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
          'description': widget.data['description'] ?? '',
          'amount': double.tryParse(widget.data['amount'].toString()) ?? 0.0,
          'category': widget.data['category'] ?? 'Uncategorized',
          'date': widget.data['date'] ?? DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        _showCustomSnackBar(
          context: context,
          message: '✅ Transaction saved successfully!',
          icon: Icons.check_circle,
          backgroundColor: const Color(0xFF4CAF50),
          iconColor: Colors.white,
        );
        Navigator.popUntil(context, (route) => route.isFirst);
      } else {
        throw Exception('Save failed: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      _showCustomSnackBar(
        context: context,
        message: 'Error saving transaction: ${e.toString()}',
        icon: Icons.error_outline,
        backgroundColor: const Color(0xFFFF6B6B),
        iconColor: Colors.white,
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
        content: Row(
          children: [
            Icon(icon, color: iconColor, size: context.responsiveText(20)),
            SizedBox(width: context.responsiveWidth(8)),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  fontSize: context.responsiveText(14),
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(context.responsiveWidth(12)),
        duration: duration,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(context.responsiveWidth(12)),
        ),
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
          width: context.responsiveWidth(40),
          height: context.responsiveWidth(40),
          decoration: BoxDecoration(
            color: accentColor.withOpacity(0.08),
            borderRadius: BorderRadius.circular(context.responsiveWidth(10)),
          ),
          child: Icon(
            icon,
            color: accentColor,
            size: context.responsiveText(20),
          ),
        ),
        SizedBox(width: context.responsiveWidth(14)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  color: primaryColor.withOpacity(0.6),
                  fontSize: context.responsiveText(12),
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: context.responsiveHeight(2)),
              Text(
                value,
                style: GoogleFonts.inter(
                  color: isAmount ? Colors.green : primaryColor,
                  fontSize: context.responsiveText(16),
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
    final amount = widget.data['amount'];
    final description = widget.data['description'];
    final category = widget.data['category'];
    final date =
        widget.data['date'] != null
            ? DateTime.parse(widget.data['date']).toLocal()
            : DateTime.now();

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: EdgeInsets.all(context.responsiveWidth(6)),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(context.responsiveWidth(12)),
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
            fontSize: context.responsiveText(18),
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Padding(
              padding: EdgeInsets.all(context.responsiveWidth(20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Container(
                    padding: EdgeInsets.all(context.responsiveWidth(18)),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(
                        context.responsiveWidth(18),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: accentColor.withOpacity(0.08),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(context.responsiveWidth(10)),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(
                              context.responsiveWidth(10),
                            ),
                          ),
                          child: Icon(
                            Icons.check_circle_outline,
                            color: Colors.green,
                            size: context.responsiveText(22),
                          ),
                        ),
                        SizedBox(width: context.responsiveWidth(14)),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Review Transaction",
                              style: GoogleFonts.inter(
                                fontSize: context.responsiveText(16),
                                fontWeight: FontWeight.w700,
                                color: primaryColor,
                              ),
                            ),
                            Text(
                              "Please confirm the details below",
                              style: GoogleFonts.inter(
                                fontSize: context.responsiveText(13),
                                fontWeight: FontWeight.w500,
                                color: primaryColor.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: context.responsiveHeight(24)),

                  // Details Card
                  Container(
                    padding: EdgeInsets.all(context.responsiveWidth(20)),
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(
                        context.responsiveWidth(18),
                      ),
                      border: Border.all(
                        color: primaryColor.withOpacity(0.08),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildDetailItem(
                          icon: Icons.description_outlined,
                          label: "Description",
                          value: description?.toString() ?? "No description",
                        ),
                        SizedBox(height: context.responsiveHeight(16)),
                        _buildDetailItem(
                          icon: Icons.payments_outlined,
                          label: "Amount",
                          value: "₹$amount",
                          isAmount: true,
                        ),
                        SizedBox(height: context.responsiveHeight(16)),
                        _buildDetailItem(
                          icon: Icons.category_outlined,
                          label: "Category",
                          value: category?.toString() ?? "Uncategorized",
                        ),
                        SizedBox(height: context.responsiveHeight(16)),
                        _buildDetailItem(
                          icon: Icons.calendar_today_outlined,
                          label: "Date",
                          value: "${date.day}/${date.month}/${date.year}",
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Buttons
                  Column(
                    children: [
                      // Confirm
                      GestureDetector(
                        onTapDown: (_) => _controller.forward(),
                        onTapUp: (_) => _saveTransaction(context),
                        child: AnimatedScale(
                          scale: 1,
                          duration: const Duration(milliseconds: 150),
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                              vertical: context.responsiveHeight(14),
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.green, Colors.green.shade700],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(
                                context.responsiveWidth(14),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.green.withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                "Confirm & Save Transaction",
                                style: GoogleFonts.inter(
                                  fontSize: context.responsiveText(15),
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: context.responsiveHeight(14)),

                      // Cancel
                      OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          minimumSize: Size(
                            double.infinity,
                            context.responsiveHeight(48),
                          ),
                          side: BorderSide(
                            color: primaryColor.withOpacity(0.3),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              context.responsiveWidth(12),
                            ),
                          ),
                        ),
                        child: Text(
                          "Edit or Cancel",
                          style: GoogleFonts.inter(
                            fontSize: context.responsiveText(14),
                            fontWeight: FontWeight.w600,
                            color: primaryColor.withOpacity(0.8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

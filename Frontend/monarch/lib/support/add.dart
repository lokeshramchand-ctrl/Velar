// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:monarch/other_pages/enviroment.dart';
import 'package:monarch/main_pages/Statistics/statistics.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen>
    with TickerProviderStateMixin {
  // Modern color palette inspired by the image
  final Color backgroundColor = const Color(0xFFF8F9FA); // Light cream/white
  final Color primaryColor = const Color(0xFF2D3436); // Deep charcoal
  final Color accentColor = const Color(0xFF00B894); // Emerald green
  final Color cardColor = const Color(0xFFFFFFFF); // Pure white
  final Color textSecondary = const Color(0xFF636E72); // Muted gray
  final Color surfaceColor = const Color(0xFFF1F2F6); // Light surface

  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _amountFocus = FocusNode();

  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  bool _isNameFocused = false;
  String _displayAmount = '';

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _nameFocus.addListener(() {
      setState(() {
        _isNameFocused = _nameFocus.hasFocus;
      });
    });

    _amountFocus.addListener(() {
      setState(() {});
    });

    // Start animations
    _slideController.forward();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    descriptionController.dispose();
    amountController.dispose();
    _nameFocus.dispose();
    _amountFocus.dispose();
    super.dispose();
  }

  void _onAmountChanged(String value) {
    if (value.isEmpty) {
      setState(() {
        _displayAmount = '';
      });
      return;
    }

    // Remove any non-digit characters except decimal point
    String cleanValue = value.replaceAll(RegExp(r'[^\d.]'), '');

    // Ensure only one decimal point
    List<String> parts = cleanValue.split('.');
    if (parts.length > 2) {
      cleanValue =
          '₹{parts[0]}.₹{parts.sublist(1).join('
          ')}';
    }

    if (cleanValue.isNotEmpty) {
      double? amount = double.tryParse(cleanValue);
      if (amount != null) {
        setState(() {
          _displayAmount = '₹${amount.toStringAsFixed(2)}';
        });
      }
    }
  }

  Widget _buildKeypadButton(
    String text, {
    bool isSpecial = false,
    double buttonHeight = 60,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        if (text == '⌫') {
          if (amountController.text.isNotEmpty) {
            amountController.text = amountController.text.substring(
              0,
              amountController.text.length - 1,
            );
            _onAmountChanged(amountController.text);
          }
        } else if (text == '.') {
          if (!amountController.text.contains('.')) {
            amountController.text += text;
            _onAmountChanged(amountController.text);
          }
        } else {
          amountController.text += text;
          _onAmountChanged(amountController.text);
        }
      },
      child: Container(
        height: buttonHeight,
        decoration: BoxDecoration(
          color: isSpecial ? surfaceColor : cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSpecial ? textSecondary.withOpacity(0.2) : surfaceColor,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: isSpecial ? textSecondary : primaryColor,
            ),
          ),
        ),
      ),
    );
  }
  final baseUrl = dotenv.env['BASE_URL'];

  Future<void> addTransaction() async {
    // Validation first
    if (descriptionController.text.trim().isEmpty ||
        amountController.text.trim().isEmpty) {
      _showCustomSnackBar(
        message: 'Please fill in both name and amount',
        icon: Icons.warning_rounded,
        backgroundColor: const Color(0xFFFF6B6B),
        iconColor: Colors.white,
      );
      return;
    }

    // Show beautiful loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                    strokeWidth: 3,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Processing transaction...',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
    );

    try {
      final response = await http.post(
        Uri.parse('${Environment.baseUrl}/api/transaction/add'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'description': descriptionController.text,
          'amount': double.tryParse(amountController.text),
        }),
      );

      Navigator.of(context).pop(); // Close loading dialog

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final predictedCategory = responseData['data']['category'];

        // Clear the input fields
        descriptionController.clear();
        amountController.clear();
        setState(() {
          _displayAmount = '';
        });

        // Show success message
        _showCustomSnackBar(
          message:
              'Transaction added successfully!\nCategorized as: $predictedCategory',
          icon: Icons.check_circle_rounded,
          backgroundColor: accentColor,
          iconColor: Colors.white,
          duration: const Duration(seconds: 2),
        );

        // Navigate back to statistics page after a short delay
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) {
            Navigator.of(context).pop(); // Go back to previous screen
          }
        });
      } else {
        _showCustomSnackBar(
          message: 'Failed to add transaction\nPlease try again',
          icon: Icons.error_rounded,
          backgroundColor: const Color(0xFFFF6B6B),
          iconColor: Colors.white,
        );
      }
    } catch (e) {
      Navigator.of(context).pop(); // Close loading dialog
      _showCustomSnackBar(
        message: 'Network error occurred\nPlease check your connection',
        icon: Icons.wifi_off_rounded,
        backgroundColor: const Color(0xFFFF9F43),
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
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: duration,
        elevation: 8,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: SafeArea(
        child: SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap:
                            () => Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Statistics(),
                              ),
                            ),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Add Expense',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                // Main Content Card
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Drag indicator
                          Center(
                            child: Container(
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: textSecondary.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Expense Name Section
                          Text(
                            'Expense Name',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: primaryColor,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            decoration: BoxDecoration(
                              color: _isNameFocused ? cardColor : surfaceColor,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color:
                                    _isNameFocused
                                        ? accentColor
                                        : Colors.transparent,
                                width: 2,
                              ),
                              boxShadow:
                                  _isNameFocused
                                      ? [
                                        BoxShadow(
                                          color: accentColor.withOpacity(0.1),
                                          blurRadius: 20,
                                          offset: const Offset(0, 4),
                                        ),
                                      ]
                                      : [
                                        BoxShadow(
                                          color: primaryColor.withOpacity(0.06),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                            ),
                            child: TextField(
                              controller: descriptionController,
                              focusNode: _nameFocus,
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: primaryColor,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Enter expense name',
                                hintStyle: GoogleFonts.inter(
                                  color: textSecondary,
                                  fontWeight: FontWeight.w400,
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.all(20),
                              ),
                            ),
                          ),

                          const SizedBox(height: 40),

                          // Amount Display
                          Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                color: cardColor,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: primaryColor.withOpacity(0.08),
                                    blurRadius: 16,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Text(
                                _displayAmount.isEmpty
                                    ? '₹0.00'
                                    : _displayAmount,
                                style: GoogleFonts.inter(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w700,
                                  color: primaryColor,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Custom Keypad
                          Expanded(
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                double availableHeight = constraints.maxHeight;
                                double buttonHeight =
                                    (availableHeight - 32) /
                                    4; // 4 rows with spacing
                                buttonHeight = buttonHeight.clamp(
                                  50.0,
                                  70.0,
                                ); // Min 50, Max 70

                                return GridView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3,
                                        childAspectRatio:
                                            constraints.maxWidth /
                                            (buttonHeight * 3 + 32),
                                        crossAxisSpacing: 10,
                                        mainAxisSpacing: 10,
                                      ),
                                  itemCount: 12,
                                  itemBuilder: (context, index) {
                                    List<String> keys = [
                                      '1',
                                      '2',
                                      '3',
                                      '4',
                                      '5',
                                      '6',
                                      '7',
                                      '8',
                                      '9',
                                      '.',
                                      '0',
                                      '⌫',
                                    ];
                                    return _buildKeypadButton(
                                      keys[index],
                                      isSpecial:
                                          keys[index] == '.' ||
                                          keys[index] == '⌫',
                                      buttonHeight: buttonHeight,
                                    );
                                  },
                                );
                              },
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Add Expense Button
                          GestureDetector(
                            onTap: addTransaction,
                            child: Container(
                              width: double.infinity,
                              height: 60,
                              decoration: BoxDecoration(
                                color: accentColor,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: accentColor.withOpacity(0.3),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  'Add Expense',
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

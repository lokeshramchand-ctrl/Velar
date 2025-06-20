// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen>
    with TickerProviderStateMixin {
  // Constants and Controllers
  static const _animationDuration = Duration(milliseconds: 600);
  static const _fadeDuration = Duration(milliseconds: 800);

  // Color Scheme
  final Color backgroundColor = const Color(0xFFF8F9FA);
  final Color primaryColor = const Color(0xFF2D3436);
  final Color accentColor = const Color(0xFF00B894);
  final Color cardColor = const Color(0xFFFFFFFF);
  final Color textSecondary = const Color(0xFF636E72);
  final Color surfaceColor = const Color(0xFFF1F2F6);

  // Controllers and Focus Nodes
  final TextEditingController amountController = TextEditingController();
  final FocusNode _amountFocus = FocusNode();

  // Animation Controllers
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  // State Variables
  String _displayAmount = '';

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _setupFocusListeners();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    amountController.dispose();
    _amountFocus.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: _animationDuration,
      vsync: this,
    );
    _fadeController = AnimationController(duration: _fadeDuration, vsync: this);

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

    _slideController.forward();
    _fadeController.forward();
  }

  void _setupFocusListeners() {
    _amountFocus.addListener(() => setState(() {}));
  }

  // UI Components
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: _responsiveWidth(20, context),
        vertical: _responsiveHeight(20, context),
      ),
      child: Row(
        children: [
          _buildBackButton(context),
          SizedBox(width: _responsiveWidth(16, context)),
          Text(
            'Budget',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: _responsiveText(24, context),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        width: _responsiveWidth(44, context),
        height: _responsiveWidth(44, context),
        decoration: BoxDecoration(
          color: primaryColor.withOpacity(0.8),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
        ),
        child: const Icon(
          Icons.arrow_back_ios_new,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildAmountDisplay() {
    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: _responsiveWidth(24, context),
          vertical: _responsiveHeight(16, context),
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
          _displayAmount.isEmpty ? '₹0.00' : _displayAmount,
          style: GoogleFonts.inter(
            fontSize: _responsiveText(36, context),
            fontWeight: FontWeight.w700,
            color: primaryColor,
          ),
        ),
      ),
    );
  }

  Widget _buildKeypad(BuildContext context) {
    return Expanded(
      child: GridView.count(
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 3,
        childAspectRatio: 1,
        mainAxisSpacing: _responsiveWidth(10, context),
        crossAxisSpacing: _responsiveWidth(10, context),
        padding: EdgeInsets.symmetric(
          horizontal: _responsiveWidth(10, context),
        ),
        children:
            [
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
            ].map((key) => _buildKeypadButton(key, context)).toList(),
      ),
    );
  }

  Widget _buildKeypadButton(String text, BuildContext context) {
    final isSpecial = text == '.' || text == '⌫';

    return GestureDetector(
      onTap: () => _handleKeyPress(text),
      child: Container(
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
              fontSize: _responsiveText(24, context),
              fontWeight: FontWeight.w600,
              color: isSpecial ? textSecondary : primaryColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return GestureDetector(
      onTap: _addTransaction,
      child: Container(
        width: double.infinity,
        height: _responsiveHeight(60, context),
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
            'Update Budget',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: _responsiveText(18, context),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  // Helper Methods
  double _responsiveWidth(double size, BuildContext context) {
    return size *
        (MediaQuery.of(context).size.width / 375); // Base width 375 (iPhone 8)
  }

  double _responsiveHeight(double size, BuildContext context) {
    return size *
        (MediaQuery.of(context).size.height /
            812); // Base height 812 (iPhone 8)
  }

  double _responsiveText(double size, BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 350) return size * 0.9;
    if (width > 600) return size * 1.2;
    return size;
  }

  void _handleKeyPress(String text) {
    HapticFeedback.lightImpact();
    if (text == '⌫') {
      if (amountController.text.isNotEmpty) {
        amountController.text = amountController.text.substring(
          0,
          amountController.text.length - 1,
        );
        _updateDisplayAmount();
      }
    } else if (text == '.') {
      if (!amountController.text.contains('.')) {
        amountController.text += text;
        _updateDisplayAmount();
      }
    } else {
      amountController.text += text;
      _updateDisplayAmount();
    }
  }

  void _updateDisplayAmount() {
    if (amountController.text.isEmpty) {
      setState(() => _displayAmount = '');
      return;
    }

    final cleanValue = amountController.text.replaceAll(RegExp(r'[^\d.]'), '');
    final parts = cleanValue.split('.');
    final cleanNumber =
        parts.length > 2
            ? '${parts[0]}.${parts.sublist(1).join('')}'
            : cleanValue;

    if (cleanNumber.isNotEmpty) {
      final amount = double.tryParse(cleanNumber);
      if (amount != null) {
        setState(() => _displayAmount = '₹${amount.toStringAsFixed(2)}');
      }
    }
  }

  Future<void> _addTransaction() async {
    if (amountController.text.trim().isEmpty) {
      _showCustomSnackBar(
        message: 'Please enter an amount',
        icon: Icons.warning_rounded,
        backgroundColor: const Color(0xFFFF6B6B),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _buildLoadingDialog(),
    );

    try {
      final response = await http
          .post(
            Uri.parse('http://192.168.1.9:3000/api/transaction/add'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'amount': double.tryParse(amountController.text),
            }),
          )
          .timeout(const Duration(seconds: 10));

      Navigator.of(context).pop();

      if (response.statusCode == 200) {
        _handleSuccessResponse(response);
      } else {
        _showError('Failed to add transaction');
      }
    } catch (e) {
      Navigator.of(context).pop();
      _showError('Network error occurred');
    }
  }

  Widget _buildLoadingDialog() {
    return Center(
      child: Container(
        padding: EdgeInsets.all(_responsiveWidth(24, context)),
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
            SizedBox(height: _responsiveHeight(16, context)),
            Text(
              'Processing...',
              style: GoogleFonts.inter(
                fontSize: _responsiveText(16, context),
                fontWeight: FontWeight.w500,
                color: primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSuccessResponse(http.Response response) {
    final responseData = json.decode(response.body);
    final category = responseData['data']['category'];

    amountController.clear();
    setState(() => _displayAmount = '');

    _showCustomSnackBar(
      message: 'Added successfully!\nCategory: $category',
      icon: Icons.check_circle_rounded,
      backgroundColor: accentColor,
    );

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) Navigator.pop(context);
    });
  }

  void _showError(String message) {
    _showCustomSnackBar(
      message: message,
      icon: Icons.error_rounded,
      backgroundColor: const Color(0xFFFF6B6B),
    );
  }

  void _showCustomSnackBar({
    required String message,
    required IconData icon,
    required Color backgroundColor,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
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
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(_responsiveWidth(16, context)),
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
                _buildHeader(context),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(top: _responsiveHeight(8, context)),
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(_responsiveWidth(24, context)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Container(
                              width: _responsiveWidth(40, context),
                              height: 4,
                              decoration: BoxDecoration(
                                color: textSecondary.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          SizedBox(height: _responsiveHeight(32, context)),
                          _buildAmountDisplay(),
                          SizedBox(height: _responsiveHeight(20, context)),
                          _buildKeypad(context),
                          SizedBox(height: _responsiveHeight(24, context)),
                          _buildAddButton(context),
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

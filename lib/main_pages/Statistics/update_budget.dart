// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monarch/other_pages/colors.dart';
import 'package:monarch/main_pages/Statistics/statistics.dart';

class UpdateBudget extends StatefulWidget {
  const UpdateBudget({super.key});

  @override
  State<UpdateBudget> createState() => _UpdateBudgetState();
}

class _UpdateBudgetState extends State<UpdateBudget>
    with TickerProviderStateMixin {
  // Constants and Controllers
  static const _animationDuration = Duration(milliseconds: 600);
  static const _fadeDuration = Duration(milliseconds: 800);


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
      onTap: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Statistics(),
                  ),
      ),
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
    return ElevatedButton(
      onPressed: () {
        final amount = double.tryParse(amountController.text);
        if (amount != null && amount > 0) {
          Navigator.pop(context, amount); // Simply return the value
        } else if (amount == null || amount <= 0) {
          _showCustomSnackBar(
            message: 'Please enter a valid budget amount',
            icon: Icons.error,
            backgroundColor: Colors.red,
          );
        }
      },
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
    HapticFeedback.heavyImpact();
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

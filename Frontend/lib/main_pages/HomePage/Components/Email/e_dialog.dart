// ignore_for_file: deprecated_member_use, unused_import
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:monarch/main_pages/HomePage/homepage.dart';
import 'dart:convert';
import 'dart:math' as math;
import 'package:monarch/other_pages/colors.dart';
import 'package:monarch/other_pages/enviroment.dart';
import 'package:shared_preferences/shared_preferences.dart';

extension ResponsiveExtension on BuildContext {
  double responsiveWidth(double size) {
    return size * (MediaQuery.of(this).size.width / 375);
  }

  double responsiveHeight(double size) {
    return size * (MediaQuery.of(this).size.height / 812);
  }

  double responsiveText(double size) {
    final width = MediaQuery.of(this).size.width;
    if (width < 350) return size * 0.9;
    if (width > 600) return size * 1.2;
    return size;
  }
}

class EmailTransactionDialog extends StatefulWidget {
  const EmailTransactionDialog({super.key});

  @override
  State<EmailTransactionDialog> createState() => _EmailTransactionDialogState();
}

class _EmailTransactionDialogState extends State<EmailTransactionDialog>
    with TickerProviderStateMixin {
  final List<dynamic> _emails = [];
  bool _loading = true;
  String? _status;
  int _syncedCount = 0;
  String? _error;
  String? _userId;
  String? _accessToken;

  late AnimationController _slideController;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _rotationController;
  late AnimationController _progressController;

  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startEntryAnimation();
    _autoSyncEmails();
  }

  void _initAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(_rotationController);

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );
  }

  void _startEntryAnimation() {
    _slideController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _fadeController.forward();
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      _scaleController.forward();
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    _rotationController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  Future<void> _autoSyncEmails() async {
    setState(() {
      _loading = true;
      _status = "Syncing your bank emails...";
      _syncedCount = 0;
    });

    _rotationController.repeat();
    _progressController.forward();

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      final accessToken = prefs.getString('accessToken');

      final response = await http.post(
        Uri.parse("${Environment.baseUrl}/api/sync-gmail"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"accessToken": accessToken, "userId": userId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['count'] != null) {
          setState(() {
            _loading = false;
            _syncedCount = data['count'];
            _status = "Synced";
          });

          _rotationController.stop();
          _progressController.reset();

          // Success animation
          _scaleController.reset();
          _scaleController.forward();
        } else {
          setState(() {
            _loading = false;
            _status = " Sync failed: Unexpected response format";
          });
          _rotationController.stop();
        }
      } else {
        setState(() {
          _loading = false;
          _status = "Backend error: ${response.body}";
        });
        _rotationController.stop();
      }
    } catch (error) {
      setState(() {
        _loading = false;
        _status = "Network error: $error";
      });
      _rotationController.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        height: context.responsiveHeight(560),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(context.responsiveWidth(28)),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 32,
              offset: const Offset(0, -8),
              spreadRadius: 2,
            ),
            BoxShadow(
              color: primaryColor.withOpacity(0.05),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Drag Handle with Animation
            FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                width: context.responsiveWidth(48),
                height: context.responsiveHeight(4),
                margin: EdgeInsets.only(
                  top: context.responsiveHeight(16),
                  bottom: context.responsiveHeight(24),
                ),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(
                    context.responsiveWidth(2),
                  ),
                ),
              ),
            ),

            // Animated Header
            FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: context.responsiveWidth(24),
                ),
                child: Row(
                  children: [
                    // Animated Icon Container
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        width: context.responsiveWidth(56),
                        height: context.responsiveWidth(56),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              accentColor.withOpacity(0.1),
                              accentColor.withOpacity(0.05),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(
                            context.responsiveWidth(16),
                          ),
                          border: Border.all(
                            color: accentColor.withOpacity(0.2),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: accentColor.withOpacity(0.1),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.email_rounded,
                          color: accentColor,
                          size: context.responsiveWidth(28),
                        ),
                      ),
                    ),
                    SizedBox(width: context.responsiveWidth(16)),

                    // Title Section
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Email Transactions',
                            style: GoogleFonts.inter(
                              color: primaryColor,
                              fontSize: context.responsiveText(20),
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.5,
                            ),
                          ),
                          SizedBox(height: context.responsiveHeight(2)),
                          Text(
                            'Forward receipts to auto-add transactions',
                            style: GoogleFonts.inter(
                              color: primaryColor.withOpacity(0.6),
                              fontSize: context.responsiveText(13),
                              fontWeight: FontWeight.w500,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Animated Refresh Button
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        width: context.responsiveWidth(44),
                        height: context.responsiveWidth(44),
                        decoration: BoxDecoration(
                          color: accentColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(
                            context.responsiveWidth(12),
                          ),
                          border: Border.all(
                            color: accentColor.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _autoSyncEmails,
                            borderRadius: BorderRadius.circular(
                              context.responsiveWidth(12),
                            ),
                            child: AnimatedBuilder(
                              animation: _rotationAnimation,
                              builder: (context, child) {
                                return Transform.rotate(
                                  angle:
                                      _loading ? _rotationAnimation.value : 0,
                                  child: Icon(
                                    Icons.refresh_rounded,
                                    color: accentColor,
                                    size: context.responsiveWidth(22),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: context.responsiveHeight(32)),

            // Main Content Area
            Expanded(
              child: _loading ? _buildLoadingContent() : _buildResultContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingContent() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated Loading Circle
          ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              width: context.responsiveWidth(80),
              height: context.responsiveWidth(80),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    accentColor.withOpacity(0.1),
                    accentColor.withOpacity(0.05),
                  ],
                ),
                border: Border.all(
                  color: accentColor.withOpacity(0.2),
                  width: 2,
                ),
              ),
              child: AnimatedBuilder(
                animation: _rotationAnimation,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _rotationAnimation.value,
                    child: Icon(
                      Icons.sync_rounded,
                      color: accentColor,
                      size: context.responsiveWidth(36),
                    ),
                  );
                },
              ),
            ),
          ),

          SizedBox(height: context.responsiveHeight(32)),

          // Progress Bar
          Container(
            width: context.responsiveWidth(200),
            height: context.responsiveHeight(6),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(context.responsiveWidth(3)),
            ),
            child: AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) {
                return FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: _progressAnimation.value,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [accentColor, accentColor.withOpacity(0.7)],
                      ),
                      borderRadius: BorderRadius.circular(
                        context.responsiveWidth(3),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          SizedBox(height: context.responsiveHeight(24)),

          // Status Text
          Text(
            _status ?? "Processing...",
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: context.responsiveText(16),
              fontWeight: FontWeight.w600,
              color: primaryColor.withOpacity(0.8),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultContent() {
    final isSuccess = _status?.contains('✅') == true;
    final isError =
        _status?.contains('❌') == true || _status?.contains('⚠️') == true;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Result Icon
          ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              width: context.responsiveWidth(80),
              height: context.responsiveWidth(80),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors:
                      isSuccess
                          ? [
                            Colors.green.withOpacity(0.1),
                            Colors.green.withOpacity(0.05),
                          ]
                          : isError
                          ? [
                            Colors.red.withOpacity(0.1),
                            Colors.red.withOpacity(0.05),
                          ]
                          : [
                            accentColor.withOpacity(0.1),
                            accentColor.withOpacity(0.05),
                          ],
                ),
                border: Border.all(
                  color:
                      isSuccess
                          ? Colors.green.withOpacity(0.3)
                          : isError
                          ? Colors.red.withOpacity(0.3)
                          : accentColor.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.check_circle_rounded,
                color:
                    isSuccess
                        ? Colors.green
                        : isError
                        ? Colors.red
                        : accentColor,
                size: context.responsiveWidth(36),
              ),
            ),
          ),

          SizedBox(height: context.responsiveHeight(24)),

          // Status Text
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: context.responsiveWidth(32),
            ),
            child: Text(
              _status ?? "Done",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: context.responsiveText(16),
                fontWeight: FontWeight.w600,
                color: primaryColor.withOpacity(0.9),
                height: 1.4,
              ),
            ),
          ),

          SizedBox(height: context.responsiveHeight(32)),

          // Action Button
          ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              width: context.responsiveWidth(180),
              height: context.responsiveHeight(48),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [accentColor, accentColor.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(
                  context.responsiveWidth(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _autoSyncEmails,
                  borderRadius: BorderRadius.circular(
                    context.responsiveWidth(24),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(width: context.responsiveWidth(8)),
                      Text(
                        "Update",
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: context.responsiveText(14),
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

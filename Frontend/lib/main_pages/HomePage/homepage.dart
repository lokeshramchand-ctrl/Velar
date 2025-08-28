// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:monarch/main_pages/HomePage/animated.dart';
import 'package:monarch/main_pages/HomePage/greeting.dart';
import 'package:monarch/main_pages/HomePage/navbar.dart';
import 'package:monarch/main_pages/HomePage/Components/Voice/t_dialog.dart';
import 'package:monarch/main_pages/HomePage/Components/Voice/voice_dialog.dart';
import 'package:monarch/other_pages/colors.dart';
import 'package:monarch/support/fetch_service.dart';
import 'package:monarch/main_pages/HomePage/hero_card.dart';
import 'package:monarch/main_pages/HomePage/quick_actions.dart';
import 'package:monarch/support/transcations_recent.dart';

class FinTrackHomePage extends StatefulWidget {
  const FinTrackHomePage({super.key});

  @override
  State<FinTrackHomePage> createState() => _FinTrackHomePageState();
}

class _FinTrackHomePageState extends State<FinTrackHomePage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  int _selectedIndex = 0;
  String _greetingText = '';

  @override
  void initState() {
    super.initState();
    _initializeData();
    _setupAnimations();
    _updateGreeting();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _initializeData() {
    fetchRecentTransactions().then((transactions) {
      // Handle transactions data
    });
  }

  void _updateGreeting() {
    final now = DateTime.now();
    final hour = now.hour;

    if (hour >= 5 && hour < 12) {
      _greetingText = 'Good Morning';
    } else if (hour >= 12 && hour < 17) {
      _greetingText = 'Good Afternoon';
    } else if (hour >= 17 && hour < 21) {
      _greetingText = 'Good Evening';
    } else {
      _greetingText = 'Good Night';
    }
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOutQuart),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _slideController.forward();
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      _scaleController.forward();
    });
  }

  void _showTransactionEntryDialog(String type) {
    if (type == 'voice') {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (context) => VoiceTransactionDialog(),
      );
    } else {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (context) => EmailTransactionDialog(),
      );
    }
  }

  Widget _buildMainContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedSection(
          delay: 600,
          child: Container(
            margin: const EdgeInsets.only(bottom: 32),
            child: const BalanceCardPage(),
          ),
        ),
        AnimatedSection(
          delay: 800,
          child: Container(
            margin: const EdgeInsets.only(bottom: 32),
            child: QuickActionsPage(),
          ),
        ),
        AnimatedSection(
          delay: 1000,
          child: Container(
            margin: const EdgeInsets.only(bottom: 32),
            child: RecentTransactionsWidget(
              recentTransactions: fetchRecentTransactions(),
            ),
          ),
        ),
        const SizedBox(height: 120),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: RefreshIndicator(
              onRefresh: () async {
                _initializeData();
                _updateGreeting();
                setState(() {});
              },
              color: accentColor,
              backgroundColor: cardColor,
              strokeWidth: 2.5,
              displacement: 60,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                slivers: [
                  SliverToBoxAdapter(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            backgroundColor,
                            backgroundColor.withOpacity(0.95),
                          ],
                          stops: const [0.0, 1.0],
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          24,
                          20,
                          24,
                          80,
                        ), // Added bottom padding for navbar
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GreetingHeader(
                              greetingText: _greetingText,
                              scaleAnimation: _scaleAnimation,
                              onEmailPressed:
                                  () => _showTransactionEntryDialog('email'),
                              onVoicePressed:
                                  () => _showTransactionEntryDialog('voice'),
                            ),
                            _buildMainContent(),
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
      ),
      // Use bottomNavigationBar instead of floatingActionButton
      bottomNavigationBar: CustomNavBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
        },
        backgroundColor: backgroundColor,
        accentColor: accentColor,
        primaryColor: primaryColor,
        cardColor: cardColor,
      ),
    );
  }
}

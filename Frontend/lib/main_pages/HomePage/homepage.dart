// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:monarch/main_pages/HomePage/Backend_Support/fetch_service.dart';
import 'package:monarch/main_pages/HomePage/Backend_Support/transcations_recent.dart';
import 'package:monarch/main_pages/HomePage/Components/Email/e_dialog.dart';
import 'package:monarch/main_pages/HomePage/animated.dart';
import 'package:monarch/main_pages/HomePage/Components/Home/greeting.dart';
import 'package:monarch/main_pages/HomePage/Components/Home/navbar.dart';
import 'package:monarch/main_pages/HomePage/Components/Voice/voice_dialog.dart';
import 'package:monarch/other_pages/colors.dart';
import 'package:monarch/main_pages/HomePage/Components/Manual/add_expense.dart';

import 'package:shared_preferences/shared_preferences.dart';

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

  Future<void> _updateGreeting() async {
    final now = DateTime.now();
    final hour = now.hour;
    final prefs = await SharedPreferences.getInstance();
    String? name = prefs.getString('name');
    String firstName = (name ?? "User").split(' ').first;

    String greeting;
    if (hour >= 5 && hour < 12) {
      greeting = 'Good Morning, $firstName';
    } else if (hour >= 12 && hour < 17) {
      greeting = 'Good Afternoon, $firstName';
    } else if (hour >= 17 && hour < 21) {
      greeting = 'Good Evening, $firstName';
    } else {
      greeting = 'Good Night, $firstName';
    }
    setState(() {
      _greetingText = greeting;
    });
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
    } else if (type == 'email') {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (context) => EmailTransactionDialog(),
      );
    } else {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (context) => AddExpenseScreen(),
      );
    }
  }

  Widget _buildMainContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedSection(
          delay: 1000,
          child: Container(
            margin: const EdgeInsets.only(bottom: 32),
            child: RecentTransactionsWidget(
              recentTransactions: fetchRecentTransactions(),
            ),
          ),
        ),
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
                              onManualPressed:
                                  () => _showTransactionEntryDialog('manual'),
                            ),
                            const SizedBox(height: 45),
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
        floatingActionButtonLocation: FloatingActionButtonLocation.centerTop,
      ),
    );
  }
}

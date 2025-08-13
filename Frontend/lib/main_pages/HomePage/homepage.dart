// ignore_for_file: deprecated_member_use, unused_local_variable, use_super_parameters, avoid_print

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monarch/other_pages/colors.dart';
import 'package:monarch/support/fetch_service.dart';
import 'package:monarch/main_pages/HomePage/hero_card.dart';
import 'package:monarch/main_pages/HomePage/navbar.dart';
import 'package:monarch/main_pages/HomePage/quick_actions.dart';
import 'package:monarch/support/transcations_recent.dart';

class FinTrackHomePage extends StatefulWidget {
  const FinTrackHomePage({Key? key}) : super(key: key);

  @override
  State<FinTrackHomePage> createState() => _FinTrackHomePageState();
}

class _FinTrackHomePageState extends State<FinTrackHomePage>
    with TickerProviderStateMixin {

  // Animation Controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Navigation State
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeData();
    _setupAnimations();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  // Initialize data fetching
  void _initializeData() {
    fetchRecentTransactions().then((transactions) {
      // Handle transactions data
    });
  }

  // Setup animation controllers and animations
  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    // Start animations
    _fadeController.forward();
    _slideController.forward();
  }

  // Build greeting header with enhanced styling
  Widget _buildGreetingHeader() {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Greeting Section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good Morning! 👋',
                  style: GoogleFonts.inter(
                    color: primaryColor,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Welcome back to your financial dashboard',
                  style: GoogleFonts.inter(
                    color: primaryColor.withOpacity(0.7),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),

          // Notification Button with enhanced design
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: accentColor.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () {
                  // Handle notification tap
                },
                child: Icon(
                  Icons.notifications_outlined,
                  color: accentColor,
                  size: 26,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Build main content sections
  Widget _buildMainContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Balance Card Section
        Container(
          margin: const EdgeInsets.only(bottom: 28),
          child: const BalanceCardPage(),
        ),

        // Quick Actions Section
        Container(
          margin: const EdgeInsets.only(bottom: 28),
          child: QuickActionsPage(),
        ),

        // Recent Transactions Section
        Container(
          margin: const EdgeInsets.only(bottom: 32),
          child: RecentTransactionsWidget(
            recentTransactions: fetchRecentTransactions(),
          ),
        ),

        // Bottom spacing for FAB
        const SizedBox(height: 100),
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
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildGreetingHeader(),
                        _buildMainContent(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      // Enhanced Floating Action Button
      floatingActionButton: CustomNavBar(
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

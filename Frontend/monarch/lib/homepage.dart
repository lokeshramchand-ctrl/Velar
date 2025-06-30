// ignore_for_file: deprecated_member_use, unused_local_variable, use_super_parameters, avoid_print


import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monarch/colors.dart';
import 'package:monarch/fetch_service.dart';
import 'package:monarch/hero_card.dart';
import 'package:monarch/navbar.dart';
import 'package:monarch/quick_actions.dart';
import 'package:monarch/transcations_recent.dart';
//import 'package:monarch/static.dart';

class FinTrackHomePage extends StatefulWidget {
  const FinTrackHomePage({Key? key}) : super(key: key);

  @override
  State<FinTrackHomePage> createState() => _FinTrackHomePageState();
}

class _FinTrackHomePageState extends State<FinTrackHomePage>
    with TickerProviderStateMixin {
  // Modern color palette

  // List to hold recent transactions


  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Sample data for dashboard

  @override
  void initState() {
    super.initState();
    fetchRecentTransactions().then((transactions) {
      // Do something with the transactions
    });

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
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    // Start animations
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Good Morning! 👋',
                            style: GoogleFonts.inter(
                              color: primaryColor,
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: accentColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Icons.notifications_outlined,
                          color: accentColor,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const BalanceCardPage(),
                  const SizedBox(height: 24),
                  QuickActionsPage(),
                  const SizedBox(height: 24),
                  RecentTransactionsWidget(
                    recentTransactions: fetchRecentTransactions(),
                  ),
                  const SizedBox(height: 24),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),

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

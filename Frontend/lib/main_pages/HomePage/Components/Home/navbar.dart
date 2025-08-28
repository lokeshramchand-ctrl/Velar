// ignore_for_file: deprecated_member_use

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:monarch/support/add.dart';
import 'package:monarch/main_pages/HomePage/homepage.dart';
import 'package:monarch/main_pages/Statistics/statistics.dart';

class CustomNavBar extends StatelessWidget {
  final int currentIndex;
  final void Function(int) onTap;
  final Color backgroundColor;
  final Color accentColor;
  final Color primaryColor;
  final Color cardColor;

  const CustomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.backgroundColor,
    required this.accentColor,
    required this.primaryColor,
    required this.cardColor,
    required FloatingActionButtonLocation floatingActionButtonLocation,
  });

  // Navigation items
  final List _navItems = const [
    NavItem(icon: Icons.home_rounded, index: 0, page: FinTrackHomePage()),
    NavItem(icon: Icons.bar_chart_rounded, index: 1, page: Statistics()),
    NavItem(icon: Icons.settings_rounded, index: 2, page: AddExpenseScreen()),
  ];

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        height: 72,
        width: MediaQuery.of(context).size.width * 0.7, // centered & responsive
        decoration: BoxDecoration(
          color: cardColor.withOpacity(0.65),
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.15),
              blurRadius: 30,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(40),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children:
                  _navItems
                      .map((item) => _buildNavItem(context, item))
                      .toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, NavItem item) {
    final isActive = currentIndex == item.index;
    return GestureDetector(
      onTap: () {
        onTap(item.index);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => item.page),
        );
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: isActive ? 38 : 30,
            height: isActive ? 38 : 30,
            decoration: BoxDecoration(
              color:
                  isActive
                      ? primaryColor.withOpacity(0.15)
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              item.icon,
              color: isActive ? primaryColor : primaryColor.withOpacity(0.4),
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: isActive ? accentColor : Colors.transparent,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}

// Nav item model
class NavItem {
  final IconData icon;
  final int index;
  final Widget page;
  const NavItem({required this.icon, required this.index, required this.page});
}

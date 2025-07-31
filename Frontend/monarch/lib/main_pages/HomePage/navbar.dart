// ignore_for_file: deprecated_member_use

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
    required this.cardColor, required FloatingActionButtonLocation floatingActionButtonLocation,
  });

  // Define navigation items configuration
  final List<NavItem> _navItems = const [
    NavItem(
      icon: Icons.home_rounded,
      index: 0,
      page: FinTrackHomePage(),
    ),
    NavItem(
      icon: Icons.bar_chart_rounded,
      index: 1,
      page: Statistics(),
    ),
    NavItem(
      icon: Icons.settings_rounded,
      index: 2,
      page: AddExpenseScreen(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      height: 72,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(36),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.1),
            blurRadius: 30,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ..._navItems.map((item) => _buildNavItem(context, item)),
          _buildAddButton(context),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, NavItem item) {
    final isActive = currentIndex == item.index;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          onTap(item.index);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => item.page),
          );
        },
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isActive ? primaryColor.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            item.icon,
            color: isActive ? primaryColor : primaryColor.withOpacity(0.4),
            size: 24,
          ),
        ),
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: accentColor,
        borderRadius: BorderRadius.circular(20),
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
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddExpenseScreen()),
          ),
          borderRadius: BorderRadius.circular(20),
          child: const Icon(
            Icons.add_rounded,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }
}

// Navigation item model
class NavItem {
  final IconData icon;
  final int index;
  final Widget page;

  const NavItem({
    required this.icon,
    required this.index,
    required this.page,
  });
}

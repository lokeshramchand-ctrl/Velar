// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:monarch/main_pages/HomePage/Components/Manual/add_expense.dart';
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
    return Container(
      color: backgroundColor, // blend with page
      height: 72,
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(0, 0, 0, 34),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children:
            _navItems.map((item) => _buildNavItem(context, item)).toList(),
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
          Icon(
            item.icon,
            color: isActive ? primaryColor : primaryColor.withOpacity(0.4),
            size: 28,
          ),
          const SizedBox(height: 4),
          Container(
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

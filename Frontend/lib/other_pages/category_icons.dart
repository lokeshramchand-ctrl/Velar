import 'package:flutter/material.dart';

IconData getCategoryIcon(String category) {
  switch (category) {
    case 'Food':
      return Icons.restaurant_rounded;
    case 'Shopping':
      return Icons.shopping_bag_rounded;
    case 'Bills':
      return Icons.receipt_rounded;
    case 'Travel':
      return Icons.flight_rounded;
    case 'Entertainment':
      return Icons.movie_rounded;
    default:
      return Icons.category_rounded;
  }
}

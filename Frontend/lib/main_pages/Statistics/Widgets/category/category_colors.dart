// lib/utils/category_utils.dart
import 'package:flutter/material.dart';

Color getCategoryColor(String category) {
  switch (category) {
    case 'Food':
      return const Color(0xFFE17055);
    case 'Shopping':
      return const Color(0xFF6C5CE7);
    case 'Bills':
      return const Color(0xFF0984E3);
    case 'Travel':
      return const Color(0xFF00B894);
    case 'Entertainment':
      return const Color(0xFFE84393);
    default:
      return const Color(0xFFB2BEC3); // fallback muted gray
  }
}

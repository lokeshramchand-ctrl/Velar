import 'dart:ui';

class CategoryUtils {
  static final List<Color> _colors = [
    const Color(0xFF6C5CE7),
    const Color(0xFFE17055),
    const Color(0xFF00B894),
    const Color(0xFF0984E3),
    const Color(0xFFE84393),
    const Color(0xFFFD79A8),
    const Color(0xFF6C5CE7),
  ];

  static Color getCategoryColor(String category, List<String> categories) {
    return _colors[categories.indexOf(category) % _colors.length];
  }
}

import 'package:flutter/material.dart';

extension ResponsiveExtension on BuildContext {
  double responsiveWidth(double size) {
    return size * (MediaQuery.of(this).size.width / 375);
  }

  double responsiveHeight(double size) {
    return size * (MediaQuery.of(this).size.height / 812);
  }

  double responsiveText(double size) {
    final width = MediaQuery.of(this).size.width;
    if (width < 350) return size * 0.9;
    if (width > 600) return size * 1.2;
    return size;
  }
}

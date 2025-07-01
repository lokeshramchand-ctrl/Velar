import 'package:flutter/material.dart';

class ResponsiveUtils {
  static double responsiveWidth(double size, BuildContext context) =>
      size * (MediaQuery.of(context).size.width / 375);

  static double responsiveHeight(double size, BuildContext context) =>
      size * (MediaQuery.of(context).size.height / 812);

  static double responsiveText(double size, BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 350) return size * 0.9;
    if (width > 600) return size * 1.2;
    return size;
  }
}

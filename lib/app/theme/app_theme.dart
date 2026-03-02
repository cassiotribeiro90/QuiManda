
import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFFC82158);
  static const Color secondaryColor = Color(0xFF274084);
  static const Color surfaceColor = Color(0xFFFFFFFF);

  static ThemeData get theme {
    return ThemeData(
      primaryColor: primaryColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
      ),
      scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
    );
  }
}

import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: const Color(0xFFF5F7FA),

    colorScheme: const ColorScheme.light(
      primary: Color(0xFF2ECC71), // Emerald Green
      secondary: Color(0xFF00BFFF), // Electric Blue
      error: Colors.red,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF2ECC71),
      foregroundColor: Colors.white,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    scaffoldBackgroundColor: const Color(0xFF121212),

    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF2ECC71),
      secondary: Color(0xFF00BFFF),
      error: Colors.red,
    ),
  );
}

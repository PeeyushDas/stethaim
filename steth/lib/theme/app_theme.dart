// lib/theme/app_theme.dart

import 'package:flutter/material.dart';

class AppTheme {
  // Define your color palette
  static const Color primaryColor = Color(0xFF0066CC);
  static const Color accentColor = Color(0xFFFFA000);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color errorColor = Color(0xFFD32F2F);

  // Light Theme
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primaryColor,
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: accentColor,
      background: backgroundColor,
      error: errorColor,
    ),
    scaffoldBackgroundColor: backgroundColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 2,
    ),
    textTheme: _textTheme,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: primaryColor),
      ),
    ),
  );

  // Centralized text styles
  static const TextTheme _textTheme = TextTheme(
    headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
    headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
    bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
    bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
    labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
  );
}

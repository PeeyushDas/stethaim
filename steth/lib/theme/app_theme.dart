// lib/theme/app_theme.dart

import 'package:flutter/material.dart';

class AppTheme {
  // Define your color palette
  static const Color primaryColor = Color(0xFF912611);
  static const Color secondaryColor = Color(0xFF0F5E84);
  static const Color backgroundColor = Color(0xFFF8F8F8);
  static const Color accent1Color = Color(0xFF1148B3);
  static const Color accent2Color = Color(0xFFE5BD1C);
  static const Color accent3Color = Color(0xFF139846);
  static const Color accent4Color = Color(0xFFBC2C2C);
  static const Color neutral1Color = Color(0xFF191919);
  static const Color neutral2Color = Color(0xFF333333);
  static const Color neutral3Color = Color(0xFF808080);
  static const Color neutral4Color = Color(0xFFB3B3B3);
  static const Color neutral5Color = Color(0xFFD9D9D9);

  // Light Theme
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primaryColor,
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: backgroundColor,
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

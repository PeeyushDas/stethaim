// lib/constants/app_constants.dart

import 'package:flutter/material.dart';

class AppConstants {
  // App Information
  static const String appName = 'Stethaim';
  static const String appVersion = '1.0.0';

  // colors
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

  // API Endpoints
  static const String baseUrl = 'https://api.example.com/';
  static const String loginEndpoint = '${baseUrl}auth/login';
  static const String registerEndpoint = '${baseUrl}auth/register';
  static const String userProfileEndpoint = '${baseUrl}user/profile';

  // Storage Keys
  static const String tokenKey = 'TOKEN_KEY';
  static const String userIdKey = 'USER_ID_KEY';

  // Padding and Spacing
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 32.0;

  // Durations
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration splashDelay = Duration(seconds: 5);

  // Error Messages
  static const String networkError = 'Network error. Please try again.';
  static const String unknownError =
      'Something went wrong. Please try again later.';

  // Image Paths
  static const String logoPath = 'assets/images/logo.png';
  static const String placeholderImage = 'assets/images/placeholder.png';

  // Supported Locales
  static const List<Locale> supportedLocales = [
    Locale('en', 'US'),
    Locale('hi', 'IN'),
  ];
}

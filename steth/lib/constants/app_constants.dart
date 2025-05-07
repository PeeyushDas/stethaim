// lib/constants/app_constants.dart

import 'package:flutter/material.dart';

class AppConstants {
  // App Information
  static const String appName = 'MyFlutterApp';
  static const String appVersion = '1.0.0';

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
  static const Duration splashDelay = Duration(seconds: 2);

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

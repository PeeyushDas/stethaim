import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stethaim/src/presentation/splash_screen.dart';
import 'package:stethaim/src/presentation/welcome_screen.dart';
import 'package:stethaim/src/presentation/otp_screen.dart';
import 'package:stethaim/src/presentation/scan_screen.dart';
import 'package:stethaim/src/presentation/report_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

final GoRouter router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  debugLogDiagnostics: true,
  routes: [
    GoRoute(
      path: '/',
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/phone',
      name: 'phone',
      builder: (context, state) => const PhoneVerificationScreen(),
    ),
    GoRoute(
      path: '/otp/:phoneNumber',
      name: 'otp',
      builder: (context, state) {
        final phoneNumber = state.pathParameters['phoneNumber'] ?? '';
        return OtpVerificationScreen(phoneNumber: phoneNumber);
      },
    ),
    GoRoute(
      path: '/scan',
      name: 'scan',
      builder: (context, state) => const ScanningScreen(),
    ),
    GoRoute(
      path: '/report',
      name: 'report',
      builder: (context, state) => const LungsReportScreen(),
    ),
  ],
);

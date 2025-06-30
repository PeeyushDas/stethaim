import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stethaim/models/patient.dart';
import 'package:stethaim/src/presentation/add_patient.dart';
import 'package:stethaim/src/presentation/home_page.dart';
import 'package:stethaim/src/presentation/patient_details.dart';
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
      path: '/home',
      name: 'home',
      builder: (context, state) => const AllPatientsScreen(),
    ),
    GoRoute(
      path: '/add_patient',
      name: 'add_patient',
      builder: (context, state) => const AddPatientScreen(),
    ),
    GoRoute(
      path: '/patient_details/:patientId',
      name: 'patient_details',
      builder: (context, state) {
        final patientId = state.pathParameters['patientId'] ?? '';
        final patient = state.extra as Patient?;
        return PatientDetailsScreen(patientId: patientId, patient: patient);
      },
    ),
    GoRoute(
      path: '/scan/:patientId',
      name: 'scan',
      builder: (context, state) {
        final patientId = state.pathParameters['patientId'] ?? '';
        final patient = state.extra as Patient?;
        return ScanningScreen(patientId: patientId, patient: patient);
      },
    ),
    GoRoute(
      path: '/report/:patientId',
      name: 'report',
      builder: (context, state) {
        final patientId = state.pathParameters['patientId'] ?? '';
        final patient = state.extra as Patient?;
        return LungsReportScreen(patientId: patientId, patient: patient);
      },
    ),
  ],
);

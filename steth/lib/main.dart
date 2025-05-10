import 'package:flutter/material.dart';
import 'package:stethaim/constants/app_constants.dart';
import 'package:stethaim/theme/text_theme.dart';
import 'package:stethaim/utils/size_config.dart';
import 'package:stethaim/router.dart'; // Import the new router

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConstants.appName,
      theme: ThemeData(
        primaryColor: AppConstants.primaryColor,
        colorScheme: ColorScheme.fromSeed(seedColor: AppConstants.primaryColor),
        extensions: [AppTypography.of(context)],
      ),
      routerConfig: router, // Use the Go Router config
      builder: (context, child) {
        SizeConfig.init(context); // Initialize SizeConfig once here
        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 600 * SizeConfig.blockSizeHorizontal,
            ),
            child: child!,
          ),
        );
      },
    );
  }
}

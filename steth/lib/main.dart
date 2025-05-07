import 'package:flutter/material.dart';
import 'package:stethaim/constants/app_constants.dart';
import 'package:stethaim/src/presentation/splash_screen.dart';
import 'package:stethaim/theme/text_theme.dart';
import 'package:stethaim/utils/size_config.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    return MaterialApp(
      title: AppConstants.appName,
      theme: ThemeData(
        primaryColor: AppConstants.primaryColor,
        colorScheme: ColorScheme.fromSeed(seedColor: AppConstants.primaryColor),
        extensions: [AppTypography.of(context)],
      ),
      builder: (context, child) {
        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 600 * SizeConfig.blockSizeHorizontal,
            ),
            child: child!,
          ),
        );
      },
      home: const SplashScreen(),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:stethaim/theme/app_theme.dart';
import 'package:stethaim/theme/text_theme.dart';
import 'package:stethaim/utils/size_config.dart';

Widget buildEmptyState(BuildContext context) {
  return Center(
    child: Padding(
      padding: EdgeInsets.all(8 * SizeConfig.blockSizeHorizontal),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Doctor illustration
          SvgPicture.asset(
            'assets/Doctors.svg', // Add your SVG asset
            height: 40 * SizeConfig.blockSizeVertical,
            width: 60 * SizeConfig.blockSizeHorizontal,
            fit: BoxFit.contain,
          ),

          SizedBox(height: 4 * SizeConfig.blockSizeVertical),

          // Main message
          Text(
            'Add your first patient and start tracking medical history.',
            style: Theme.of(context)
                .extension<AppTypography>()!
                .heading5MediumWithColor(AppTheme.neutral2Color),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 4 * SizeConfig.blockSizeVertical),

          // Add Patient button
          SizedBox(
            width: double.infinity,
            height: 6 * SizeConfig.blockSizeVertical,
            child: ElevatedButton(
              onPressed: () {
                context.go('/add_patient');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    1 * SizeConfig.blockSizeHorizontal,
                  ),
                ),
              ),
              child: Text(
                'Add Patient',
                style: Theme.of(context)
                    .extension<AppTypography>()!
                    .body1SemiBoldWithColor(Colors.white),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

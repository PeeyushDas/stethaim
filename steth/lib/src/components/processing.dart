import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:stethaim/theme/text_theme.dart';
import 'package:stethaim/utils/size_config.dart';

class AnalyzingResultsDialog extends StatelessWidget {
  const AnalyzingResultsDialog({Key? key}) : super(key: key);

  static Future<void> show(
    BuildContext context, {
    VoidCallback? onDownloadPressed,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AnalyzingResultsDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Container(
        width: SizeConfig.blockSizeHorizontal * 80,
        padding: EdgeInsets.symmetric(
          vertical: SizeConfig.blockSizeVertical * 3,
          horizontal: SizeConfig.blockSizeHorizontal * 5,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Lottie animation
            SizedBox(
              height: SizeConfig.blockSizeHorizontal * 40,
              width: SizeConfig.blockSizeHorizontal * 40,
              child: Lottie.asset(
                'assets/processing.json',
                fit: BoxFit.contain,
                repeat: true,
              ),
            ),

            SizedBox(height: SizeConfig.blockSizeVertical * 2),

            // Title
            Text(
              'Analyzing Results',
              style:
                  Theme.of(
                    context,
                  ).extension<AppTypography>()!.heading3SemiBold,
            ),

            SizedBox(height: SizeConfig.blockSizeVertical * 1.5),

            // Description
            Text(
              'We are processing your lung scan.\nThis may take a few moments.',
              textAlign: TextAlign.center,
              style:
                  Theme.of(context).extension<AppTypography>()!.heading5Medium,
            ),
          ],
        ),
      ),
    );
  }
}

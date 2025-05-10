import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:stethaim/constants/app_constants.dart';
import 'package:stethaim/src/components/processing.dart';
import 'package:stethaim/utils/size_config.dart';
import 'package:stethaim/theme/text_theme.dart';
import 'package:go_router/go_router.dart';

class LungsReportScreen extends StatefulWidget {
  const LungsReportScreen({Key? key}) : super(key: key);

  @override
  State<LungsReportScreen> createState() => _LungsReportScreenState();
}

class _LungsReportScreenState extends State<LungsReportScreen> {
  Timer? _dialogTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showAnalyzingDialog();
    });
  }

  @override
  void dispose() {
    _dialogTimer?.cancel();
    super.dispose();
  }

  void _showAnalyzingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        _dialogTimer = Timer(Duration(seconds: 5), () {
          if (dialogContext.mounted) {
            Navigator.of(dialogContext).pop();
          }
        });

        return AnalyzingResultsDialog();
      },
    ).then((_) {
      // Ensure timer is canceled if dialog is dismissed another way
      _dialogTimer?.cancel();
      _dialogTimer = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    // Report data
    final List<Map<String, dynamic>> reportData = [
      {'site': 1, 'position': 'Lower lobe', 'status': 'Normal'},
      {'site': 2, 'position': 'Upper lobe', 'status': 'Abnormal'},
      {'site': 3, 'position': 'Right primary bronchus', 'status': 'Normal'},
      {'site': 4, 'position': 'Upper lobe back', 'status': 'Normal'},
      {'site': 5, 'position': 'Left lobe', 'status': 'Normal'},
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.go('/scan'),
        ),
        title: Text(
          'Lungs Report',
          style: Theme.of(context).extension<AppTypography>()!.heading5SemiBold,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: SizeConfig.blockSizeHorizontal * 5,
          ),
          child: Column(
            children: [
              // Doctor illustration
              Container(
                margin: EdgeInsets.symmetric(
                  vertical: SizeConfig.blockSizeVertical * 2,
                ),
                padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal * 2),

                child: SvgPicture.asset(
                  'assets/report.svg',
                  height: SizeConfig.blockSizeVertical * 20,
                  fit: BoxFit.contain,
                ),
              ),

              // Table headers
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.blockSizeHorizontal * 2,
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: SizeConfig.blockSizeHorizontal * 13,
                      child: Text(
                        'Site of marking',
                        style: Theme.of(context)
                            .extension<AppTypography>()!
                            .body2SemiBoldWithColor(AppConstants.neutral3Color),
                      ),
                    ),
                    SizedBox(width: SizeConfig.blockSizeHorizontal * 10),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Position',
                        style: Theme.of(context)
                            .extension<AppTypography>()!
                            .body2SemiBoldWithColor(AppConstants.neutral3Color),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        'Status',
                        style: Theme.of(context)
                            .extension<AppTypography>()!
                            .body2SemiBoldWithColor(AppConstants.neutral3Color),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ),

              // Report data rows
              Expanded(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: reportData.length,
                  separatorBuilder:
                      (context, index) =>
                          Divider(color: AppConstants.neutral5Color),
                  itemBuilder: (context, index) {
                    final item = reportData[index];
                    final bool isAbnormal = item['status'] == 'Abnormal';

                    return Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: SizeConfig.blockSizeVertical * 1.5,
                        horizontal: SizeConfig.blockSizeHorizontal * 2,
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: SizeConfig.blockSizeHorizontal * 10,
                            child: Text(
                              item['site'].toString(),
                              style:
                                  Theme.of(
                                    context,
                                  ).extension<AppTypography>()!.body1Medium,
                            ),
                          ),
                          SizedBox(width: SizeConfig.blockSizeHorizontal * 10),
                          Expanded(
                            flex: 2,
                            child: Text(
                              item['position'],
                              style:
                                  Theme.of(
                                    context,
                                  ).extension<AppTypography>()!.body1Medium,
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              item['status'],
                              style: Theme.of(context)
                                  .extension<AppTypography>()!
                                  .body1MediumWithColor(
                                    isAbnormal
                                        ? AppConstants.accent4Color
                                        : AppConstants.accent3Color,
                                  ),

                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Action buttons
              Padding(
                padding: EdgeInsets.only(
                  bottom: SizeConfig.blockSizeVertical * 2,
                ),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: SizeConfig.blockSizeVertical * 6,
                      child: ElevatedButton(
                        onPressed: () {
                          // Download report logic
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppConstants.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        child: Text(
                          'Download Report',
                          style: Theme.of(context)
                              .extension<AppTypography>()!
                              .body1SemiBoldWithColor(Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(height: SizeConfig.blockSizeVertical * 1.5),
                    SizedBox(
                      width: double.infinity,
                      height: SizeConfig.blockSizeVertical * 6,
                      child: OutlinedButton(
                        onPressed: () {
                          context.go('/scan');
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppConstants.primaryColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.refresh,
                              color: AppConstants.primaryColor,
                              size: SizeConfig.blockSizeHorizontal * 5,
                            ),
                            SizedBox(width: SizeConfig.blockSizeHorizontal * 2),
                            Text(
                              'Scan Again',
                              style: Theme.of(context)
                                  .extension<AppTypography>()!
                                  .body1SemiBoldWithColor(
                                    AppConstants.primaryColor,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

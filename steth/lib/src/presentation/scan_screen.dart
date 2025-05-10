import 'package:flutter/material.dart';
import 'package:stethaim/src/components/frontal_view.dart';
import 'package:stethaim/theme/text_theme.dart';
import 'package:stethaim/utils/size_config.dart';
import 'package:stethaim/constants/app_constants.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:go_router/go_router.dart';

class ScanningScreen extends StatefulWidget {
  const ScanningScreen({Key? key}) : super(key: key);

  @override
  State<ScanningScreen> createState() => _ScanningScreenState();
}

class _ScanningScreenState extends State<ScanningScreen> {
  bool _isScanning = false;
  bool _hasStartedScanning = false;
  int _currentLobeIndex = 0;
  final CountDownController _countDownController = CountDownController();
  final int _duration = 5;

  // For the specific indicator point
  final List<Map<String, dynamic>> _lobes = [
    {
      'imagePath': 'assets/lower_lobe.svg',
      'baseImagePath': 'assets/front.png',
      'xCoordinate': 23.0,
      'yCoordinate': 9.0,
      'label': 'Lower lobe',
    },
    {
      'imagePath': 'assets/upper_lobe.svg',
      'baseImagePath': 'assets/front.png',
      'xCoordinate': 23.0,
      'yCoordinate': 3.0,
      'label': 'Upper lobe',
    },
    {
      'imagePath': 'assets/r_prim_broc.svg',
      'baseImagePath': 'assets/front.png',
      'xCoordinate': 3.5,
      'yCoordinate': 3.0,
      'label': 'Primary bronchus',
    },
    {
      'imagePath': 'assets/upper_lobe_back.svg',
      'baseImagePath': 'assets/back.png',
      'xCoordinate': 22.5,
      'yCoordinate': 4.0,
      'label': 'Upper lobe (back)',
    },
    {
      'imagePath': 'assets/left_lobe.svg',
      'baseImagePath': 'assets/back.png',
      'xCoordinate': 0.0,
      'yCoordinate': 9.0,
      'label': 'Left lobe',
    },
    {
      'imagePath': 'assets/lower_lobe_back.svg',
      'baseImagePath': 'assets/back.png',
      'xCoordinate': 23.0,
      'yCoordinate': 9.0,
      'label': 'Lower lobe (back)',
    },
  ];

  void _handlePrimaryButtonPress() {
    if (!_hasStartedScanning) {
      // First time pressing Start Scanning
      setState(() {
        _hasStartedScanning = true;
        _isScanning = true;
      });
      _countDownController.start();
    } else if (!_isScanning) {
      // Pressing Next after scan completion
      if (_currentLobeIndex < _lobes.length - 1) {
        // Move to next lobe
        setState(() {
          _currentLobeIndex++;
        });
        _countDownController.restart();
      } else {
        // All lobes scanned, show results
        _navigateToResults();
      }
    }
  }

  void _handleSecondaryButtonPress() {
    if (!_hasStartedScanning) {
      // Back button before any scanning
      context.go('/phone');
    } else {
      // Scan Again button after scanning has started
      _countDownController.restart();
      setState(() {
        _isScanning = true;
      });
    }
  }

  void _navigateToResults() {
    // Navigate to results page
    context.go('/report');
  }

  String _getPrimaryButtonText() {
    if (!_hasStartedScanning) {
      return 'Start Scanning';
    } else if (_currentLobeIndex == _lobes.length - 1 && !_isScanning) {
      return 'Show Results';
    } else {
      return 'Next';
    }
  }

  String _getSecondaryButtonText() {
    return _hasStartedScanning ? '⟳ Scan Again' : 'Back';
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.go('/phone'),
        ),
        title: Text(
          'Scanning Lungs',
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
              // Anatomy visualization with indicator
              SizedBox(
                height: SizeConfig.screenHeight * 0.35,
                child: StackedSvgImages(
                  upperImagePath: _lobes[_currentLobeIndex]['imagePath'],
                  xCoordinate: _lobes[_currentLobeIndex]['xCoordinate'],
                  yCoordinate: _lobes[_currentLobeIndex]['yCoordinate'],
                  lowerImagePath: _lobes[_currentLobeIndex]['baseImagePath'],
                ),

                // Label with arrow
              ),

              // Instruction text
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: SizeConfig.blockSizeVertical * 2,
                ),
                child: Text(
                  'Place the Neumo Rex at the indicated place & tap "Start Scanning"',
                  textAlign: TextAlign.center,
                  style:
                      Theme.of(
                        context,
                      ).extension<AppTypography>()!.heading5Medium,
                ),
              ),

              // Circular Countdown Timer
              CircularCountDownTimer(
                duration: _duration,
                initialDuration: 0,
                controller: _countDownController,
                width: SizeConfig.blockSizeHorizontal * 50,
                height: SizeConfig.blockSizeHorizontal * 50,
                ringColor: Colors.grey.withOpacity(0.3),
                fillColor: AppConstants.primaryColor,
                backgroundColor: Colors.white,
                strokeWidth: 4.0,
                strokeCap: StrokeCap.round,
                textStyle: TextStyle(
                  fontSize: SizeConfig.textMultiplier * 3.5,
                  fontWeight: FontWeight.w300,
                  color: AppConstants.primaryColor,
                ),
                textFormat: CountdownTextFormat.MM_SS,
                isReverse: false,
                isReverseAnimation: false,
                isTimerTextShown: true,
                autoStart: false,
                onStart: () {
                  setState(() {
                    _isScanning = true;
                  });
                },
                onComplete: () {
                  setState(() {
                    _isScanning = false;
                  });
                },
              ),

              Spacer(),

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
                        onPressed:
                            _isScanning ? null : _handlePrimaryButtonPress,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppConstants.primaryColor,
                          disabledBackgroundColor: AppConstants.primaryColor
                              .withOpacity(0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        child: Text(
                          _getPrimaryButtonText(),
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
                        onPressed: _handleSecondaryButtonPress,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppConstants.primaryColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        child: Text(
                          _getSecondaryButtonText(),
                          style: Theme.of(
                            context,
                          ).extension<AppTypography>()!.body1SemiBoldWithColor(
                            AppConstants.primaryColor,
                          ),
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

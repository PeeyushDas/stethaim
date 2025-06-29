import 'package:flutter/material.dart';
import 'package:stethaim/src/components/frontal_view.dart';
import 'package:stethaim/theme/text_theme.dart';
import 'package:stethaim/utils/size_config.dart';
import 'package:stethaim/constants/app_constants.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:go_router/go_router.dart';
import 'package:stethaim/src/components/bluetooth_connection.dart';
import 'package:stethaim/models/patient.dart';

class ScanningScreen extends StatefulWidget {
  final String? patientId;
  final Patient? patient;

  const ScanningScreen({Key? key, this.patientId, this.patient})
    : super(key: key);

  @override
  State<ScanningScreen> createState() => _ScanningScreenState();
}

class _ScanningScreenState extends State<ScanningScreen> {
  bool _isScanning = false;
  bool _hasStartedCurrentLobe = false; // Track if current lobe scan has started
  bool _hasCompletedCurrentLobe =
      false; // Track if current lobe scan is completed
  int _currentLobeIndex = 0;
  final CountDownController _countDownController = CountDownController();
  final int _duration = 5;

  @override
  void initState() {
    super.initState();

    // Show dialog after the build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NeumorexConnectionDialogs.showBluetoothPromptDialog(context);
    });
  }

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

  void _handleStartButtonPress() {
    // Start scanning for current lobe
    setState(() {
      _hasStartedCurrentLobe = true;
      _isScanning = true;
      _hasCompletedCurrentLobe = false;
    });
    _countDownController.start();
  }

  void _handleNextButtonPress() {
    // Move to next lobe
    if (_currentLobeIndex < _lobes.length - 1) {
      setState(() {
        _currentLobeIndex++;
        _hasStartedCurrentLobe = false;
        _hasCompletedCurrentLobe = false;
        _isScanning = false;
      });
      _countDownController.reset();
    } else {
      // All lobes scanned, show results
      _navigateToResults();
    }
  }

  void _handleScanAgainButtonPress() {
    // Restart current lobe scan
    setState(() {
      _hasStartedCurrentLobe = false;
      _hasCompletedCurrentLobe = false;
      _isScanning = false;
    });
    _countDownController.reset();
  }

  void _handleBackButtonPress() {
    if (widget.patientId != null) {
      context.go('/patient_details/${widget.patientId}', extra: widget.patient);
    } else {
      context.go('/home');
    }
  }

  void _navigateToResults() {
    // Navigate to results page with patient context
    if (widget.patientId != null) {
      context.go('/report/${widget.patientId}', extra: widget.patient);
    } else {
      // Fallback if no patient context
      context.go('/home');
    }
  }

  String _getPrimaryButtonText() {
    if (!_hasStartedCurrentLobe) {
      return 'Start Scanning';
    } else if (_hasCompletedCurrentLobe) {
      if (_currentLobeIndex == _lobes.length - 1) {
        return 'Show Results';
      } else {
        return 'Next';
      }
    } else {
      return 'Scanning...'; // This won't be clickable
    }
  }

  String _getSecondaryButtonText() {
    if (!_hasStartedCurrentLobe) {
      return 'Back';
    } else {
      return '⟳ Scan Again';
    }
  }

  bool _isPrimaryButtonEnabled() {
    return !_isScanning; // Disabled only while actively scanning
  }

  void _handlePrimaryButtonPress() {
    if (!_hasStartedCurrentLobe) {
      _handleStartButtonPress();
    } else if (_hasCompletedCurrentLobe) {
      _handleNextButtonPress();
    }
    // Do nothing if currently scanning
  }

  void _handleSecondaryButtonPress() {
    if (!_hasStartedCurrentLobe) {
      _handleBackButtonPress();
    } else {
      _handleScanAgainButtonPress();
    }
  }

  String _getInstructionText() {
    if (!_hasStartedCurrentLobe) {
      return 'Place the Neumo Rex at the indicated place & tap "Start Scanning"';
    } else if (_isScanning) {
      return 'Keep the stethoscope steady. Scanning in progress...';
    } else if (_hasCompletedCurrentLobe) {
      if (_currentLobeIndex == _lobes.length - 1) {
        return 'Scan completed! Tap "Show Results" to view the report.';
      } else {
        return 'Scan completed! Tap "Next" to scan the next area or "Scan Again" to repeat.';
      }
    }
    return '';
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
          onPressed: () {
            if (widget.patientId != null) {
              context.go(
                '/patient_details/${widget.patientId}',
                extra: widget.patient,
              );
            } else {
              context.go('/home');
            }
          },
        ),
        title: Text(
          widget.patient != null
              ? 'Scanning ${widget.patient!.fullName}'
              : 'Scanning Lungs',
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
              // Progress indicator
              Container(
                margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 1),
                padding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.blockSizeHorizontal * 4,
                  vertical: SizeConfig.blockSizeVertical * 1,
                ),
                decoration: BoxDecoration(
                  color: AppConstants.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Area ${_currentLobeIndex + 1} of ${_lobes.length}',
                      style: Theme.of(context)
                          .extension<AppTypography>()!
                          .body2MediumWithColor(AppConstants.primaryColor),
                    ),
                    Text(
                      _lobes[_currentLobeIndex]['label'],
                      style: Theme.of(context)
                          .extension<AppTypography>()!
                          .body2SemiBoldWithColor(AppConstants.primaryColor),
                    ),
                  ],
                ),
              ),

              // Anatomy visualization with indicator
              SizedBox(
                height: SizeConfig.screenHeight * 0.32,
                child: StackedSvgImages(
                  upperImagePath: _lobes[_currentLobeIndex]['imagePath'],
                  xCoordinate: _lobes[_currentLobeIndex]['xCoordinate'],
                  yCoordinate: _lobes[_currentLobeIndex]['yCoordinate'],
                  lowerImagePath: _lobes[_currentLobeIndex]['baseImagePath'],
                ),
              ),

              // Instruction text
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: SizeConfig.blockSizeVertical * 2,
                ),
                child: Text(
                  _getInstructionText(),
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).extension<AppTypography>()!.heading5Medium.copyWith(
                    color:
                        _isScanning
                            ? AppConstants.primaryColor
                            : AppConstants.neutral1Color,
                  ),
                ),
              ),

              // Circular Countdown Timer
              CircularCountDownTimer(
                duration: _duration,
                initialDuration: 0,
                controller: _countDownController,
                width: SizeConfig.blockSizeHorizontal * 45,
                height: SizeConfig.blockSizeHorizontal * 45,
                ringColor: Colors.grey.withOpacity(0.3),
                fillColor: AppConstants.primaryColor,
                backgroundColor: Colors.white,
                strokeWidth: 4.0,
                strokeCap: StrokeCap.round,
                textStyle: TextStyle(
                  fontSize: SizeConfig.textMultiplier * 3.0,
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
                    _hasCompletedCurrentLobe = true;
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
                    // Primary button (Start/Next/Show Results)
                    SizedBox(
                      width: double.infinity,
                      height: SizeConfig.blockSizeVertical * 6,
                      child: ElevatedButton(
                        onPressed:
                            _isPrimaryButtonEnabled()
                                ? _handlePrimaryButtonPress
                                : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppConstants.primaryColor,
                          disabledBackgroundColor: AppConstants.primaryColor
                              .withOpacity(0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (_isScanning) ...[
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                            ],
                            Text(
                              _getPrimaryButtonText(),
                              style: Theme.of(context)
                                  .extension<AppTypography>()!
                                  .body1SemiBoldWithColor(Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: SizeConfig.blockSizeVertical * 1.5),

                    // Secondary button (Back/Scan Again)
                    SizedBox(
                      width: double.infinity,
                      height: SizeConfig.blockSizeVertical * 6,
                      child: OutlinedButton(
                        onPressed: _handleSecondaryButtonPress,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color:
                                _hasStartedCurrentLobe
                                    ? AppConstants.accent2Color
                                    : AppConstants.primaryColor,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        child: Text(
                          _getSecondaryButtonText(),
                          style: Theme.of(
                            context,
                          ).extension<AppTypography>()!.body1SemiBoldWithColor(
                            _hasStartedCurrentLobe
                                ? AppConstants.accent2Color
                                : AppConstants.primaryColor,
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

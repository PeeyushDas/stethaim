import 'package:flutter/material.dart';
import 'package:stethaim/src/components/frontal_view.dart';
import 'package:stethaim/theme/text_theme.dart';
import 'package:stethaim/utils/size_config.dart';
import 'package:stethaim/constants/app_constants.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:go_router/go_router.dart';
import 'package:stethaim/src/components/bluetooth_connection.dart';
import 'package:stethaim/models/patient.dart';
import 'package:stethaim/src/services/audio_recording_service.dart'; // Add this import
import 'dart:async'; // Add this import

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
  bool _hasStartedCurrentLobe = false;
  bool _hasCompletedCurrentLobe = false;
  int _currentLobeIndex = 0;
  final CountDownController _countDownController = CountDownController();
  final int _duration = 5;

  // Add recording service
  final AudioRecordingService _recordingService = AudioRecordingService();
  StreamSubscription<String>? _recordingStatusSubscription;
  String _recordingStatus = '';
  List<String> _recordedFiles = []; // Track recorded files for each lobe

  @override
  void initState() {
    super.initState();

    // Initialize recorded files list
    _recordedFiles = List.filled(_lobes.length, '');

    // Listen to recording status
    _recordingStatusSubscription = _recordingService.recordingStatusStream
        .listen((status) {
          if (mounted) {
            setState(() {
              _recordingStatus = status;
            });

            // Show snackbar for important recording events
            if (status.contains('Recording saved') ||
                status.contains('error') ||
                status.contains('Failed')) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(status),
                  backgroundColor:
                      status.contains('error') || status.contains('Failed')
                          ? AppConstants.accent4Color
                          : AppConstants.accent3Color,
                  duration: Duration(seconds: 3),
                ),
              );
            }
          }
        });

    // Show dialog after the build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NeumorexConnectionDialogs.showBluetoothPromptDialog(context);
    });
  }

  @override
  void dispose() {
    _recordingStatusSubscription?.cancel();
    super.dispose();
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

  void _handleStartButtonPress() async {
    try {
      // Start scanning for current lobe
      setState(() {
        _hasStartedCurrentLobe = true;
        _isScanning = true;
        _hasCompletedCurrentLobe = false;
      });

      // Start recording with custom filename
      String fileName = await _recordingService.startRecording(
        fileName: 'scan_${_currentLobeIndex + 1}',
        patientId: widget.patient?.id ?? widget.patientId ?? 'unknown',
        lobeLabel: _lobes[_currentLobeIndex]['label'],
      );

      print(
        'Recording started for ${_lobes[_currentLobeIndex]['label']}: $fileName',
      );

      // Start the timer
      _countDownController.start();
    } catch (e) {
      print('Error starting recording: $e');

      // Reset state if recording failed
      setState(() {
        _hasStartedCurrentLobe = false;
        _isScanning = false;
        _hasCompletedCurrentLobe = false;
      });

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to start recording: $e'),
          backgroundColor: AppConstants.accent4Color,
        ),
      );
    }
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
      return 'Scanning...';
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
    return !_isScanning;
  }

  void _handlePrimaryButtonPress() {
    if (!_hasStartedCurrentLobe) {
      _handleStartButtonPress();
    } else if (_hasCompletedCurrentLobe) {
      _handleNextButtonPress();
    }
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
      return 'Keep the stethoscope steady. Recording in progress...';
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
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
            size: SizeConfig.imageSizeMultiplier * 6,
          ),
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
          style: Theme.of(context)
              .extension<AppTypography>()!
              .heading5SemiBold
              .copyWith(fontSize: SizeConfig.textMultiplier * 2.2),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Calculate responsive padding based on screen width
            double horizontalPadding =
                SizeConfig.orientation == Orientation.portrait
                    ? SizeConfig.blockSizeHorizontal * 5
                    : SizeConfig.blockSizeHorizontal * 8;

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Column(
                children: [
                  // Progress indicator
                  Container(
                    margin: EdgeInsets.only(
                      top: SizeConfig.blockSizeVertical * 1.5,
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: SizeConfig.blockSizeHorizontal * 4,
                      vertical: SizeConfig.blockSizeVertical * 1.5,
                    ),
                    decoration: BoxDecoration(
                      color: AppConstants.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(
                        SizeConfig.blockSizeHorizontal * 2,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            'Area ${_currentLobeIndex + 1} of ${_lobes.length}',
                            style: Theme.of(context)
                                .extension<AppTypography>()!
                                .body2MediumWithColor(AppConstants.primaryColor)
                                .copyWith(
                                  fontSize: SizeConfig.textMultiplier * 1.8,
                                ),
                          ),
                        ),
                        Flexible(
                          child: Text(
                            _lobes[_currentLobeIndex]['label'],
                            style: Theme.of(context)
                                .extension<AppTypography>()!
                                .body2SemiBoldWithColor(
                                  AppConstants.primaryColor,
                                )
                                .copyWith(
                                  fontSize: SizeConfig.textMultiplier * 1.8,
                                ),
                            textAlign: TextAlign.end,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Recording status indicator
                  if (_recordingStatus.isNotEmpty)
                    Container(
                      margin: EdgeInsets.only(
                        top: SizeConfig.blockSizeVertical * 1.5,
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: SizeConfig.blockSizeHorizontal * 3,
                        vertical: SizeConfig.blockSizeVertical * 1,
                      ),
                      decoration: BoxDecoration(
                        color:
                            _recordingService.isRecording
                                ? AppConstants.accent4Color.withOpacity(0.1)
                                : AppConstants.accent3Color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(
                          SizeConfig.blockSizeHorizontal * 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _recordingService.isRecording
                                ? Icons.fiber_manual_record
                                : Icons.check_circle,
                            color:
                                _recordingService.isRecording
                                    ? AppConstants.accent4Color
                                    : AppConstants.accent3Color,
                            size: SizeConfig.imageSizeMultiplier * 3,
                          ),
                          SizedBox(width: SizeConfig.blockSizeHorizontal * 1.5),
                          Expanded(
                            child: Text(
                              _recordingStatus,
                              style: TextStyle(
                                fontSize: SizeConfig.textMultiplier * 1.4,
                                color:
                                    _recordingService.isRecording
                                        ? AppConstants.accent4Color
                                        : AppConstants.accent3Color,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Anatomy visualization with indicator
                  Container(
                    height:
                        SizeConfig.orientation == Orientation.portrait
                            ? SizeConfig.screenHeight * 0.25
                            : SizeConfig.screenHeight * 0.32,
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(
                      vertical: SizeConfig.blockSizeVertical * 2,
                    ),
                    child: StackedSvgImages(
                      upperImagePath: _lobes[_currentLobeIndex]['imagePath'],
                      xCoordinate: _lobes[_currentLobeIndex]['xCoordinate'],
                      yCoordinate: _lobes[_currentLobeIndex]['yCoordinate'],
                      lowerImagePath:
                          _lobes[_currentLobeIndex]['baseImagePath'],
                    ),
                  ),

                  // Instruction text
                  Container(
                    padding: EdgeInsets.symmetric(
                      vertical: SizeConfig.blockSizeVertical * 0,
                      horizontal: SizeConfig.blockSizeHorizontal * 2,
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
                        fontSize: SizeConfig.textMultiplier * 2.0,
                        height: 1.4,
                      ),
                    ),
                  ),

                  // Circular Countdown Timer
                  Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.symmetric(
                      vertical: SizeConfig.blockSizeVertical * 2,
                    ),
                    child: CircularCountDownTimer(
                      duration: _duration,
                      initialDuration: 0,
                      controller: _countDownController,
                      width:
                          SizeConfig.orientation == Orientation.portrait
                              ? SizeConfig.blockSizeHorizontal * 40
                              : SizeConfig.blockSizeHorizontal * 25,
                      height:
                          SizeConfig.orientation == Orientation.portrait
                              ? SizeConfig.blockSizeHorizontal * 40
                              : SizeConfig.blockSizeHorizontal * 25,
                      ringColor: Colors.grey.withOpacity(0.3),
                      fillColor: AppConstants.primaryColor,
                      backgroundColor: Colors.white,
                      strokeWidth: SizeConfig.blockSizeHorizontal * 1,
                      strokeCap: StrokeCap.round,
                      textStyle: TextStyle(
                        fontSize: SizeConfig.textMultiplier * 3.2,
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
                        print(
                          'Timer started for ${_lobes[_currentLobeIndex]['label']}',
                        );
                      },
                      onComplete: () async {
                        setState(() {
                          _isScanning = false;
                          _hasCompletedCurrentLobe = true;
                        });

                        // Stop recording when timer completes
                        try {
                          String? recordedFile =
                              await _recordingService.stopRecording();
                          if (recordedFile != null) {
                            _recordedFiles[_currentLobeIndex] = recordedFile;
                            print(
                              'Recording completed for ${_lobes[_currentLobeIndex]['label']}: $recordedFile',
                            );
                          }
                        } catch (e) {
                          print('Error stopping recording: $e');
                        }
                      },
                    ),
                  ),

                  // Flexible spacer to push buttons to bottom
                  Expanded(child: SizedBox()),

                  // Action buttons
                  Container(
                    padding: EdgeInsets.only(
                      bottom: SizeConfig.blockSizeVertical * 2,
                    ),
                    child: Column(
                      children: [
                        // Primary button (Start/Next/Show Results)
                        SizedBox(
                          width: double.infinity,
                          height:
                              SizeConfig.orientation == Orientation.portrait
                                  ? SizeConfig.blockSizeVertical * 6.5
                                  : SizeConfig.blockSizeVertical * 8,
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
                                borderRadius: BorderRadius.circular(
                                  SizeConfig.blockSizeHorizontal * 1,
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (_isScanning) ...[
                                  SizedBox(
                                    width: SizeConfig.imageSizeMultiplier * 4,
                                    height: SizeConfig.imageSizeMultiplier * 4,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: SizeConfig.blockSizeHorizontal * 2,
                                  ),
                                ],
                                Text(
                                  _getPrimaryButtonText(),
                                  style: Theme.of(context)
                                      .extension<AppTypography>()!
                                      .body1SemiBoldWithColor(Colors.white)
                                      .copyWith(
                                        fontSize:
                                            SizeConfig.textMultiplier * 2.0,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: SizeConfig.blockSizeVertical * 2),

                        // Secondary button (Back/Scan Again)
                        SizedBox(
                          width: double.infinity,
                          height:
                              SizeConfig.orientation == Orientation.portrait
                                  ? SizeConfig.blockSizeVertical * 6.5
                                  : SizeConfig.blockSizeVertical * 8,
                          child: OutlinedButton(
                            onPressed: _handleSecondaryButtonPress,
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color:
                                    _hasStartedCurrentLobe
                                        ? AppConstants.accent2Color
                                        : AppConstants.primaryColor,
                                width: SizeConfig.blockSizeHorizontal * 0.3,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  SizeConfig.blockSizeHorizontal * 1,
                                ),
                              ),
                            ),
                            child: Text(
                              _getSecondaryButtonText(),
                              style: Theme.of(context)
                                  .extension<AppTypography>()!
                                  .body1SemiBoldWithColor(
                                    _hasStartedCurrentLobe
                                        ? AppConstants.accent2Color
                                        : AppConstants.primaryColor,
                                  )
                                  .copyWith(
                                    fontSize: SizeConfig.textMultiplier * 2.0,
                                  ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

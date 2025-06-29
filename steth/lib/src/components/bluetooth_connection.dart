import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_blue_classic/flutter_blue_classic.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:stethaim/constants/app_constants.dart';
import 'package:stethaim/src/components/bluetooth_device_list_entry.dart';
import 'package:stethaim/src/services/bluetooth_service.dart';

class NeumorexConnectionDialogs {
  // First dialog - Connect with Neumorex
  static Future<void> showBluetoothPromptDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                Text(
                  'Connect with Neumorex',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 24),

                // Bluetooth icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[300],
                  ),
                  child: Center(
                    child: Icon(
                      Icons.bluetooth,
                      color: Color(0xFF005F87),
                      size: 40,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Instructions
                Text(
                  'Turn on your bluetooth',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),

                Text(
                  'Bluetooth is necessary to connect with\nthe stethoscope. Please turn it on.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[700], fontSize: 14),
                ),
                const SizedBox(height: 24),

                // OK button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      // Show device list dialog
                      showDeviceListDialog(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.primaryColor,
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: Text(
                      'Ok',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // NEW: Device List Dialog
  static Future<void> showDeviceListDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return _BluetoothDeviceListDialog();
      },
    );
  }

  // Second dialog - Connecting to Stethoscope with animated progress
  static Future<void> showAnimatedConnectingDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return _AnimatedConnectingDialog();
      },
    );
  }

  // Third dialog - Connection Success
  static Future<void> showSuccessDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        // Auto-close after 2 seconds
        Future.delayed(Duration(seconds: 2), () {
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        });

        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Green tick icon
                Container(
                  width: 80,
                  height: 80,
                  margin: EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 60,
                  ),
                ),

                // Success text
                Text(
                  'Neumorex Connected',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),

                Text(
                  'Successfully!',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Method to demonstrate all dialogs in sequence
  static void showAllDialogsInSequence(BuildContext context) {
    showBluetoothPromptDialog(context);
  }
}

// NEW: Bluetooth Device List Dialog
class _BluetoothDeviceListDialog extends StatefulWidget {
  const _BluetoothDeviceListDialog({Key? key}) : super(key: key);

  @override
  _BluetoothDeviceListDialogState createState() =>
      _BluetoothDeviceListDialogState();
}

class _BluetoothDeviceListDialogState
    extends State<_BluetoothDeviceListDialog> {
  final FlutterBlueClassic _blueClassic = FlutterBlueClassic();
  BluetoothAdapterState _bluetoothState = BluetoothAdapterState.unknown;
  List<BluetoothDevice> devices = [];
  bool _isLoading = true;
  bool _permissionGranted = false;
  StreamSubscription<BluetoothAdapterState>? _bluetoothStateSubscription;

  @override
  void initState() {
    super.initState();
    _initBluetooth();
  }

  @override
  void dispose() {
    _bluetoothStateSubscription?.cancel();
    super.dispose();
  }

  void _initBluetooth() async {
    // Request permissions first
    await _requestPermissions();

    if (_permissionGranted) {
      // Get initial Bluetooth state
      try {
        _bluetoothState = await _blueClassic.adapterState.first.timeout(
          Duration(seconds: 5),
          onTimeout: () => BluetoothAdapterState.unknown,
        );

        if (mounted) {
          setState(() {
            if (_bluetoothState == BluetoothAdapterState.on) {
              _getBondedDevices();
            } else {
              _isLoading = false;
            }
          });
        }
      } catch (e) {
        print("Error getting initial Bluetooth state: $e");
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }

      // Listen to Bluetooth state changes
      _bluetoothStateSubscription = _blueClassic.adapterState.listen(
        (state) {
          print("Bluetooth state changed to: $state");
          if (mounted) {
            setState(() {
              _bluetoothState = state;
              if (state == BluetoothAdapterState.on) {
                _isLoading = true;
                _getBondedDevices();
              } else {
                _isLoading = false;
                devices.clear();
              }
            });
          }
        },
        onError: (error) {
          print("Bluetooth state listen error: $error");
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
        },
      );
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _requestPermissions() async {
    try {
      // Request permissions based on Android version
      Map<Permission, PermissionStatus> statuses =
          await [
            Permission.bluetoothScan,
            Permission.bluetoothConnect,
            Permission.location,
          ].request();

      // Check if essential permissions are granted
      bool bluetoothScanGranted =
          statuses[Permission.bluetoothScan]?.isGranted ?? false;
      bool bluetoothConnectGranted =
          statuses[Permission.bluetoothConnect]?.isGranted ?? false;
      bool locationGranted = statuses[Permission.location]?.isGranted ?? false;

      // For Android 12+, we primarily need bluetoothScan and bluetoothConnect
      // For older versions, location permission is also required
      bool permissionsGranted =
          bluetoothScanGranted && bluetoothConnectGranted && locationGranted;

      if (mounted) {
        setState(() {
          _permissionGranted = permissionsGranted;
        });
      }

      print("Permission statuses: $statuses");
      print("Bluetooth permissions granted: $permissionsGranted");
      print(
        "BluetoothScan: $bluetoothScanGranted, BluetoothConnect: $bluetoothConnectGranted, Location: $locationGranted",
      );
    } catch (e) {
      print("Error requesting permissions: $e");
      if (mounted) {
        setState(() {
          _permissionGranted = false;
        });
      }
    }
  }

  void _getBondedDevices() async {
    if (!mounted) return;

    try {
      print("Getting bonded devices...");

      setState(() {
        _isLoading = true;
      });

      // Add a small delay to ensure Bluetooth is fully ready
      await Future.delayed(Duration(milliseconds: 500));

      List<BluetoothDevice>? bonded = await _blueClassic.bondedDevices;
      print("Found ${bonded?.length ?? 0} bonded devices");

      // Log device details for debugging
      if (bonded != null && bonded.isNotEmpty) {
        for (var device in bonded) {
          print(
            "Device: ${device.name ?? 'Unknown'} - ${device.address} - Bonded: ${device.bondState}",
          );
        }
      }

      if (mounted) {
        setState(() {
          devices = bonded ?? [];
          _isLoading = false;
        });

        print(
          "UI updated with ${devices.length} devices, _isLoading: $_isLoading",
        );

        // Force a rebuild to ensure UI updates
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              // This forces a rebuild
            });
          }
        });

        // If no devices found, show a helpful message
        if (devices.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "No paired devices found. Please pair your stethoscope first.",
              ),
              backgroundColor: AppConstants.neutral3Color,
              action: SnackBarAction(
                label: 'Settings',
                textColor: Colors.white,
                onPressed: () {
                  // Open Bluetooth settings
                  openAppSettings();
                },
              ),
            ),
          );
        }
      }
    } catch (e) {
      print("Error retrieving bonded devices: $e");
      if (mounted) {
        setState(() {
          devices = [];
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error getting paired devices: $e"),
            backgroundColor: AppConstants.accent4Color,
          ),
        );
      }
    }
  }

  void _connectToDevice(BluetoothDevice device) async {
    print(
      "Attempting to connect to device: ${device.name} (${device.address})",
    );

    // Close device list dialog
    Navigator.of(context).pop();

    // Show connecting dialog with real connection attempt
    _showRealConnectingDialog(device);
  }

  void _showRealConnectingDialog(BluetoothDevice device) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return _RealConnectingDialog(device: device);
      },
    );
  }

  Future<void> _enableBluetooth() async {
    try {
      setState(() {
        _isLoading = true;
      });

      print("Attempting to turn on Bluetooth...");
      _blueClassic.turnOn();

      // Wait a bit for Bluetooth to initialize
      await Future.delayed(Duration(seconds: 2));

      // Check if Bluetooth is actually on
      BluetoothAdapterState currentState = await _blueClassic.adapterState.first
          .timeout(
            Duration(seconds: 5),
            onTimeout: () => _blueClassic.adapterState.first,
          );

      print("Bluetooth state after turn on: $currentState");

      if (mounted) {
        setState(() {
          _bluetoothState = currentState;
          if (currentState == BluetoothAdapterState.on) {
            _getBondedDevices();
          } else {
            _isLoading = false;
            // Show error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "Failed to turn on Bluetooth. Please enable it manually.",
                ),
                backgroundColor: AppConstants.accent4Color,
              ),
            );
          }
        });
      }
    } catch (e) {
      print("Error turning on Bluetooth: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error enabling Bluetooth: $e"),
            backgroundColor: AppConstants.accent4Color,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(20),
        width: double.infinity,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Select Bluetooth Device',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.close, color: AppConstants.neutral3Color),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Bluetooth status
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color:
                    _bluetoothState == BluetoothAdapterState.on
                        ? AppConstants.accent3Color.withOpacity(0.1)
                        : AppConstants.accent4Color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  Icon(
                    _bluetoothState == BluetoothAdapterState.on
                        ? Icons.bluetooth_connected
                        : Icons.bluetooth_disabled,
                    color:
                        _bluetoothState == BluetoothAdapterState.on
                            ? AppConstants.accent3Color
                            : AppConstants.accent4Color,
                    size: 16,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _bluetoothState == BluetoothAdapterState.on
                          ? 'Bluetooth is ON'
                          : _bluetoothState == BluetoothAdapterState.turningOn
                          ? 'Turning on Bluetooth...'
                          : 'Bluetooth is OFF',
                      style: TextStyle(
                        color:
                            _bluetoothState == BluetoothAdapterState.on
                                ? AppConstants.accent3Color
                                : AppConstants.accent4Color,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  // Always show refresh button when Bluetooth is on
                  if (_bluetoothState == BluetoothAdapterState.on)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextButton(
                          onPressed: _isLoading ? null : _getBondedDevices,
                          child: Text(
                            'Refresh',
                            style: TextStyle(
                              color:
                                  _isLoading
                                      ? AppConstants.neutral3Color
                                      : AppConstants.primaryColor,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        // Add scan button for discovery
                        IconButton(
                          onPressed:
                              _isLoading
                                  ? null
                                  : () {
                                    //     _blueClassic.openBluetoothSettings();
                                  },
                          icon: Icon(
                            Icons.settings_bluetooth,
                            color: AppConstants.primaryColor,
                            size: 16,
                          ),
                          tooltip: 'Bluetooth Settings',
                        ),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Device list content
            Expanded(child: _buildDeviceListContent()),

            // Bottom buttons
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: AppConstants.neutral3Color,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed:
                        _bluetoothState != BluetoothAdapterState.on &&
                                !_isLoading
                            ? _enableBluetooth
                            : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.primaryColor,
                      disabledBackgroundColor: AppConstants.neutral4Color,
                    ),
                    child:
                        _isLoading
                            ? SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                            : Text(
                              _bluetoothState == BluetoothAdapterState.on
                                  ? 'Bluetooth ON'
                                  : 'Turn ON',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Keep the existing _buildDeviceListContent method unchanged
  Widget _buildDeviceListContent() {
    print(
      "Building device list content - devices: ${devices.length}, loading: $_isLoading, permissions: $_permissionGranted, bluetooth: $_bluetoothState",
    );

    if (!_permissionGranted) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_off,
              size: 48,
              color: AppConstants.neutral3Color,
            ),
            SizedBox(height: 16),
            Text(
              'Bluetooth permissions required',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppConstants.neutral2Color,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Please grant Bluetooth and Location permissions to scan for devices.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppConstants.neutral3Color),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                await _requestPermissions();
                if (_permissionGranted &&
                    _bluetoothState == BluetoothAdapterState.on) {
                  _getBondedDevices();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
              ),
              child: Text(
                'Grant Permissions',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }

    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppConstants.primaryColor),
            SizedBox(height: 16),
            Text(
              _bluetoothState == BluetoothAdapterState.turningOn
                  ? 'Turning on Bluetooth...'
                  : 'Scanning for devices...',
              style: TextStyle(color: AppConstants.neutral3Color, fontSize: 14),
            ),
          ],
        ),
      );
    }

    if (_bluetoothState != BluetoothAdapterState.on) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bluetooth_disabled,
              size: 48,
              color: AppConstants.neutral3Color,
            ),
            SizedBox(height: 16),
            Text(
              'Bluetooth is turned off',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppConstants.neutral2Color,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Please turn on Bluetooth to see available devices.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppConstants.neutral3Color),
            ),
          ],
        ),
      );
    }

    if (devices.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.devices, size: 48, color: AppConstants.neutral3Color),
            SizedBox(height: 16),
            Text(
              'No paired devices found',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppConstants.neutral2Color,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Make sure your stethoscope is paired\nwith this device first.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppConstants.neutral3Color),
            ),
            SizedBox(height: 16),
            OutlinedButton(
              onPressed: () {
                openAppSettings();
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppConstants.primaryColor),
              ),
              child: Text(
                'Open Bluetooth Settings',
                style: TextStyle(color: AppConstants.primaryColor),
              ),
            ),
          ],
        ),
      );
    }

    // Show the actual device list
    print("Showing device list with ${devices.length} devices");
    return Column(
      children: [
        // Add a debug text to confirm devices are found
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppConstants.accent3Color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            'Found ${devices.length} paired device(s)',
            style: TextStyle(
              color: AppConstants.accent3Color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        SizedBox(height: 8),
        Expanded(
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: devices.length,
            separatorBuilder:
                (context, index) =>
                    Divider(color: AppConstants.neutral5Color, height: 1),
            itemBuilder: (context, index) {
              final device = devices[index];
              return BluetoothDeviceListEntry(
                device: device,
                enabled: true,
                onTap: () => _connectToDevice(device),
              );
            },
          ),
        ),
      ],
    );
  }
}

// Animated connecting dialog (unchanged)
class _AnimatedConnectingDialog extends StatefulWidget {
  const _AnimatedConnectingDialog({Key? key}) : super(key: key);

  @override
  _AnimatedConnectingDialogState createState() =>
      _AnimatedConnectingDialogState();
}

class _AnimatedConnectingDialogState extends State<_AnimatedConnectingDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  Timer? _dialogTimer;

  @override
  void initState() {
    super.initState();

    _progressController = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_progressController)..addListener(() {
      setState(() {});
    });

    _progressController.forward();

    _dialogTimer = Timer(Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pop();
        NeumorexConnectionDialogs.showSuccessDialog(context);
      }
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    _dialogTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(20),
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Connecting to Stethoscope...',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),

            const Text(
              'Searching Neumo Rex device...',
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 20),

            LinearProgressIndicator(
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                AppConstants.secondaryColor,
              ),
              value: _progressAnimation.value,
            ),
            const SizedBox(height: 24),

            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  _dialogTimer?.cancel();
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: AppConstants.primaryColor,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// NEW: Real Connecting Dialog
class _RealConnectingDialog extends StatefulWidget {
  final BluetoothDevice device;

  const _RealConnectingDialog({Key? key, required this.device})
    : super(key: key);

  @override
  _RealConnectingDialogState createState() => _RealConnectingDialogState();
}

class _RealConnectingDialogState extends State<_RealConnectingDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  String _connectionStatus = 'Connecting to device...';
  bool _isConnecting = true;
  bool _connectionSuccessful = false;

  final BluetoothService _bluetoothService = BluetoothService();

  @override
  void initState() {
    super.initState();

    _progressController = AnimationController(
      duration: Duration(seconds: 15), // 15 second timeout
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_progressController)..addListener(() {
      setState(() {});
    });

    _startConnection();
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  void _startConnection() async {
    _progressController.forward();

    setState(() {
      _connectionStatus = 'Connecting to ${widget.device.name ?? 'device'}...';
    });

    try {
      // Attempt real connection
      bool connected = await _bluetoothService.connectToDevice(widget.device);

      if (mounted) {
        if (connected) {
          setState(() {
            _connectionStatus = 'Connected successfully!';
            _isConnecting = false;
            _connectionSuccessful = true;
          });

          // Show success for 2 seconds then close
          await Future.delayed(Duration(seconds: 2));

          if (mounted) {
            Navigator.of(context).pop();
            _showConnectionSuccessDialog();
          }
        } else {
          _showConnectionError('Failed to connect to device');
        }
      }
    } catch (e) {
      if (mounted) {
        _showConnectionError('Connection error: $e');
      }
    }
  }

  void _showConnectionError(String error) {
    setState(() {
      _connectionStatus = error;
      _isConnecting = false;
      _connectionSuccessful = false;
    });
  }

  void _showConnectionSuccessDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        // Auto-close after 3 seconds
        Future.delayed(Duration(seconds: 3), () {
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        });

        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Green tick icon with animation
                Container(
                  width: 80,
                  height: 80,
                  margin: EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: AppConstants.accent3Color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle,
                    color: AppConstants.accent3Color,
                    size: 60,
                  ),
                ),

                // Success text
                Text(
                  '${widget.device.name ?? 'Device'} Connected',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppConstants.neutral1Color,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 8),

                Text(
                  'Successfully connected!',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppConstants.neutral3Color,
                  ),
                ),

                SizedBox(height: 16),

                // Connection details
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppConstants.accent3Color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Device:',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppConstants.neutral3Color,
                            ),
                          ),
                          Text(
                            widget.device.name ?? 'Unknown',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppConstants.neutral1Color,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Address:',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppConstants.neutral3Color,
                            ),
                          ),
                          Text(
                            widget.device.address,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppConstants.neutral1Color,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(20),
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                if (_isConnecting)
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppConstants.primaryColor,
                      ),
                    ),
                  )
                else if (_connectionSuccessful)
                  Icon(
                    Icons.check_circle,
                    color: AppConstants.accent3Color,
                    size: 20,
                  )
                else
                  Icon(Icons.error, color: AppConstants.accent4Color, size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _isConnecting
                        ? 'Connecting to Stethoscope...'
                        : _connectionSuccessful
                        ? 'Connection Successful!'
                        : 'Connection Failed',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Status text
            Text(
              _connectionStatus,
              style: TextStyle(
                fontSize: 14,
                color:
                    _connectionSuccessful
                        ? AppConstants.accent3Color
                        : _isConnecting
                        ? AppConstants.neutral3Color
                        : AppConstants.accent4Color,
              ),
            ),
            const SizedBox(height: 20),

            // Progress bar (only show when connecting)
            if (_isConnecting) ...[
              LinearProgressIndicator(
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppConstants.primaryColor,
                ),
                value: _progressAnimation.value,
              ),
              const SizedBox(height: 8),
              Text(
                'Timeout in ${(15 - (_progressAnimation.value * 15)).round()}s',
                style: TextStyle(
                  fontSize: 12,
                  color: AppConstants.neutral3Color,
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (_isConnecting)
                  TextButton(
                    onPressed: () {
                      _bluetoothService.disconnect();
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: AppConstants.accent4Color,
                        fontSize: 14,
                      ),
                    ),
                  )
                else if (!_connectionSuccessful)
                  Row(
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          'Close',
                          style: TextStyle(
                            color: AppConstants.neutral3Color,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          // Fix: Create new dialog instead of calling undefined method
                          showDialog<void>(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              return _RealConnectingDialog(
                                device: widget.device,
                              );
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppConstants.primaryColor,
                        ),
                        child: Text(
                          'Retry',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

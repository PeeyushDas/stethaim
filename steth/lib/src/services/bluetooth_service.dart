import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_blue_classic/flutter_blue_classic.dart';

class BluetoothService {
  static final BluetoothService _instance = BluetoothService._internal();
  factory BluetoothService() => _instance;
  BluetoothService._internal();

  BluetoothConnection? _connection;
  StreamSubscription? _dataSubscription;
  StreamSubscription? _connectionStateSubscription;
  Timer? _reconnectionTimer;

  // Connection state
  bool get isConnected => _connection != null && _connection!.isConnected;
  BluetoothDevice? _connectedDevice;
  BluetoothDevice? get connectedDevice => _connectedDevice;

  // Auto-reconnection settings
  bool _autoReconnectEnabled = true;
  bool _isReconnecting = false;
  int _reconnectionAttempts = 0;
  static const int maxReconnectionAttempts = 10;
  static const Duration reconnectionDelay = Duration(seconds: 3);

  // Data stream
  final StreamController<Uint8List> _dataStreamController =
      StreamController<Uint8List>.broadcast();
  Stream<Uint8List> get dataStream => _dataStreamController.stream;

  // Connection state stream
  final StreamController<bool> _connectionStateController =
      StreamController<bool>.broadcast();
  Stream<bool> get connectionStateStream => _connectionStateController.stream;

  // Reconnection status stream
  final StreamController<String> _reconnectionStatusController =
      StreamController<String>.broadcast();
  Stream<String> get reconnectionStatusStream =>
      _reconnectionStatusController.stream;

  Future<bool> connectToDevice(BluetoothDevice device) async {
    try {
      print(
        'Attempting to connect to device: ${device.name} (${device.address})',
      );

      // Disconnect any existing connection first
      await disconnect();

      final FlutterBlueClassic blueClassic = FlutterBlueClassic();

      // Check if Bluetooth is enabled
      bool isEnabled = await blueClassic.isEnabled;
      if (!isEnabled) {
        print('Bluetooth is not enabled');
        return false;
      }

      // Attempt connection with timeout
      _connection = await blueClassic
          .connect(device.address)
          .timeout(Duration(seconds: 15));

      if (_connection != null && _connection!.isConnected) {
        _connectedDevice = device;
        _reconnectionAttempts = 0; // Reset reconnection attempts
        _isReconnecting = false;
        print('Successfully connected to ${device.name}');

        // Set up data listener
        _dataSubscription = _connection!.input?.listen(
          (Uint8List data) {
            print('Received data: ${data.length} bytes');
            _dataStreamController.add(data);
          },
          onDone: () {
            print('Connection closed by remote device');
            _handleDisconnection();
          },
          onError: (error) {
            print('Data stream error: $error');
            _handleDisconnection();
          },
        );

        // Monitor connection state more frequently
        _connectionStateSubscription = Stream.periodic(
          Duration(seconds: 1), // Check every second for faster detection
        ).listen((_) {
          final bool currentlyConnected = isConnected;
          _connectionStateController.add(currentlyConnected);

          if (!currentlyConnected &&
              _connectedDevice != null &&
              !_isReconnecting) {
            print('Connection lost to ${_connectedDevice!.name}');
            _handleDisconnection();
          }
        });

        _connectionStateController.add(true);
        _reconnectionStatusController.add('Connected to ${device.name}');
        return true;
      } else {
        print('Connection object exists but isConnected is false');
        return false;
      }
    } catch (e) {
      print('Error connecting to device: $e');
      _handleDisconnection();
      return false;
    }
  }

  void _handleDisconnection() {
    print('Handling disconnection...');

    // Update connection state immediately
    _connectionStateController.add(false);

    // Clean up current connection
    _dataSubscription?.cancel();
    _connectionStateSubscription?.cancel();

    _dataSubscription = null;
    _connectionStateSubscription = null;

    if (_connection != null) {
      _connection!.dispose();
      _connection = null;
    }

    // Start auto-reconnection if enabled and we have a device to reconnect to
    if (_autoReconnectEnabled && _connectedDevice != null && !_isReconnecting) {
      _startAutoReconnection();
    } else if (!_autoReconnectEnabled) {
      _connectedDevice = null;
    }
  }

  void _startAutoReconnection() {
    if (_isReconnecting || _connectedDevice == null) return;

    _isReconnecting = true;
    _reconnectionAttempts = 0;

    print('Starting auto-reconnection to ${_connectedDevice!.name}...');
    _reconnectionStatusController.add(
      'Connection lost. Attempting to reconnect...',
    );

    _attemptReconnection();
  }

  void _attemptReconnection() {
    if (!_autoReconnectEnabled ||
        _connectedDevice == null ||
        _reconnectionAttempts >= maxReconnectionAttempts) {
      _isReconnecting = false;
      if (_reconnectionAttempts >= maxReconnectionAttempts) {
        print('Max reconnection attempts reached. Giving up.');
        _reconnectionStatusController.add(
          'Reconnection failed after $maxReconnectionAttempts attempts',
        );
        _connectedDevice = null;
      }
      return;
    }

    _reconnectionAttempts++;
    print(
      'Reconnection attempt $_reconnectionAttempts of $maxReconnectionAttempts...',
    );
    _reconnectionStatusController.add(
      'Reconnecting... Attempt $_reconnectionAttempts/$maxReconnectionAttempts',
    );

    _reconnectionTimer = Timer(reconnectionDelay, () async {
      if (!_autoReconnectEnabled || _connectedDevice == null) {
        _isReconnecting = false;
        return;
      }

      try {
        final FlutterBlueClassic blueClassic = FlutterBlueClassic();

        // Check if Bluetooth is still enabled
        bool isEnabled = await blueClassic.isEnabled;
        if (!isEnabled) {
          print('Bluetooth is disabled. Waiting for it to be enabled...');
          _scheduleNextReconnectionAttempt();
          return;
        }

        // Attempt reconnection
        _connection = await blueClassic
            .connect(_connectedDevice!.address)
            .timeout(Duration(seconds: 10)); // Shorter timeout for reconnection

        if (_connection != null && _connection!.isConnected) {
          print('Successfully reconnected to ${_connectedDevice!.name}');
          _reconnectionAttempts = 0;
          _isReconnecting = false;

          // Set up listeners again
          _dataSubscription = _connection!.input?.listen(
            (Uint8List data) {
              print('Received data: ${data.length} bytes');
              _dataStreamController.add(data);
            },
            onDone: () {
              print('Connection closed by remote device');
              _handleDisconnection();
            },
            onError: (error) {
              print('Data stream error: $error');
              _handleDisconnection();
            },
          );

          // Resume connection monitoring
          _connectionStateSubscription = Stream.periodic(
            Duration(seconds: 1),
          ).listen((_) {
            final bool currentlyConnected = isConnected;
            _connectionStateController.add(currentlyConnected);

            if (!currentlyConnected &&
                _connectedDevice != null &&
                !_isReconnecting) {
              print('Connection lost to ${_connectedDevice!.name}');
              _handleDisconnection();
            }
          });

          _connectionStateController.add(true);
          _reconnectionStatusController.add(
            'Reconnected to ${_connectedDevice!.name}',
          );
        } else {
          print('Reconnection failed. Scheduling next attempt...');
          _scheduleNextReconnectionAttempt();
        }
      } catch (e) {
        print('Reconnection attempt failed: $e');
        _scheduleNextReconnectionAttempt();
      }
    });
  }

  void _scheduleNextReconnectionAttempt() {
    if (_reconnectionAttempts < maxReconnectionAttempts &&
        _autoReconnectEnabled) {
      Timer(Duration(seconds: 2), () {
        _attemptReconnection();
      });
    } else {
      _isReconnecting = false;
      if (_reconnectionAttempts >= maxReconnectionAttempts) {
        _reconnectionStatusController.add(
          'Failed to reconnect after $maxReconnectionAttempts attempts',
        );
        _connectedDevice = null;
      }
    }
  }

  Future<void> disconnect() async {
    try {
      print('Manually disconnecting from device...');

      // Disable auto-reconnection for manual disconnections
      _autoReconnectEnabled = false;

      _reconnectionTimer?.cancel();
      _reconnectionTimer = null;

      await _dataSubscription?.cancel();
      await _connectionStateSubscription?.cancel();

      _dataSubscription = null;
      _connectionStateSubscription = null;

      if (_connection != null) {
        _connection!.dispose();
        _connection = null;
      }

      _connectedDevice = null;
      _isReconnecting = false;
      _reconnectionAttempts = 0;

      _connectionStateController.add(false);
      _reconnectionStatusController.add('Disconnected');

      print('Disconnected successfully');
    } catch (e) {
      print('Error during disconnection: $e');
    }
  }

  // Method to enable auto-reconnection (call this when you want to maintain connection)
  void enableAutoReconnect() {
    _autoReconnectEnabled = true;
    print('Auto-reconnection enabled');
  }

  // Method to disable auto-reconnection
  void disableAutoReconnect() {
    _autoReconnectEnabled = false;
    _reconnectionTimer?.cancel();
    _isReconnecting = false;
    print('Auto-reconnection disabled');
  }

  // Check if currently trying to reconnect
  bool get isReconnecting => _isReconnecting;

  // Get current reconnection attempts
  int get reconnectionAttempts => _reconnectionAttempts;

  Future<bool> sendData(String data) async {
    if (!isConnected) {
      print('Cannot send data: not connected');
      return false;
    }

    try {
      _connection!.output.add(Uint8List.fromList(data.codeUnits));
      await _connection!.output.allSent;
      print('Sent data: $data');
      return true;
    } catch (e) {
      print('Error sending data: $e');
      return false;
    }
  }

  void dispose() {
    _autoReconnectEnabled = false;
    _reconnectionTimer?.cancel();
    disconnect();
    _dataStreamController.close();
    _connectionStateController.close();
    _reconnectionStatusController.close();
  }
}

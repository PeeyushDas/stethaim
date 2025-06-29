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

  // Connection state
  bool get isConnected => _connection != null && _connection!.isConnected;
  BluetoothDevice? _connectedDevice;
  BluetoothDevice? get connectedDevice => _connectedDevice;

  // Data stream
  final StreamController<Uint8List> _dataStreamController =
      StreamController<Uint8List>.broadcast();
  Stream<Uint8List> get dataStream => _dataStreamController.stream;

  // Connection state stream
  final StreamController<bool> _connectionStateController =
      StreamController<bool>.broadcast();
  Stream<bool> get connectionStateStream => _connectionStateController.stream;

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

        // Monitor connection state
        _connectionStateSubscription = Stream.periodic(
          Duration(seconds: 2),
        ).listen((_) {
          final bool currentlyConnected = isConnected;
          _connectionStateController.add(currentlyConnected);

          if (!currentlyConnected && _connectedDevice != null) {
            print('Connection lost to ${_connectedDevice!.name}');
            _handleDisconnection();
          }
        });

        _connectionStateController.add(true);
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

  Future<void> disconnect() async {
    try {
      print('Disconnecting from device...');

      await _dataSubscription?.cancel();
      await _connectionStateSubscription?.cancel();

      _dataSubscription = null;
      _connectionStateSubscription = null;

      if (_connection != null) {
        _connection!.dispose();
        _connection = null;
      }

      _connectedDevice = null;
      _connectionStateController.add(false);

      print('Disconnected successfully');
    } catch (e) {
      print('Error during disconnection: $e');
    }
  }

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

  void _handleDisconnection() {
    _connectedDevice = null;
    _connectionStateController.add(false);

    _dataSubscription?.cancel();
    _connectionStateSubscription?.cancel();

    _dataSubscription = null;
    _connectionStateSubscription = null;

    if (_connection != null) {
      _connection!.dispose();
      _connection = null;
    }
  }

  void dispose() {
    disconnect();
    _dataStreamController.close();
    _connectionStateController.close();
  }
}

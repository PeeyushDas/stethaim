import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:permission_handler/permission_handler.dart';
import 'file_entity_list_tile.dart';
import 'wav_header.dart';
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_classic/flutter_blue_classic.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:external_path/external_path.dart';

enum RecordState { stopped, recording }

class DetailPage extends StatefulWidget {
  final BluetoothDevice server;

  const DetailPage({Key? key, required this.server}) : super(key: key);

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  BluetoothConnection? connection;
  bool isConnecting = true;
  bool get isConnected => connection != null && connection!.isConnected;
  bool isDisconnecting = false;

  List<List<int>> chunks = <List<int>>[];
  int contentLength = 0;
  Uint8List? _bytes;

  RestartableTimer? _timer;
  RecordState _recordState = RecordState.stopped;
  DateFormat dateFormat = DateFormat("yyyy-MM-dd_HH_mm_ss");

  List<FileSystemEntity> files = <FileSystemEntity>[];
  String selectedFilePath = '';
  AudioPlayer audioPlayer = AudioPlayer();

  // Flag to avoid calling setState after dispose
  bool _disposed = false;
  // Subscription for connection input
  StreamSubscription? _dataSubscription;
  // Subscription for connection state
  StreamSubscription? _connectionStateSubscription;

  @override
  void initState() {
    super.initState();
    requestStoragePermission();
    _connectToDevice();
    // Use the timer with a mounted check before calling _completeByte
    _timer = RestartableTimer(Duration(seconds: 1), () {
      if (mounted) _completeByte();
    });
    _listofFiles();
    selectedFilePath = '';
  }

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    audioPlayer.dispose();
    _dataSubscription?.cancel();
    _connectionStateSubscription?.cancel();
    if (isConnected) {
      isDisconnecting = true;
      connection?.dispose();
      connection = null;
    }
    super.dispose();
  }

  Future<void> _connectToDevice() async {
    if (_disposed) return;

    setState(() {
      isConnecting = true;
    });

    final FlutterBlueClassic blueClassic = FlutterBlueClassic();
    final String deviceAddress = widget.server.address;

    try {
      // Check if Bluetooth is available and enabled
      bool isAvailable = await blueClassic.isEnabled;
      bool isEnabled = await blueClassic.isEnabled;

      if (!isAvailable || !isEnabled) {
        if (mounted) {
          setState(() {
            isConnecting = false;
          });
        }
        print('Bluetooth is not available or not enabled');
        return;
      }

      print('Attempting to connect to device: $deviceAddress');

      // Attempt connection with a 15-second timeout
      final _connection = await blueClassic
          .connect(deviceAddress)
          .timeout(Duration(seconds: 15));

      // If successful, update connection state
      if (_disposed) return;

      connection = _connection;

      // Check connection state immediately
      if (connection != null && connection!.isConnected) {
        print('Successfully connected to device');
      } else {
        print('Connection object exists but isConnected is false');
      }

      if (mounted) {
        setState(() {
          isConnecting = false;
        });
      }

      // Listen to connection state changes
      _connectionStateSubscription = Stream.periodic(
        Duration(seconds: 2),
      ).listen((_) {
        if (_disposed) return;

        final bool currentlyConnected =
            connection != null && connection!.isConnected;

        // Only update UI if connection state changed
        if (currentlyConnected != isConnected && mounted) {
          print('Connection state changed: $currentlyConnected');
          setState(() {
            // State will update through the isConnected getter
            // No need to set any variable directly
          });
        }
      });
      ;

      // Listen to incoming data
      _dataSubscription = connection!.input?.listen(
        _onDataReceived,
        onDone: () {
          print('Connection closed by remote device.');
          if (mounted) {
            setState(() {});
          }
        },
        onError: (error) {
          print('Connection error: $error');
          if (mounted) {
            setState(() {});
          }
        },
      );
    } catch (e) {
      // Handle timeouts and connection errors
      print('Error connecting: $e');
      if (mounted) {
        setState(() {
          isConnecting = false;
        });
      }

      // Retry connection after delay if appropriate
      if (!_disposed) {
        Future.delayed(Duration(seconds: 3), () {
          if (mounted && !isConnected && !isConnecting) {
            print('Retrying connection...');
            _connectToDevice();
          }
        });
      }
    }
  }

  void _completeByte() async {
    if (_disposed) return;
    if (chunks.isEmpty || contentLength == 0) return;
    print("CompleteByte length: $contentLength");

    _bytes = Uint8List(contentLength);
    int offset = 0;
    for (final List<int> chunk in chunks) {
      _bytes!.setRange(offset, offset + chunk.length, chunk);
      offset += chunk.length;
    }

    final file = await _makeNewFile;
    var headerList = WavHeader.createWavHeader(contentLength);
    file.writeAsBytesSync(headerList, mode: FileMode.write);
    file.writeAsBytesSync(_bytes!, mode: FileMode.append);

    print("File written. Size: ${await file.length()}");
    if (!mounted) return;
    await _listofFiles();

    contentLength = 0;
    chunks.clear();
  }

  void _onDataReceived(Uint8List data) {
    if (data.isNotEmpty) {
      chunks.add(data);
      contentLength += data.length;
      _timer?.reset();
    }
    print("Data Length: ${data.length}, chunks: ${chunks.length}");
  }

  void _sendMessage(String text) async {
    text = text.trim();
    if (text.isNotEmpty && isConnected) {
      try {
        connection?.output.add(utf8.encode(text));
        await connection?.output.allSent;

        if (text == "START") {
          _recordState = RecordState.recording;
        } else if (text == "STOP") {
          _recordState = RecordState.stopped;
        }
        if (mounted) setState(() {});
      } catch (e) {
        if (mounted) setState(() {});
        print("Error sending message: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          isConnecting
              ? 'Connecting to ${widget.server.name} ...'
              : isConnected
              ? 'Connected with ${widget.server.name}'
              : 'Disconnected from ${widget.server.name}',
        ),
        actions: [
          // Add reconnect button
          if (!isConnecting && !isConnected)
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: _connectToDevice,
              tooltip: 'Retry connection',
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            // Connection status indicator
            Container(
              padding: EdgeInsets.all(8),
              color: isConnected ? Colors.green.shade100 : Colors.red.shade100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isConnected
                        ? Icons.bluetooth_connected
                        : Icons.bluetooth_disabled,
                    color: isConnected ? Colors.green : Colors.red,
                  ),
                  SizedBox(width: 8),
                  Text(
                    isConnecting
                        ? "Connecting..."
                        : isConnected
                        ? "Connected"
                        : "Disconnected",
                    style: TextStyle(
                      color: isConnected ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            if (isConnected) ...[
              shotButton(),
              Expanded(
                child: ListView(
                  children:
                      files.map((file) {
                        return FileEntityListTile(
                          filePath: file.path,
                          fileSize: file.statSync().size,
                          onLongPress: () async {
                            print("onLongPress item");
                            if (await File(file.path).exists()) {
                              File(file.path).deleteSync();
                              files.remove(file);
                              if (mounted) setState(() {});
                            }
                          },
                          onTap: () async {
                            print("onTap item");
                            if (file.path == selectedFilePath) {
                              await audioPlayer.stop();
                              selectedFilePath = '';
                              if (mounted) setState(() {});
                              return;
                            }
                            if (await File(file.path).exists()) {
                              selectedFilePath = file.path;
                              await audioPlayer.setSource(
                                DeviceFileSource(selectedFilePath),
                              );
                              await audioPlayer.resume();
                              if (mounted) setState(() {});
                            } else {
                              selectedFilePath = '';
                              if (mounted) setState(() {});
                            }
                          },
                        );
                      }).toList(),
                ),
              ),
            ] else ...[
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isConnecting) CircularProgressIndicator(),
                      SizedBox(height: 20),
                      Text(
                        isConnecting
                            ? "Connecting to device..."
                            : "Not connected to device",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (!isConnecting)
                        ElevatedButton(
                          onPressed: _connectToDevice,
                          child: Text("Retry Connection"),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget shotButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(color: Colors.red),
          ),
        ),
        onPressed: () {
          if (_recordState == RecordState.stopped) {
            _sendMessage("START");
            _showRecordingDialog();
          } else {
            _sendMessage("STOP");
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            _recordState == RecordState.stopped ? "RECORD" : "STOP",
            style: TextStyle(fontSize: 24, color: Colors.white),
          ),
        ),
      ),
    );
  }

  void _showRecordingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissal by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(
            child: Text(
              "Recording",
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
          ),
          content: Container(
            width: 100,
            height: 100,
            alignment: Alignment.center,
            child: CircularProgressIndicator(
              strokeWidth: 10,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
            ),
          ),
          actions: <Widget>[
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: BorderSide(color: Colors.red),
                  ),
                ),
                onPressed: () {
                  _sendMessage("STOP");
                  Navigator.of(context).pop();
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "STOP",
                    style: TextStyle(fontSize: 24, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<String> get _localPath async {
    if (Platform.isAndroid) {
      // Retrieve the public Downloads directory
      return await ExternalPath.getExternalStoragePublicDirectory(
        ExternalPath.DIRECTORY_DOWNLOAD,
      );
    } else {
      return (await getApplicationDocumentsDirectory()).path;
    }
  }

  Future<File> get _makeNewFile async {
    final path = await _localPath;
    String newFileName = dateFormat.format(DateTime.now());
    return File('$path/$newFileName.wav');
  }

  Future<void> requestStoragePermission() async {
    var status = await Permission.storage.request();

    if (status.isGranted) {
      print("Storage permission granted");
    } else if (status.isDenied) {
      print("Storage permission denied");
    } else if (status.isPermanentlyDenied) {
      print("Storage permission permanently denied");
      openAppSettings();
    }
  }

  Future<void> _listofFiles() async {
    final path = await _localPath;
    List<FileSystemEntity> tempFiles = [];
    await for (var entity in Directory(path).list()) {
      if (entity.path.contains("wav")) {
        tempFiles.insert(0, entity);
        print(
          "PATH: ${entity.path} Size: ${await entity.stat().then((s) => s.size)}",
        );
      }
    }
    if (!mounted) return;
    setState(() {
      files = tempFiles;
    });
  }
}

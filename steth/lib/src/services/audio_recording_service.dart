import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';
import 'package:stethaim/src/services/bluetooth_service.dart';
import 'package:async/async.dart';

class AudioRecordingService {
  static final AudioRecordingService _instance =
      AudioRecordingService._internal();
  factory AudioRecordingService() => _instance;
  AudioRecordingService._internal();

  final BluetoothService _bluetoothService = BluetoothService();
  StreamSubscription<Uint8List>? _dataSubscription;
  bool _isRecording = false;
  String? _currentFilePath;

  // DigiSteth-style data collection
  List<List<int>> _chunks = <List<int>>[];
  int _contentLength = 0;
  RestartableTimer? _timer;

  // ESP32 audio format parameters
  static const int _sampleRate = 16000;
  static const int _channels = 1;
  static const int _bitsPerSample = 16;
  static const int _byteRate = _sampleRate * _channels * _bitsPerSample ~/ 8;
  static const int _blockAlign = _channels * _bitsPerSample ~/ 8;

  // Recording state
  bool get isRecording => _isRecording;
  String? get currentFilePath => _currentFilePath;

  // Stream controller for recording status
  final StreamController<String> _recordingStatusController =
      StreamController<String>.broadcast();
  Stream<String> get recordingStatusStream => _recordingStatusController.stream;

  Future<String> startRecording({
    required String fileName,
    String? patientId,
    String? lobeLabel,
  }) async {
    try {
      if (_isRecording) {
        throw Exception('Recording already in progress');
      }

      if (!_bluetoothService.isConnected) {
        throw Exception('Bluetooth device not connected');
      }

      // Request storage permissions
      bool hasPermission = await _requestStoragePermission();
      if (!hasPermission) {
        throw Exception('Storage permission not granted');
      }

      // Reset data collection
      _chunks.clear();
      _contentLength = 0;

      // Create the recordings directory
      Directory recordingsDir = await _getExternalRecordingsDirectory();

      // Generate filename
      String customFileName = _generateFileName(
        fileName: fileName,
        patientId: patientId,
        lobeLabel: lobeLabel,
      );

      // Set the target file path (but don't create file yet)
      _currentFilePath = path.join(recordingsDir.path, customFileName);

      print('Will save recording to: $_currentFilePath');

      // Initialize timer for data completion detection
      _timer = RestartableTimer(Duration(seconds: 2), () {
        if (_isRecording) {
          _completeRecording();
        }
      });

      // Subscribe to Bluetooth data stream
      _dataSubscription = _bluetoothService.dataStream.listen(
        _onDataReceived,
        onError: (error) {
          print('Error during recording: $error');
          _recordingStatusController.add('Recording error: $error');
        },
      );

      _isRecording = true;
      _recordingStatusController.add('Recording started: $customFileName');

      // Send START command to ESP32
      await _bluetoothService.sendData('START');
      print('Sent START command to ESP32');

      return _currentFilePath!;
    } catch (e) {
      print('Error starting recording: $e');
      _recordingStatusController.add('Failed to start recording: $e');
      rethrow;
    }
  }

  void _onDataReceived(Uint8List data) {
    if (!_isRecording) return;

    if (data.isNotEmpty) {
      _chunks.add(data.toList());
      _contentLength += data.length;
      _timer?.reset(); // Reset timer on each data packet

      print(
        "Data Length: ${data.length}, chunks: ${_chunks.length}, total: $_contentLength",
      );
    }
  }

  Future<void> _completeRecording() async {
    if (_chunks.isEmpty || _contentLength == 0) {
      print("No data to save");
      return;
    }

    print("Completing recording with $_contentLength bytes");

    try {
      // Combine all chunks into one Uint8List (DigiSteth style)
      Uint8List audioBytes = Uint8List(_contentLength);
      int offset = 0;
      for (final List<int> chunk in _chunks) {
        audioBytes.setRange(offset, offset + chunk.length, chunk);
        offset += chunk.length;
      }

      // Create file
      File file = File(_currentFilePath!);
      await file.create(recursive: true);

      // Write WAV header first
      List<int> headerList = _createWavHeader(_contentLength);
      await file.writeAsBytes(headerList, mode: FileMode.write);

      // Write audio data
      await file.writeAsBytes(audioBytes, mode: FileMode.append);

      int finalFileSize = await file.length();
      double durationSeconds = _contentLength / _byteRate;

      print("File written successfully. Size: $finalFileSize bytes");
      print('Duration: ${durationSeconds.toStringAsFixed(2)} seconds');

      _recordingStatusController.add(
        'Recording saved: ${path.basename(_currentFilePath!)} (${_formatFileSize(finalFileSize)}, ${durationSeconds.toStringAsFixed(1)}s)',
      );

      // Validate the file
      bool isValid = await _validateWavFile(_currentFilePath!);
      if (isValid) {
        print('WAV file validation: PASSED');
      } else {
        print('WAV file validation: FAILED');
        _recordingStatusController.add(
          'Warning: Audio file may have playback issues',
        );
      }
    } catch (e) {
      print('Error completing recording: $e');
      _recordingStatusController.add('Error saving recording: $e');
    }

    // Clear data
    _contentLength = 0;
    _chunks.clear();
  }

  Future<String?> stopRecording() async {
    try {
      if (!_isRecording) {
        print('No recording in progress');
        return null;
      }

      print('Stopping recording...');

      // Send STOP command to ESP32
      await _bluetoothService.sendData('STOP');
      print('Sent STOP command to ESP32');

      // Set recording flag to false
      _isRecording = false;

      // Cancel timer and data subscription
      _timer?.cancel();
      await _dataSubscription?.cancel();
      _dataSubscription = null;

      // Complete any pending recording
      if (_chunks.isNotEmpty) {
        await _completeRecording();
      }

      String? filePath = _currentFilePath;
      _currentFilePath = null;

      return filePath;
    } catch (e) {
      print('Error stopping recording: $e');
      _recordingStatusController.add('Error stopping recording: $e');
      _isRecording = false;
      _currentFilePath = null;
      rethrow;
    }
  }

  List<int> _createWavHeader(int dataSize) {
    int fileSize = 36 + dataSize;

    return [
      // RIFF header
      0x52, 0x49, 0x46, 0x46, // "RIFF"
      (fileSize - 8) & 0xff, ((fileSize - 8) >> 8) & 0xff,
      ((fileSize - 8) >> 16) & 0xff, ((fileSize - 8) >> 24) & 0xff,
      0x57, 0x41, 0x56, 0x45, // "WAVE"
      // fmt chunk
      0x66, 0x6d, 0x74, 0x20, // "fmt "
      16, 0, 0, 0, // chunk size (16 for PCM)
      1, 0, // audio format (1 = PCM)
      _channels, 0, // number of channels
      _sampleRate & 0xff, (_sampleRate >> 8) & 0xff,
      (_sampleRate >> 16) & 0xff, (_sampleRate >> 24) & 0xff,
      _byteRate & 0xff, (_byteRate >> 8) & 0xff,
      (_byteRate >> 16) & 0xff, (_byteRate >> 24) & 0xff,
      _blockAlign, 0, // block align
      _bitsPerSample, 0, // bits per sample
      // data chunk
      0x64, 0x61, 0x74, 0x61, // "data"
      dataSize & 0xff, (dataSize >> 8) & 0xff,
      (dataSize >> 16) & 0xff, (dataSize >> 24) & 0xff,
    ];
  }

  Future<bool> _requestStoragePermission() async {
    try {
      if (Platform.isAndroid) {
        var status = await Permission.storage.request();
        if (status.isDenied) {
          status = await Permission.manageExternalStorage.request();
        }
        return status.isGranted;
      }
      return true;
    } catch (e) {
      print('Error requesting storage permission: $e');
      return false;
    }
  }

  Future<Directory> _getExternalRecordingsDirectory() async {
    try {
      // Try Downloads folder first
      Directory downloadsDir = Directory(
        '/storage/emulated/0/Download/StethAIM_Recordings',
      );

      if (!await downloadsDir.exists()) {
        try {
          await downloadsDir.create(recursive: true);
          print('Created Downloads directory: ${downloadsDir.path}');
        } catch (e) {
          print(
            'Could not create Downloads directory, trying external storage: $e',
          );

          Directory? externalDir = await getExternalStorageDirectory();
          if (externalDir != null) {
            downloadsDir = Directory(
              path.join(externalDir.path, 'StethAIM_Recordings'),
            );
            await downloadsDir.create(recursive: true);
            print('Created external directory: ${downloadsDir.path}');
          } else {
            throw Exception('Could not access external storage');
          }
        }
      }

      print('Using recordings directory: ${downloadsDir.path}');
      return downloadsDir;
    } catch (e) {
      print('Error creating external directory: $e');
      Directory appDir = await getApplicationDocumentsDirectory();
      Directory recordingsDir = Directory(
        path.join(appDir.path, 'StethAIM_Recordings'),
      );

      if (!await recordingsDir.exists()) {
        await recordingsDir.create(recursive: true);
      }

      print('Using fallback directory: ${recordingsDir.path}');
      return recordingsDir;
    }
  }

  String _generateFileName({
    required String fileName,
    String? patientId,
    String? lobeLabel,
  }) {
    DateTime now = DateTime.now();
    String timestamp =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_'
        '${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';

    String sanitizedLobe =
        lobeLabel?.replaceAll(RegExp(r'[^\w\s-]'), '').replaceAll(' ', '_') ??
        'Unknown_Lobe';
    String sanitizedPatient = patientId ?? 'Unknown_Patient';

    // Format: StethAIM_PatientID_Lobe_Timestamp.wav
    return 'StethAIM_${sanitizedPatient}_${sanitizedLobe}_${timestamp}.wav';
  }

  Future<bool> _validateWavFile(String filePath) async {
    try {
      File file = File(filePath);
      List<int> headerBytes = await file.openRead(0, 44).first;

      if (headerBytes.length < 44) {
        print(
          'WAV validation failed: Header too short (${headerBytes.length} bytes)',
        );
        return false;
      }

      String riffSignature = String.fromCharCodes(headerBytes.sublist(0, 4));
      String waveSignature = String.fromCharCodes(headerBytes.sublist(8, 12));
      String fmtSignature = String.fromCharCodes(headerBytes.sublist(12, 16));
      String dataSignature = String.fromCharCodes(headerBytes.sublist(36, 40));

      // Check sample rate
      int headerSampleRate =
          headerBytes[24] |
          (headerBytes[25] << 8) |
          (headerBytes[26] << 16) |
          (headerBytes[27] << 24);

      bool isValid =
          riffSignature == 'RIFF' &&
          waveSignature == 'WAVE' &&
          fmtSignature == 'fmt ' &&
          dataSignature == 'data' &&
          headerSampleRate == _sampleRate;

      print(
        'WAV validation: RIFF=$riffSignature, WAVE=$waveSignature, fmt=$fmtSignature, data=$dataSignature',
      );
      print(
        'Sample rate in header: $headerSampleRate (expected: $_sampleRate)',
      );
      print('Validation result: ${isValid ? "PASSED" : "FAILED"}');

      return isValid;
    } catch (e) {
      print('Error validating WAV file: $e');
      return false;
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '${bytes} B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Future<List<String>> getRecordedFiles() async {
    try {
      Directory recordingsDir = await _getExternalRecordingsDirectory();
      List<FileSystemEntity> files = recordingsDir.listSync();

      return files
          .where((file) => file is File && file.path.endsWith('.wav'))
          .map((file) => file.path)
          .toList();
    } catch (e) {
      print('Error getting recorded files: $e');
      return [];
    }
  }

  Future<bool> deleteRecording(String filePath) async {
    try {
      File file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        print('Deleted recording: $filePath');
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting recording: $e');
      return false;
    }
  }

  void dispose() {
    _timer?.cancel();
    if (_isRecording) {
      stopRecording();
    }
    _recordingStatusController.close();
  }
}

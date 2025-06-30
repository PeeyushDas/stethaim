import 'package:flutter/material.dart';
import 'package:flutter_blue_classic/flutter_blue_classic.dart';
import 'BluetoothDeviceListEntry.dart';
import 'detailpage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ESP32 Voice Recorder',
      home: HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  // Create an instance of FlutterBlueClassic
  final FlutterBlueClassic _blueClassic = FlutterBlueClassic();

  // Track the adapter's Bluetooth state
  BluetoothAdapterState _bluetoothState = BluetoothAdapterState.unknown;

  // List of paired (bonded) devices
  List<BluetoothDevice> devices = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initBluetooth();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Listen to app lifecycle changes to refresh device list when resuming
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        _bluetoothState == BluetoothAdapterState.on) {
      _getBondedDevices();
    }
  }

  void _initBluetooth() {
    _blueClassic.adapterState.listen((state) {
      setState(() {
        _bluetoothState = state;
        if (state == BluetoothAdapterState.on) {
          _getBondedDevices();
        }
      });
    });
  }

  void _getBondedDevices() async {
    try {
      List<BluetoothDevice>? bonded = await _blueClassic.bondedDevices;
      setState(() {
        devices = bonded!;
      });
    } catch (e) {
      print("Error retrieving bonded devices: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("ESP32 Voice Recorder")),
      body: Column(
        children: <Widget>[
          // Switch to toggle Bluetooth on/off
          SwitchListTile(
            title: Text('Enable Bluetooth'),
            value: _bluetoothState == BluetoothAdapterState.on,
            onChanged: (bool value) async {
              if (value) {
                _blueClassic.turnOn();
              } else {
                //_blueClassic.turnOff();
              }
            },
          ),
          // Display current Bluetooth status and a button for settings
          ListTile(
            title: Text("Bluetooth STATUS"),
            subtitle: Text(_bluetoothState.toString()),
            trailing: ElevatedButton(
              child: Text("Settings"),
              onPressed: () {
                // _blueClassic.openBluetoothSettings();
              },
            ),
          ),
          // List bonded devices
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Bonded Devices'),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _getBondedDevices();
                  });
                },
                child: Text('Refresh'),
              ),
            ],
          ),
          Expanded(
            child: ListView(
              children:
                  devices.map((device) {
                    return BluetoothDeviceListEntry(
                      device: device,
                      enabled: true,
                      onTap: () {
                        _startConnect(device);
                      },
                    );
                  }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  void _startConnect(BluetoothDevice device) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => DetailPage(server: device)));
  }
}

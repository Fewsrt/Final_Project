import 'package:alert/Screens/add_device/add_device.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Initialize Firebase
  runApp(const AdminDashboardPage(
    deviceId: '',
  ));
}

class AdminDashboardPage extends StatefulWidget {
  final String deviceId;

  const AdminDashboardPage({super.key, required this.deviceId});

  @override
  // ignore: library_private_types_in_public_api
  _AdminDashboardPageState createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  bool _auto = false;
  bool _drain = false;
  bool _pumpleft = false;
  bool _pumpright = false;
  bool _door1 = false;
  bool _door2 = false;
  var _direction = 0;
  double _humidity = 0;
  double _temperature = 0;
  int _ultrasonicleft = 0;
  var _ultrasonicright = 0;
  double ultrasonicleftvalue = 0;
  double ultrasonicrightvalue = 0;
  double _rain = 0;
  double _windspeed = 0;
  DatabaseReference refbutton = FirebaseDatabase.instance.ref("Button");
  DatabaseReference refsensor = FirebaseDatabase.instance.ref("sensor");
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  CollectionReference devicesCollection =
      FirebaseFirestore.instance.collection('Devices');
  String deviceName = '';

  @override
  void initState() {
    super.initState();
    getDataFromFirestore();
    // refbutton.child('Auto').onValue.listen((DatabaseEvent event) {
    //   setState(() {
    //     _auto = event.snapshot.value as bool? ?? false;
    //   });
    // });
    // refbutton.child('Drain').onValue.listen((DatabaseEvent event) {
    //   setState(() {
    //     _drain = event.snapshot.value as bool? ?? false;
    //   });
    // });
    // refbutton.child('PumpL').onValue.listen((DatabaseEvent event) {
    //   setState(() {
    //     _pumpleft = event.snapshot.value as bool? ?? false;
    //   });
    // });
    // refbutton.child('PumpR').onValue.listen((DatabaseEvent event) {
    //   setState(() {
    //     _pumpright = event.snapshot.value as bool? ?? false;
    //   });
    // });
    // refbutton.child('door1').onValue.listen((DatabaseEvent event) {
    //   setState(() {
    //     _door1 = event.snapshot.value as bool? ?? false;
    //   });
    // });
    // refbutton.child('door2').onValue.listen((DatabaseEvent event) {
    //   setState(() {
    //     _door2 = event.snapshot.value as bool? ?? false;
    //   });
    // });
    // refsensor.child('Direction').onValue.listen((DatabaseEvent event) {
    //   setState(() {
    //     _direction = int.parse(event.snapshot.value.toString());
    //   });
    // });
    // refsensor.child('Temp_real').onValue.listen((DatabaseEvent event) {
    //   setState(() {
    //     _temperature = double.parse(event.snapshot.value.toString());
    //   });
    // });
    // refsensor.child('Humidity').onValue.listen((DatabaseEvent event) {
    //   setState(() {
    //     _humidity = double.parse(event.snapshot.value.toString());
    //   });
    // });
    // refsensor.child('Utra').onValue.listen((DatabaseEvent event) {
    //   setState(() {
    //     _ultrasonicleft = int.parse(event.snapshot.value.toString());
    //     ultrasonicleftvalue = double.parse(event.snapshot.value.toString());
    //   });
    // });
    // refsensor.child('Utra2').onValue.listen((DatabaseEvent event) {
    //   setState(() {
    //     _ultrasonicright = int.parse(event.snapshot.value.toString());
    //     ultrasonicrightvalue = double.parse(event.snapshot.value.toString());
    //   });
    // });
    // refsensor.child('rain_real').onValue.listen((DatabaseEvent event) {
    //   setState(() {
    //     _rain = double.parse(event.snapshot.value.toString());
    //   });
    // });
    // refsensor.child('wind_real').onValue.listen((DatabaseEvent event) {
    //   setState(() {
    //     _windspeed = double.parse(event.snapshot.value.toString());
    //   });
    // });
  }

  Future<void> _handleSwitchAuto(bool value) async {
    setState(() {
      _auto = value;
    });
    await refbutton.update({"Auto": value});
  }

  Future<void> _handleSwitchdrain(bool value) async {
    setState(() {
      _drain = value;
    });
    await refbutton.update({"Drain": value});
  }

  Future<void> _handleSwitchpumpleft(bool value) async {
    setState(() {
      _pumpleft = value;
    });
    await refbutton.update({"PumpL": value});
  }

  Future<void> _handleSwitchpumpright(bool value) async {
    setState(() {
      _pumpright = value;
    });
    await refbutton.update({"PumpR": value});
  }

  Future<void> _handleSwitchdoor1(bool value) async {
    setState(() {
      _door1 = value;
    });
    await refbutton.update({"door1": value});
  }

  Future<void> _handleSwitchdoor2(bool value) async {
    setState(() {
      _door2 = value;
    });
    await refbutton.update({"door2": value});
  }

  void getDataFromFirestore() async {
    DocumentSnapshot documentSnapshot =
        await devicesCollection.doc(widget.deviceId).get();

    if (documentSnapshot.exists) {
      setState(() {
        deviceName = documentSnapshot.get('device_name');
        // debugPrint(deviceName);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(deviceName),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Control:',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                Expanded(
                  child: SwitchListTile(
                    title: const Text('Auto'),
                    value: _auto,
                    onChanged: _handleSwitchAuto,
                  ),
                ),
                Expanded(
                  child: SwitchListTile(
                    title: const Text('Drain'),
                    value: _drain,
                    onChanged: _handleSwitchdrain,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: SwitchListTile(
                      title: const Text('Pump Left'),
                      value: _pumpleft,
                      onChanged: _handleSwitchpumpleft),
                ),
                Expanded(
                  child: SwitchListTile(
                    title: const Text('Pump Right'),
                    value: _pumpright,
                    onChanged: _handleSwitchpumpright,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: SwitchListTile(
                    title: const Text('Door 1'),
                    value: _door1,
                    onChanged: _handleSwitchdoor1,
                  ),
                ),
                Expanded(
                  child: SwitchListTile(
                    title: const Text('Door 2'),
                    value: _door2,
                    onChanged: _handleSwitchdoor2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Sensor Value:',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            Text('Direction: $_direction'),
            Text('Temperature: $_temperature'),
            Text('Humidity: $_humidity'),
            Text('Ultrasonic Left: $_ultrasonicleft'),
            Text('Ultrasonic Right: $_ultrasonicright'),
            Text('Rain: $_rain'),
            Text('Wind Speed: $_windspeed'),
            // Row(
            //   children: [
            //     Expanded(
            //         child: SfRadialGauge(axes: <RadialAxis>[
            //       RadialAxis(minimum: 0, maximum: 20, ranges: <GaugeRange>[
            //         GaugeRange(startValue: 0, endValue: 5, color: Colors.green),
            //         GaugeRange(
            //             startValue: 5, endValue: 12, color: Colors.orange),
            //         GaugeRange(startValue: 12, endValue: 20, color: Colors.red)
            //       ], pointers: <GaugePointer>[
            //         NeedlePointer(
            //           value: ultrasonicleftvalue,
            //           enableAnimation: true,
            //         )
            //       ], annotations: <GaugeAnnotation>[
            //         GaugeAnnotation(
            //             widget: Text('$_ultrasonicleft cm',
            //                 style: const TextStyle(
            //                     fontSize: 14, fontWeight: FontWeight.bold)),
            //             angle: 90,
            //             positionFactor: 0.5)
            //       ])
            //     ])),
            //     Expanded(
            //         child: SfRadialGauge(axes: <RadialAxis>[
            //       RadialAxis(minimum: 0, maximum: 20, ranges: <GaugeRange>[
            //         GaugeRange(startValue: 0, endValue: 5, color: Colors.green),
            //         GaugeRange(
            //             startValue: 5, endValue: 12, color: Colors.orange),
            //         GaugeRange(startValue: 12, endValue: 20, color: Colors.red)
            //       ], pointers: <GaugePointer>[
            //         NeedlePointer(
            //           value: ultrasonicrightvalue,
            //           enableAnimation: true,
            //         )
            //       ], annotations: <GaugeAnnotation>[
            //         GaugeAnnotation(
            //             widget: Text('$_ultrasonicright cm',
            //                 style: const TextStyle(
            //                     fontSize: 14, fontWeight: FontWeight.bold)),
            //             angle: 90,
            //             positionFactor: 0.5)
            //       ])
            //     ]))
            //   ],
            // )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddDeviceScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

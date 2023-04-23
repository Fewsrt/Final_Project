import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

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
  DatabaseReference refbutton = FirebaseDatabase.instance.ref("/");
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  CollectionReference devicesCollection =
      FirebaseFirestore.instance.collection('Devices');
  String deviceName = '';
  String uuid = '';

  @override
  void initState() {
    super.initState();
    getDataFromFirestore();
  }

  Future<void> _handleSwitchAuto(bool value) async {
    setState(() {
      _auto = value;
    });
    await refbutton.update({"$uuid/Buttons/AutoButton": value});
  }

  Future<void> _handleSwitchdrain(bool value) async {
    setState(() {
      _drain = value;
    });
    await refbutton.update({"$uuid/Buttons/drainButton": value});
  }

  Future<void> _handleSwitchpumpleft(bool value) async {
    setState(() {
      _pumpleft = value;
    });
    await refbutton.update({"$uuid/Buttons/VillageButton": value});
  }

  Future<void> _handleSwitchpumpright(bool value) async {
    setState(() {
      _pumpright = value;
    });
    await refbutton.update({"$uuid/Buttons/riverButton": value});
  }

  Future<void> _handleSwitchdoor1(bool value) async {
    setState(() {
      _door1 = value;
    });
    await refbutton.update({"$uuid/Buttons/door1Button": value});
  }

  Future<void> _handleSwitchdoor2(bool value) async {
    setState(() {
      _door2 = value;
    });
    await refbutton.update({"$uuid/Buttons/door2Button": value});
  }

  void getDataFromFirestore() async {
    DocumentSnapshot documentSnapshot =
        await devicesCollection.doc(widget.deviceId).get();

    if (documentSnapshot.exists) {
      setState(() {
        deviceName = documentSnapshot.get('device_name');
        uuid = documentSnapshot.get('uuid');
      });

      refbutton.child("/$uuid/Buttons").onValue.listen((event) {
        setState(() {
          // Update the state of the buttons based on the new values in the database
          _auto = event.snapshot.child("AutoButton").value as bool? ?? false;
          _drain = event.snapshot.child("drainButton").value as bool? ?? false;
          _pumpleft =
              event.snapshot.child("VillageButton").value as bool? ?? false;
          _pumpright =
              event.snapshot.child("riverButton").value as bool? ?? false;
          _door1 = event.snapshot.child("door1Button").value as bool? ?? false;
          _door2 = event.snapshot.child("door2Button").value as bool? ?? false;
        });
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
          ],
        ),
      ),
    );
  }
}

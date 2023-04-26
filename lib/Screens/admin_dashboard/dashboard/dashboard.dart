import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart' as fb;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class DashBoardPage extends StatefulWidget {
  final String deviceId;
  const DashBoardPage({super.key, required this.deviceId});
  @override
  // ignore: library_private_types_in_public_api
  _DashBoardPageState createState() => _DashBoardPageState();
}

class _DashBoardPageState extends State<DashBoardPage> {
  bool _auto = false;
  bool _drain = false;
  bool _pumpleft = false;
  bool _pumpright = false;
  bool _door1 = false;
  bool _door2 = false;
  int _direction = 0;
  int _ultrasonicleft = 0;
  int _ultrasonicright = 0;
  double _humidity = 0;
  double _temperature = 0;
  double ultrasonicleftvalue = 0;
  double ultrasonicrightvalue = 0;
  double _rain = 0;
  double _windspeed = 0;
  fb.DatabaseReference refbutton = fb.FirebaseDatabase.instance.ref("/");
  fb.DatabaseReference refsensor = fb.FirebaseDatabase.instance.ref("/");
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  CollectionReference devicesCollection =
      FirebaseFirestore.instance.collection('Devices');
  String deviceName = '';
  String uuid = '';
  String _userRole = '';

  StreamSubscription<fb.DatabaseEvent>? _buttonSubscription;
  StreamSubscription<fb.DatabaseEvent>? _sensorSubscription;

  @override
  void initState() {
    super.initState();
    getDataFromFirestore();
    _loadUserRole();
  }

  @override
  void dispose() {
    _buttonSubscription?.cancel();
    _sensorSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadUserRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userRole = prefs.getString('userRole');
    setState(() {
      _userRole = userRole ?? '';
    });
  }

  void getDataFromFirestore() async {
    DocumentSnapshot documentSnapshot =
        await devicesCollection.doc(widget.deviceId).get();

    if (documentSnapshot.exists) {
      setState(() {
        deviceName = documentSnapshot.get('device_name');
        uuid = documentSnapshot.get('uuid');
      });
      _buttonSubscription =
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
      _sensorSubscription =
          refbutton.child("/$uuid/Sensors").onValue.listen((event) {
        setState(() {
          // Update the state of the buttons based on the new values in the database
          _ultrasonicleft =
              (event.snapshot.child("VillageSensor").value as num?)?.toInt() ??
                  0;
          _ultrasonicright =
              (event.snapshot.child("RiverSensor").value as num?)?.toInt() ?? 0;
          _direction =
              (event.snapshot.child("Direction").value as num?)?.toInt() ?? 0;
          _humidity =
              (event.snapshot.child("Humidity").value as num?)?.toDouble() ??
                  0.0;
          _temperature =
              (event.snapshot.child("Temperature").value as num?)?.toDouble() ??
                  0.0;
          _rain =
              (event.snapshot.child("RainGuage").value as num?)?.toDouble() ??
                  0.0;
          _windspeed =
              (event.snapshot.child("WindSpeed").value as num?)?.toDouble() ??
                  0.0;
        });
      });
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_userRole == 'admin')
              const Text(
                'Control:',
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
            const SizedBox(height: 16.0),
            if (_userRole == 'admin')
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
            if (_userRole == 'admin')
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
            if (_userRole == 'admin')
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
            if (_userRole == 'admin') const SizedBox(height: 16.0),
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

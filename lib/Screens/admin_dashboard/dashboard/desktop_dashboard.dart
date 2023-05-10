import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart' as fb;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class DesktopDashBoardPage extends StatefulWidget {
  final String deviceId;
  const DesktopDashBoardPage({super.key, required this.deviceId});
  @override
  // ignore: library_private_types_in_public_api
  _DesktopDashBoardPageState createState() => _DesktopDashBoardPageState();
}

class _DesktopDashBoardPageState extends State<DesktopDashBoardPage> {
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
  CollectionReference activityCollection =
      FirebaseFirestore.instance.collection('Activity');
  String deviceName = '';
  String uuid = '';
  String _userRole = '';
  String _userSurname = '';
  String _userName = '';

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
    String? userSurname = prefs.getString('userSurname');
    String? userName = prefs.getString('userName');
    setState(() {
      _userRole = userRole ?? '';
      _userSurname = userSurname ?? '';
      _userName = userName ?? '';
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

    String action = value ? 'open' : 'close';
    await activityCollection.add({
      'button': 'AutoButton',
      'value': action,
      'timestamp': FieldValue.serverTimestamp(),
      'user': '$_userName $_userSurname',
      'uuid': uuid
    });
  }

  Future<void> _handleSwitchdrain(bool value) async {
    setState(() {
      _drain = value;
    });
    await refbutton.update({"$uuid/Buttons/drainButton": value});

    String action = value ? 'open' : 'close';

    await activityCollection.add({
      'button': 'Drain',
      'value': action,
      'timestamp': FieldValue.serverTimestamp(),
      'user': '$_userName $_userSurname',
      'uuid': uuid
    });
  }

  Future<void> _handleSwitchpumpleft(bool value) async {
    setState(() {
      _pumpleft = value;
    });
    await refbutton.update({"$uuid/Buttons/VillageButton": value});

    String action = value ? 'open' : 'close';

    await activityCollection.add({
      'button': 'PumpLeft',
      'value': action,
      'timestamp': FieldValue.serverTimestamp(),
      'user': '$_userName $_userSurname',
      'uuid': uuid
    });
  }

  Future<void> _handleSwitchpumpright(bool value) async {
    setState(() {
      _pumpright = value;
    });
    await refbutton.update({"$uuid/Buttons/riverButton": value});

    String action = value ? 'open' : 'close';

    await activityCollection.add({
      'button': 'PumpRight',
      'value': action,
      'timestamp': FieldValue.serverTimestamp(),
      'user': '$_userName $_userSurname',
      'uuid': uuid
    });
  }

  Future<void> _handleSwitchdoor1(bool value) async {
    setState(() {
      _door1 = value;
    });
    await refbutton.update({"$uuid/Buttons/door1Button": value});

    String action = value ? 'open' : 'close';

    await activityCollection.add({
      'button': 'Door1',
      'value': action,
      'timestamp': FieldValue.serverTimestamp(),
      'user': '$_userName $_userSurname',
      'uuid': uuid
    });
  }

  Future<void> _handleSwitchdoor2(bool value) async {
    setState(() {
      _door2 = value;
    });
    await refbutton.update({"$uuid/Buttons/door2Button": value});

    String action = value ? 'open' : 'close';

    await activityCollection.add({
      'button': 'Door2',
      'value': action,
      'timestamp': FieldValue.serverTimestamp(),
      'user': '$_userName $_userSurname',
      'uuid': uuid
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sensor Value:',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    width: 200,
                    height: 100,
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      color: Colors.white,
                      child: ListTile(
                        leading: const Icon(Icons.water),
                        title: const Text('VillageSensor'),
                        subtitle: Text('$_ultrasonicleft cm'),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: SizedBox(
                    width: 200,
                    height: 100,
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      color: Colors.white,
                      child: ListTile(
                        leading: const Icon(Icons.water),
                        title: const Text('RiverSensor'),
                        subtitle: Text('$_ultrasonicright cm'),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: SizedBox(
                    width: 200,
                    height: 100,
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      color: Colors.white,
                      child: ListTile(
                        leading: const Icon(Icons.thermostat),
                        title: const Text('Temperature'),
                        subtitle: Text('$_temperature °C'),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: SizedBox(
                    width: 200,
                    height: 100,
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      color: Colors.white,
                      child: ListTile(
                        leading: const Icon(Icons.opacity),
                        title: const Text('Humidity'),
                        subtitle: Text('$_humidity %'),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: SizedBox(
                    width: 200,
                    height: 100,
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      color: Colors.white,
                      child: ListTile(
                        leading: const Icon(Icons.beach_access),
                        title: const Text('Rain'),
                        subtitle: Text('$_rain mm'),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: SizedBox(
                    width: 200,
                    height: 100,
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      color: Colors.white,
                      child: ListTile(
                        leading: const Icon(Icons.compass_calibration),
                        title: const Text('Direction'),
                        subtitle: Text('$_direction'),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: SizedBox(
                    width: 200,
                    height: 100,
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      color: Colors.white,
                      child: ListTile(
                        leading: const Icon(Icons.speed),
                        title: const Text('Wind Speed'),
                        subtitle: Text('$_windspeed m/s'),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
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
                    child: GestureDetector(
                      onTap: () => _handleSwitchAuto(!_auto),
                      child: _buildButtonCard(
                        title: 'Auto',
                        icon: _auto ? Icons.toggle_on : Icons.toggle_off,
                        color: _getButtonColor(_auto),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _handleSwitchdrain(!_drain),
                      child: _buildButtonCard(
                        title: 'Drain',
                        icon: _drain ? Icons.toggle_on : Icons.toggle_off,
                        color: _getButtonColor(_drain),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _handleSwitchpumpleft(!_pumpleft),
                      child: _buildButtonCard(
                        title: 'Pump Left',
                        icon: _pumpleft ? Icons.toggle_on : Icons.toggle_off,
                        color: _getButtonColor(_pumpleft),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _handleSwitchpumpright(!_pumpright),
                      child: _buildButtonCard(
                        title: 'Pump Right',
                        icon: _pumpright ? Icons.toggle_on : Icons.toggle_off,
                        color: _getButtonColor(_pumpright),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _handleSwitchdoor1(!_door1),
                      child: _buildButtonCard(
                        title: 'Door 1',
                        icon: _door1 ? Icons.toggle_on : Icons.toggle_off,
                        color: _getButtonColor(_door1),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _handleSwitchdoor2(!_door2),
                      child: _buildButtonCard(
                        title: 'Door 2',
                        icon: _door2 ? Icons.toggle_on : Icons.toggle_off,
                        color: _getButtonColor(_door2),
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

  Color _getButtonColor(bool state) {
    return state ? Colors.green : Colors.red;
  }

  Widget _buildButtonCard(
      {required String title, required IconData icon, required Color color}) {
    return Card(
      elevation: 4.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 8.0),
            Icon(
              icon,
              color: color,
            ),
          ],
        ),
      ),
    );
  }
}

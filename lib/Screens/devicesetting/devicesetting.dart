// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'dart:async';

import 'package:alert/controllers/constants.dart';
import 'package:alert/controllers/responsive.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart' as fb;

class DeviceSettingsPage extends StatefulWidget {
  final String uuid;

  const DeviceSettingsPage({super.key, required this.uuid});

  @override
  _DeviceSettingsPageState createState() => _DeviceSettingsPageState();
}

class _DeviceSettingsPageState extends State<DeviceSettingsPage> {
  final TextEditingController _villageSensor = TextEditingController();
  final TextEditingController _riverSensor = TextEditingController();
  final TextEditingController _rain = TextEditingController();
  final TextEditingController _windSpeed = TextEditingController();
  final TextEditingController _temperature = TextEditingController();
  fb.DatabaseReference refalertsensor = fb.FirebaseDatabase.instance.ref("/");
  StreamSubscription<fb.DatabaseEvent>? _settingsSubscription;

  double? _temperaturedata;
  double? _raindata;
  double? _windSpeeddata;
  double? _villageSensordata;
  double? _riverSensordata;

  CollectionReference devicesCollection =
      FirebaseFirestore.instance.collection('Devices');

  String _deviceName = '';
  String uuid = '';
  String deviceuuid = '';

  @override
  void initState() {
    super.initState();
    _getDeviceName();
    getDataFromFirestore();
    // print(widget.uuid);
  }

  Future<void> _getDeviceName() async {
    final deviceDoc = await FirebaseFirestore.instance
        .collection('Devices')
        .doc(widget.uuid)
        .get();
    setState(() {
      _deviceName = deviceDoc['device_name'];
    });
  }

  void getDataFromFirestore() async {
    DocumentSnapshot documentSnapshot =
        await devicesCollection.doc(widget.uuid).get();

    if (documentSnapshot.exists) {
      setState(() {
        _deviceName = documentSnapshot.get('device_name');
        uuid = documentSnapshot.get('uuid');
      });
      _settingsSubscription =
          refalertsensor.child("/$uuid/Settings").onValue.listen((event) {
        setState(() {
          // Update the state of the buttons based on the new values in the database
          _raindata =
              (event.snapshot.child("RainGuage").value as num?)?.toDouble();
          _villageSensordata =
              (event.snapshot.child("VillageSensor").value as num?)?.toDouble();
          _riverSensordata =
              (event.snapshot.child("RiverSensor").value as num?)?.toDouble();
          _windSpeeddata =
              (event.snapshot.child("WindSpeed").value as num?)?.toDouble();
          _temperaturedata =
              (event.snapshot.child("temperature").value as num?)?.toDouble();
        });
        _riverSensor.text = _riverSensordata.toString();
        _villageSensor.text = _villageSensordata.toString();
        _rain.text = _raindata.toString();
        _windSpeed.text = _windSpeeddata.toString();
        _temperature.text = _temperaturedata.toString();
      });
    }
  }

  @override
  void dispose() {
    _villageSensor.dispose();
    _riverSensor.dispose();
    _rain.dispose();
    _windSpeed.dispose();
    _temperature.dispose();
    _settingsSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        appBar: Responsive.isMobile(context)
            ? AppBar(
                title: const Text('Add a new device'),
                backgroundColor: kPrimaryColor,
              )
            : null,
        body: Center(
          child: Container(
            width: 500,
            height: 800,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: SingleChildScrollView(
              // Wrap the Column with SingleChildScrollView
              child: Column(
                children: <Widget>[
                  Text.rich(
                    TextSpan(
                      text: 'Flood Alert Notification: ',
                      style: const TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      children: [
                        TextSpan(
                          text: _deviceName,
                          style: const TextStyle(
                            color: kPrimaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  const Text(
                    'Please enter the following details to settings notification:',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _villageSensor,
                    decoration: const InputDecoration(
                      labelText: 'villageSensor',
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _riverSensor,
                    decoration: const InputDecoration(
                      labelText: 'riverSensor',
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _rain,
                    decoration: const InputDecoration(
                      labelText: 'rainGuage',
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _windSpeed,
                    decoration: const InputDecoration(
                      labelText: 'windSpeed',
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _temperature,
                    decoration: const InputDecoration(
                      labelText: 'temperature',
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () async {
                      DocumentSnapshot documentSnapshot =
                          await devicesCollection.doc(widget.uuid).get();
                      deviceuuid = documentSnapshot.get('uuid');
                      double temperature = double.parse(_temperature.text);
                      double rain = double.parse(_rain.text);
                      double windSpeed = double.parse(_windSpeed.text);
                      double villageSensor = double.parse(_villageSensor.text);
                      double riverSensor = double.parse(_riverSensor.text);

                      // Save the data to Firestore
                      await FirebaseFirestore.instance
                          .collection('Devices')
                          .doc(widget.uuid)
                          .collection('SettingSensor')
                          .doc('data')
                          .update({
                        'temperature': temperature,
                        'rainGuage': rain,
                        'windSpeed': windSpeed,
                        'villageSensor': villageSensor,
                        'riverSensor': riverSensor,
                      });

                      await refalertsensor.child('/$deviceuuid/Settings').update({
                        'temperature': temperature,
                        'RainGuage': rain,
                        'WindSpeed': windSpeed,
                        'VillageSensor': villageSensor,
                        'RiverSensor': riverSensor,
                      });

                      Navigator.pop(context);
                    },
                    child: const Text('Save'),
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.red),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
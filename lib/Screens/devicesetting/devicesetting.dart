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
  final TextEditingController _pumpwt = TextEditingController();
  final TextEditingController _drainwt = TextEditingController();
  final TextEditingController _drainwt2 = TextEditingController();
  final TextEditingController _pumpbwt = TextEditingController();
  final TextEditingController _drainbwt = TextEditingController();
  final TextEditingController _drainwt3 = TextEditingController();
  final TextEditingController _rain = TextEditingController();
  final TextEditingController _windSpeed = TextEditingController();
  final TextEditingController _temperature = TextEditingController();
  fb.DatabaseReference refalertsensor = fb.FirebaseDatabase.instance.ref("/");
  StreamSubscription<fb.DatabaseEvent>? _settingsSubscription;

  double? _temperaturedata;
  double? _raindata;
  double? _windSpeeddata;
  // double? _pumpwtdata;
  // double? _drainwtdata;
  double? _pumpwtdata;
  double? _drainwtdata;
  double? _drainwt2data;
  double? _pumpbwtdata;
  double? _drainbwtdata;
  double? _drainwt3data;

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
              (event.snapshot.child("RainGuage").value as num?)?.toDouble() ?? 0.0;
          _windSpeeddata =
              (event.snapshot.child("WindSpeed").value as num?)?.toDouble() ?? 0.0;
          _temperaturedata =
              (event.snapshot.child("temperature").value as num?)?.toDouble() ?? 0.0;
          _pumpwtdata =
              (event.snapshot.child("pumpwt").value as num?)?.toDouble();
          _drainwtdata =
              (event.snapshot.child("drainwt").value as num?)?.toDouble();
          _drainwt2data =
              (event.snapshot.child("drainwt2").value as num?)?.toDouble();
          _pumpbwtdata =
              (event.snapshot.child("pumpbwt").value as num?)?.toDouble();
          _drainbwtdata =
              (event.snapshot.child("drainbwt").value as num?)?.toDouble();
          _drainwt3data =
              (event.snapshot.child("drainwt3").value as num?)?.toDouble();
        });
        _rain.text = _raindata.toString();
        _windSpeed.text = _windSpeeddata.toString();
        _temperature.text = _temperaturedata.toString();
        _pumpwt.text = _pumpwtdata.toString();
        _drainwt.text = _drainwtdata.toString();
        _drainwt2.text = _drainwt2data.toString();
        _pumpbwt.text = _pumpbwtdata.toString();
        _drainbwt.text = _drainbwtdata.toString();
        _drainwt3.text = _drainwt3data.toString();
      });
    }
  }

  @override
  void dispose() {
    _pumpwt.dispose();
    _drainwt.dispose();
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
                    controller: _pumpwt,
                    decoration: const InputDecoration(
                      labelText: 'pumpwt',
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _drainwt,
                    decoration: const InputDecoration(
                      labelText: 'drainwt',
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _drainwt2,
                    decoration: const InputDecoration(
                      labelText: 'drainwt2',
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _pumpbwt,
                    decoration: const InputDecoration(
                      labelText: 'pumpbwt',
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _drainbwt,
                    decoration: const InputDecoration(
                      labelText: 'drainbwt',
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _drainwt3,
                    decoration: const InputDecoration(
                      labelText: 'drainwt3',
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
                      double pumpwt = double.parse(_pumpwt.text);
                      double drainwt = double.parse(_drainwt.text);
                      double drainwt2 = double.parse(_drainwt2.text);
                      double pumpbwt = double.parse(_pumpbwt.text);
                      double drainbwt = double.parse(_drainbwt.text);
                      double drainwt3 = double.parse(_drainwt3.text);

                      // Save the data to Firestore
                      // await FirebaseFirestore.instance
                      //     .collection('Devices')
                      //     .doc(widget.uuid)
                      //     .set({
                      //   'temperature': temperature,
                      //   'rainGuage': rain,
                      //   'windSpeed': windSpeed,
                      //   'pumpwt': pumpwt,
                      //   'drainwt': drainwt,
                      //   'drainwt2': drainwt2,
                      //   'drainbwt': drainbwt,
                      //   'pumpbwt': pumpbwt,
                      //   'drainwt3': drainwt3,
                      // });

                      await refalertsensor.child('/$deviceuuid/Settings').set({
                        'temperature': temperature,
                        'RainGuage': rain,
                        'WindSpeed': windSpeed,
                        'pumpwt': pumpwt,
                        'drainwt': drainwt,
                        'drainwt2': drainwt2,
                        'drainbwt': drainbwt,
                        'pumpbwt': pumpbwt,
                        'drainwt3': drainwt3,
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

// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SettingDevice extends StatefulWidget {
  final String uid;

  const SettingDevice({super.key, required this.uid});

  @override
  _SettingDeviceState createState() => _SettingDeviceState();
}

class _SettingDeviceState extends State<SettingDevice> {
  final TextEditingController _textController1 = TextEditingController();
  final TextEditingController _textController2 = TextEditingController();
  final TextEditingController _textController3 = TextEditingController();
  final TextEditingController _textController4 = TextEditingController();
  final TextEditingController _textController5 = TextEditingController();

  @override
  void dispose() {
    _textController1.dispose();
    _textController2.dispose();
    _textController3.dispose();
    _textController4.dispose();
    _textController5.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextField(
              controller: _textController1,
              decoration: const InputDecoration(
                labelText: 'Field 1',
              ),
            ),
            TextField(
              controller: _textController2,
              decoration: const InputDecoration(
                labelText: 'Field 2',
              ),
            ),
            TextField(
              controller: _textController3,
              decoration: const InputDecoration(
                labelText: 'Field 3',
              ),
            ),
            TextField(
              controller: _textController4,
              decoration: const InputDecoration(
                labelText: 'Field 4',
              ),
            ),
            TextField(
              controller: _textController5,
              decoration: const InputDecoration(
                labelText: 'Field 5',
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                FirebaseFirestore.instance
                    .collection('device')
                    .doc(widget.uid)
                    .collection('SettingSensor')
                    .doc('data')
                    .update({
                  'field1': _textController1.text,
                  'field2': _textController2.text,
                  'field3': _textController3.text,
                  'field4': _textController4.text,
                  'field5': _textController5.text,
                });
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}

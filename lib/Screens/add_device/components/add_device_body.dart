import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class AddDevicePage extends StatefulWidget {
  const AddDevicePage({Key? key}) : super(key: key);
  @override
  // ignore: library_private_types_in_public_api
  _AddDevicePageState createState() => _AddDevicePageState();
}

class _AddDevicePageState extends State<AddDevicePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _typeController = TextEditingController();
  final _serialNumberController = TextEditingController();
  final _qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? _controller;

  void _addDevice() async {
    try {
      // Get the current user's UID
      // final user = FirebaseAuth.instance.currentUser;
      // final uid = user!.uid;

      // Create a new device document in Firestore
      await FirebaseFirestore.instance
          // .collection('users')
          // .doc(uid)
          .collection('Devices')
          .add({
        'device_name': _nameController.text,
        'type': _typeController.text,
        'uuid': _serialNumberController.text,
      });

      // Navigate back to the previous Page
      Future.microtask(() {
        Navigator.pop(context);
      });
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }

  void _onQRViewCreated(QRViewController controller) {
    _controller?.dispose();
    setState(() {
      _controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      controller.pauseCamera();
      List<String> data = scanData.code!.split(',');

      if (data.length == 3) {
        _nameController.text = data[0].trim();
        _typeController.text = data[1].trim();
        _serialNumberController.text = data[2].trim();
        Navigator.of(context).pop();
      } else {
        // Show an error message if the QR code data is not formatted as expected
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid QR code format. Expected: name, type, uuid'),
          ),
        );
      }
    });
  }

  Widget _buildQRScanner() {
    return SizedBox(
      width: 300,
      height: 300,
      child: QRView(
        key: _qrKey,
        onQRViewCreated: _onQRViewCreated,
        overlay: QrScannerOverlayShape(
          borderColor: Colors.red,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: 250,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Device'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _typeController,
                decoration: const InputDecoration(labelText: 'Type'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a type';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _serialNumberController,
                decoration: const InputDecoration(labelText: 'Serial Number'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a serial number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                child: const Text('Scan QR Code'),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => Dialog(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Scan the QR Code',
                              style: TextStyle(fontSize: 20)),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: 300,
                            height: 300,
                            child: _buildQRScanner(),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () {
                              _controller?.stopCamera();
                              _controller?.dispose();
                              Navigator.of(context).pop();
                            },
                            child: const Text('Close Scanner'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                child: const Text('Save'),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _addDevice();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

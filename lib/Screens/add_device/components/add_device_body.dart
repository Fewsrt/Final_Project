// ignore_for_file: use_build_context_synchronously

import 'package:alert/Screens/add_device/components/locationpickerdialog.dart';

import 'package:alert/controllers/constants.dart';
import 'package:alert/controllers/responsive.dart';
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
  final _latController = TextEditingController();
  final _longController = TextEditingController();
  final _qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? _controller;
  double? latitude;
  double? longitude;

  void _addDevice() async {
    final currentTime = DateTime.now();
    try {
      // Create a new device document in Firestore
      await FirebaseFirestore.instance.collection('Devices').add({
        'device_name': _nameController.text,
        'type': _typeController.text,
        'uuid': _serialNumberController.text,
        'lat': latitude,
        'long': longitude,
        'created_at': currentTime.toIso8601String(),
      });

      // Navigate back to the previous Page
      Future.microtask(() {
        Navigator.pop(context);
      });
    } catch (e) {
      // print(e);
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
      width: 200,
      height: 200,
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
            child: SingleChildScrollView(
              child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      if (Responsive.isDesktop(context) ||
                          Responsive.isTablet(context))
                        const Text(
                          'Add a new device',
                          style: TextStyle(
                              fontSize: 24.0, fontWeight: FontWeight.bold),
                        ),
                      const SizedBox(height: 16.0),
                      const Text(
                        'Please enter the following details to add a new device: (it is usually placed below QR code)',
                        style: TextStyle(fontSize: 16.0),
                      ),
                      const SizedBox(height: 16.0),
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextFormField(
                              controller: _nameController,
                              textInputAction: TextInputAction.next,
                              cursorColor: kPrimaryColor,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Please enter Name';
                                }
                                return null;
                              },
                              decoration: const InputDecoration(
                                labelText: "Name",
                                labelStyle: TextStyle(
                                  color: Colors.deepPurpleAccent, //<-- SEE HERE
                                ),
                                prefixIcon: Padding(
                                  padding: EdgeInsets.all(defaultPadding),
                                  child: Icon(Icons.devices_fold_outlined),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16.0),
                            TextFormField(
                              controller: _typeController,
                              textInputAction: TextInputAction.next,
                              cursorColor: kPrimaryColor,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Please enter a type';
                                }
                                return null;
                              },
                              decoration: const InputDecoration(
                                labelText: "Type",
                                labelStyle: TextStyle(
                                  color: Colors.deepPurpleAccent, //<-- SEE HERE
                                ),
                                prefixIcon: Padding(
                                  padding: EdgeInsets.all(defaultPadding),
                                  child: Icon(Icons.type_specimen),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16.0),
                            TextFormField(
                              controller: _serialNumberController,
                              textInputAction: TextInputAction.next,
                              cursorColor: kPrimaryColor,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Please enter a UUID';
                                }
                                return null;
                              },
                              decoration: const InputDecoration(
                                labelText: "UUID",
                                labelStyle: TextStyle(
                                  color: Colors.deepPurpleAccent, //<-- SEE HERE
                                ),
                                prefixIcon: Padding(
                                  padding: EdgeInsets.all(defaultPadding),
                                  child: Icon(Icons.device_hub),
                                ),
                              ),
                            ),
                            if (Responsive.isMobile(context) ||
                                Responsive.isTablet(context))
                              const SizedBox(height: 16.0),
                            if (Responsive.isMobile(context) ||
                                Responsive.isTablet(context))
                              ElevatedButton(
                                child: const Text('Select Location'),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                        content: Responsive.isDesktop(context)
                                            ? SizedBox(
                                                width: 500,
                                                height: 570,
                                                child: Column(
                                                  children: [
                                                    Expanded(
                                                      child: LocationPickerPage(
                                                        onLocationPicked:
                                                            (lat, long) {
                                                          setState(() {
                                                            latitude = lat;
                                                            longitude = long;
                                                          });
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            : SizedBox(
                                                width: 450,
                                                height: 570,
                                                child: Column(
                                                  children: [
                                                    Expanded(
                                                      child: LocationPickerPage(
                                                        onLocationPicked:
                                                            (lat, long) {
                                                          setState(() {
                                                            latitude = lat;
                                                            longitude = long;
                                                          });
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                      );
                                    },
                                  );
                                },
                              ),
                            if (Responsive.isDesktop(context))
                              const SizedBox(height: 16.0),
                            if (Responsive.isDesktop(context))
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _latController,
                                      textInputAction: TextInputAction.next,
                                      keyboardType: TextInputType.number,
                                      cursorColor: kPrimaryColor,
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return 'Please enter latitude';
                                        }
                                        return null;
                                      },
                                      decoration: const InputDecoration(
                                        labelText: "Latitude",
                                        labelStyle: TextStyle(
                                          color: Colors.deepPurpleAccent,
                                        ),
                                        prefixIcon: Padding(
                                          padding:
                                              EdgeInsets.all(defaultPadding),
                                          child: Icon(Icons.map),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16.0),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _longController,
                                      textInputAction: TextInputAction.done,
                                      keyboardType: TextInputType.number,
                                      cursorColor: kPrimaryColor,
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return 'Please enter longitude';
                                        }
                                        return null;
                                      },
                                      decoration: const InputDecoration(
                                        labelText: "Longitude",
                                        labelStyle: TextStyle(
                                          color: Colors.deepPurpleAccent,
                                        ),
                                        prefixIcon: Padding(
                                          padding:
                                              EdgeInsets.all(defaultPadding),
                                          child: Icon(Icons.map),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            if (Responsive.isMobile(context) ||
                                Responsive.isTablet(context))
                              const SizedBox(height: 16.0),
                            if (Responsive.isMobile(context) ||
                                Responsive.isTablet(context))
                              ElevatedButton(
                                child: const Text('Scan QR Code'),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => Dialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const SizedBox(height: 16),
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
                                            style: ButtonStyle(
                                              minimumSize:
                                                  MaterialStateProperty.all(
                                                      const Size(200, 50)),
                                            ),
                                            child: const Text('Close Scanner'),
                                          ),
                                          const SizedBox(height: 16)
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
                            const SizedBox(height: 16.0),
                            ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.red),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('Cancel'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )),
            ),
          ),
        ),
      ),
    );
  }
}

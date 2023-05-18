// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:alert/Screens/devicesetting/devicesetting.dart';
import 'package:alert/controllers/constants.dart';
import 'package:alert/controllers/responsive.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:alert/Screens/admin_dashboard/admin_dashboard.dart';
import 'package:alert/Screens/add_device/add_device.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_database/firebase_database.dart';

class ListDevicePage extends StatefulWidget {
  const ListDevicePage({Key? key}) : super(key: key);

  @override
  State<ListDevicePage> createState() => _ListDevicePageState();
}

class _ListDevicePageState extends State<ListDevicePage> {
  bool sort = true;
  int _sortColumnIndex = 0; // new state variable to track sorted column index
  String _userRole = '';
  List<Device> _allData = [];
  List<Device> _filteredData = [];
  StreamSubscription<QuerySnapshot>? _devicesSubscription;

  DatabaseReference ref = FirebaseDatabase.instance.ref('/');
  StreamSubscription<DatabaseEvent>? _statusSubscription;
  String _status = '';
  Map<String, dynamic> statusrealtime = {};
  bool _isDisposed = false;

  Future<void> _loadDeviceStatuses() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('Devices').get();
    for (var doc in snapshot.docs) {
      getStatusData(doc);
    }
  }

  Future<void> getStatusData(DocumentSnapshot doc) async {
    final String uuid = doc.get('uuid');
    _statusSubscription =
        ref.child("/$uuid/Status").onValue.listen((event) async {
      _status = event.snapshot.value as String;
      if (!_isDisposed) {
        setState(() {
          statusrealtime[uuid] = _status;
          // print(statusData);
        });
      }
    });
  }

  Future<void> _listenToDeviceStatus() async {
    final firestore = FirebaseFirestore.instance;

    _devicesSubscription?.cancel();
    _devicesSubscription = _deviceStream().listen((devicesSnapshot) {
      final devicesDocs = devicesSnapshot.docs;
      setState(() {
        _allData = devicesDocs.map((doc) => Device.fromFirestore(doc)).toList();
        _filteredData = _allData;
      });

      // Listen for real-time status updates
      for (var doc in devicesDocs) {
        final String uuid = doc.get('uuid');
        final DatabaseReference deviceStatusRef =
            FirebaseDatabase.instance.ref('/$uuid/Status');

        deviceStatusRef.onValue.listen((event) {
          final status = event.snapshot.value as String?;

          if (!_isDisposed) {
            setState(() {
              statusrealtime[uuid] = status;
            });
          }
        });
      }
    });
  }

  @override
  void initState() {
    _devicesSubscription = _deviceStream().listen((devicesSnapshot) {
      final devicesDocs = devicesSnapshot.docs;
      setState(() {
        _allData = devicesDocs.map((doc) => Device.fromFirestore(doc)).toList();
        _filteredData = _allData;
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserRole();
      _listenToDeviceStatus();
    });

    super.initState();
  }

  @override
  void dispose() {
    _devicesSubscription?.cancel();
    _statusSubscription?.cancel();
    _isDisposed = true;
    super.dispose();
  }

  Stream<QuerySnapshot> _deviceStream() {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    return firestore
        .collection('Devices')
        .orderBy('created_at', descending: false)
        .snapshots();
  }

  Future<void> _loadUserRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userRole = prefs.getString('userRole');
    setState(() {
      _userRole = userRole ?? '';
    });
  }

  void _onSortColumn(int columnIndex, bool ascending) {
    setState(() {
      if (_filteredData.isNotEmpty) {
        if (columnIndex == 0) {
          if (ascending) {
            _filteredData.sort((a, b) => a.name.compareTo(b.name));
          } else {
            _filteredData.sort((a, b) => b.name.compareTo(a.name));
          }
        } else if (columnIndex == 2) {
          if (ascending) {
            _filteredData.sort((a, b) => a.status.compareTo(b.status));
          } else {
            _filteredData.sort((a, b) => b.status.compareTo(a.status));
          }
        }
      }
    });
  }

  void _onFilterTextChanged(String value) {
    setState(() {
      _filteredData = _allData
          .where((device) =>
              device.name.toLowerCase().contains(value.toLowerCase()) ||
              device.uuid.toLowerCase().contains(value.toLowerCase()) ||
              device.status.toLowerCase().contains(value.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenHeight = screenSize.height;
    final rowsPerPage = (screenHeight / 90).floor();

    return Scaffold(
      body: SingleChildScrollView(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
            Container(
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.all(0),
              constraints: const BoxConstraints(
                maxHeight: 700,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: Theme(
                      data: ThemeData.light().copyWith(
                        cardColor: Colors.white,
                      ),
                      child: PaginatedDataTable(
                        sortColumnIndex:
                            _sortColumnIndex, // use the state variable
                        sortAscending: sort,
                        header: Container(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            decoration: const InputDecoration(
                              hintText: 'Enter something to filter',
                            ),
                            onChanged: _onFilterTextChanged,
                          ),
                        ),
                        source: RowSource(
                          context: context,
                          myData: _filteredData,
                          count: _filteredData.length,
                          statusData: statusrealtime,
                        ),
                        rowsPerPage: rowsPerPage,
                        columnSpacing: 8,
                        columns: [
                          DataColumn(
                            label: Row(
                              children: const [
                                Text(
                                  'Device Name',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            onSort: (columnIndex, ascending) {
                              setState(() {
                                sort = !sort;
                                _sortColumnIndex =
                                    columnIndex; // update the index of the sorted column
                              });
                              _onSortColumn(columnIndex, ascending);
                            },
                          ),
                          const DataColumn(
                            label: Text(
                              'UUID',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Row(
                              children: const [
                                Text(
                                  'Status',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            onSort: (columnIndex, ascending) {
                              setState(() {
                                sort = !sort;
                                _sortColumnIndex =
                                    columnIndex; // update the index of the sorted column
                              });
                              _onSortColumn(columnIndex, ascending);
                            },
                          ),
                          const DataColumn(
                            label: Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                'Edit',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                          const DataColumn(
                              label: Text(
                                'Delete',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              numeric: true),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ])),
      floatingActionButton: (!kIsWeb || Responsive.isDesktop(context))
          ? _buildFloatingActionButton()
          : null,
    );
  }

  Widget _buildFloatingActionButton() {
    return FutureBuilder<DocumentSnapshot>(
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError) {
          return const SizedBox.shrink();
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }
        if (_userRole == 'admin') {
          return FloatingActionButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    content: Responsive.isDesktop(context)
                        ? SizedBox(
                            width: 570, // set width here
                            height: 570, // set height here
                            child: Column(
                              children: const [
                                Expanded(
                                  child: AddDeviceScreen(),
                                ),
                              ],
                            ),
                          )
                        : SizedBox(
                            width: 570, // set width here
                            height: 620, // set height here
                            child: Column(
                              children: const [
                                Expanded(
                                  child: AddDeviceScreen(),
                                ),
                              ],
                            ),
                          ),
                  );
                },
              );
            },
            backgroundColor: kPrimaryColor,
            child: const Icon(Icons.add),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}

class RowSource extends DataTableSource {
  final BuildContext context;
  final List<Device> myData;
  final int count;
  late FirebaseAuth _auth;
  late User user;
  final Map<String, dynamic> statusData;

  RowSource({
    required this.context,
    required this.myData,
    required this.count,
    required this.statusData,
  }) {
    _auth = FirebaseAuth.instance;
    user = _auth.currentUser!;
  }

  @override
  DataRow? getRow(int index) {
    if (index < rowCount) {
      final device = myData[index];
      final String status = (statusData[device.uuid] ?? 'Offline') as String;
      final bool isOnline = (status == 'Online');
      final statusText = isOnline ? 'Online' : 'Offline';
      final statusColor = isOnline ? Colors.green : Colors.red;
      return DataRow(
        cells: [
          DataCell(
            Text(device.name),
            onTap: isOnline
                ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AdminDashboardPage(deviceId: device.id),
                      ),
                    );
                  }
                : null,
          ),
          DataCell(Text(device.uuid)),
          DataCell(
            Text(
              statusText,
              style: TextStyle(
                color: statusColor,
              ),
            ),
          ),
          DataCell(
            ElevatedButton(
              onPressed: isOnline
                  ? () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            content: Responsive.isDesktop(context)
                                ? SizedBox(
                                    width: 570, // set width here
                                    height: 570, // set height here
                                    child: Column(
                                      children: [
                                        Expanded(
                                          child: DeviceSettingsPage(
                                              uuid: device.id),
                                        ),
                                      ],
                                    ),
                                  )
                                : SizedBox(
                                    width: 570, // set width here
                                    height: 570, // set height here
                                    child: Column(
                                      children: [
                                        Expanded(
                                          child: DeviceSettingsPage(
                                              uuid: device.id),
                                        ),
                                      ],
                                    ),
                                  ),
                          );
                        },
                      );
                    }
                  : null,
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                  isOnline ? kPrimaryColor : Colors.grey, // Updated color
                ),
              ),
              child: const Text('Edit'),
            ),
          ),
          DataCell(
            _buildDeleteButton(device),
          ),
        ],
      );
    } else {
      return null;
    }
  }

Future<void> _deleteDevice(String deviceId) async {
  // Get a reference to the Firebase Realtime Database.
  DatabaseReference ref = FirebaseDatabase.instance.ref('/');

  // Get a reference to the document in Firestore.
  DocumentReference docRef = FirebaseFirestore.instance.collection('Devices').doc(deviceId);
  
  // Fetch the document to get the uuid.
  DocumentSnapshot doc = await docRef.get();
  
  if (!doc.exists) {
    throw Exception('Device not found');
  }

  // Get the uuid from the document.
  String uuid = doc.get('uuid');
  
  // Get a reference to the child node in Firebase Realtime Database.
  DatabaseReference deleteRef = ref.child(uuid);

  // Delete the document in Firestore.
  await docRef.delete();
  
  // Remove the child node in Firebase Realtime Database.
  await deleteRef.remove();
}


  Future<void> _showConfirmationDialog(
      BuildContext context, String deviceId, String deviceName) async {
    final passwordController = TextEditingController();
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text.rich(
            TextSpan(
              children: [
                const TextSpan(
                  text: 'Confirm Password to delete',
                ),
                const TextSpan(
                  text: ': "',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: deviceName,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: kPrimaryColor),
                ),
                const TextSpan(
                  text: '"',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          content: TextField(
            obscureText: true,
            controller: passwordController,
            decoration: const InputDecoration(
              labelText: 'Enter your password',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all<Color>(Colors.red),
              ),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final password = passwordController.text;
                final credential = EmailAuthProvider.credential(
                    email: user.email!, password: password);
                try {
                  await user.reauthenticateWithCredential(credential);
                  Navigator.pop(context);
                  // Password confirmed, proceed with deleting data
                  await _deleteDevice(deviceId);
                } on FirebaseAuthException catch (e) {
                  // Handle incorrect password error
                  if (e.code == 'wrong-password') {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text('Incorrect password. Please try again.')),
                    );
                  }
                }
              },
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(Colors.deepPurpleAccent),
                foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
              ),
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDeleteButton(Device device) {
    return IconButton(
      onPressed: () {
        _showConfirmationDialog(context, device.id, device.name);
      },
      icon: const Icon(Icons.delete),
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => count;

  @override
  int get selectedRowCount => 0;
}

class Device {
  final String id;
  final String name;
  final String uuid;
  final String status;

  Device({
    required this.id,
    required this.name,
    required this.status,
    required this.uuid,
  });

  factory Device.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Device(
      id: doc.id,
      name: data['device_name'] ?? '',
      uuid: data['uuid'] ?? '',
      status: data['Status'] ?? '',
    );
  }
}

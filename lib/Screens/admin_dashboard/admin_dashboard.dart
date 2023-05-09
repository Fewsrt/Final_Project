// ignore_for_file: library_private_types_in_public_api

import 'package:alert/Screens/admin_dashboard/activityhistory/activityhistory.dart';
import 'package:alert/Screens/admin_dashboard/activityhistory/desktop_activityhistory.dart';
import 'package:alert/Screens/admin_dashboard/dashboard/dashboard.dart';
import 'package:alert/Screens/admin_dashboard/dashboard/desktop_dashboard.dart';
import 'package:alert/Screens/admin_dashboard/datahistory/datahistory.dart';
import 'package:alert/Screens/admin_dashboard/datahistory/desktop_datahistory.dart';
import 'package:alert/controllers/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:alert/controllers/responsive.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Initialize Firebase

  SharedPreferences prefs = await SharedPreferences.getInstance();
  String deviceId = prefs.getString('deviceId') ?? '';

  runApp(AdminDashboardPage(
    deviceId: deviceId,
  ));
}

class AdminDashboardPage extends StatefulWidget {
  final String deviceId;

  const AdminDashboardPage({Key? key, required this.deviceId})
      : super(key: key);

  @override
  _AdminDashboardPageState createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  CollectionReference devicesCollection =
      FirebaseFirestore.instance.collection('Devices');
  String deviceName = '';
  String uuid = '';
  int _selectedIndex = 0;
  String _userRole = '';

  List<Widget> _widgetOptions(String deviceId) {
    return <Widget>[
      if (Responsive.isDesktop(context) || Responsive.isTablet(context))
        DesktopDashBoardPage(deviceId: deviceId)
      else
        DashBoardPage(deviceId: deviceId),
    ];
  }

  void _onItemTapped(int index) {
    if (index == 1) {
      // if "History" item is tapped
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Choose history type'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  if (_userRole == 'admin')
                    ListTile(
                      title: const Text('Activity history'),
                      onTap: () {
                        if (Responsive.isDesktop(context) ||
                            Responsive.isTablet(context)) {
                          Future.microtask(() {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    DesktopActivityHistoryPage(
                                  deviceId: widget.deviceId,
                                  uuid: uuid,
                                ),
                              ),
                            );
                          });
                        }
                        if (Responsive.isMobile(context)) {
                          Future.microtask(() {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ActivityHistoryPage(
                                  deviceId: widget.deviceId,
                                  uuid: uuid,
                                ),
                              ),
                            );
                          });
                        }
                      },
                    ),
                  const Divider(), // add a divider between the options
                  ListTile(
                    title: const Text('Data history'),
                    onTap: () {
                      if (Responsive.isDesktop(context) ||
                          Responsive.isTablet(context)) {
                        Future.microtask(() {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DesktopHistoryPage(
                                deviceId: widget.deviceId,
                                uuid: uuid,
                              ),
                            ),
                          );
                        });
                      }
                      if (Responsive.isMobile(context)) {
                        Future.microtask(() {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DataHistoryPage(
                                deviceId: widget.deviceId,
                                uuid: uuid, // Pass the uuid to DataHistoryPage
                              ),
                            ),
                          );
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  void _handleFloatingActionButtonTap() {
    // Call the _onItemTapped function with the desired index
    _onItemTapped(1); // Example: Pass 1 to navigate to the History page
  }

  @override
  void initState() {
    super.initState();
    getDataFromFirestore();
    _loadUserRole();
    // print(widget.deviceId);
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(deviceName),
        backgroundColor: kPrimaryColor,
      ),
      body: _widgetOptions(widget.deviceId).elementAt(_selectedIndex),
      floatingActionButton: FloatingActionButton(
        onPressed: _handleFloatingActionButtonTap,
        backgroundColor: kPrimaryColor,
        child: const Icon(Icons.history),
      ),
    );
  }
}

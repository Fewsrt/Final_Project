// ignore_for_file: library_private_types_in_public_api

import 'package:alert/Screens/admin_dashboard/activityhistory/activityhistory.dart';
import 'package:alert/Screens/admin_dashboard/dashboard/dashboard.dart';
import 'package:alert/Screens/admin_dashboard/datahistory/datahistory.dart';
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

  const AdminDashboardPage({Key? key, required this.deviceId})
      : super(key: key);

  @override
  _AdminDashboardPageState createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  DatabaseReference refbutton = FirebaseDatabase.instance.ref("/");
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  CollectionReference devicesCollection =
      FirebaseFirestore.instance.collection('Devices');
  String deviceName = '';
  String uuid = '';
  int _selectedIndex = 0;

  static List<Widget> _widgetOptions(String deviceId) {
    return <Widget>[
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
                  ListTile(
                    title: const Text('Activity history'),
                    onTap: () {
                    Future.microtask(() {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ActivityHistoryPage()),
                      );
                    });
                    },
                  ),
                  const Divider(), // add a divider between the options
                  ListTile(
                    title: const Text('Data history'),
                    onTap: () {
                    Future.microtask(() {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const DataHistoryPage()),
                      );
                    });
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

  @override
  void initState() {
    super.initState();
    getDataFromFirestore();
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
      ),
      body: _widgetOptions(widget.deviceId).elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'DashBoard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

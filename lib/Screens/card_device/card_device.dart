import 'package:alert/Screens/add_device/add_device.dart';
import 'package:alert/Screens/admin_dashboard/admin_dashboard.dart';
import 'package:alert/component/custom_drawer.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CardDevicePage extends StatefulWidget {
  const CardDevicePage({super.key});
  @override
  // ignore: library_private_types_in_public_api
  _CardDeviceState createState() => _CardDeviceState();
}

class _CardDeviceState extends State<CardDevicePage> {
  String _userRole = '';

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userRole = prefs.getString('userRole');
    setState(() {
      _userRole = userRole ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Devices'),
      ),
      drawer: const CustomDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: _fetchDevices(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return const Text('Something went wrong');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }

            return _buildCards(snapshot);
          },
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Stream<QuerySnapshot> _fetchDevices() {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    return firestore.collection('Devices').snapshots();
  }

  Widget _buildCards(AsyncSnapshot<QuerySnapshot> snapshot) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
      ),
      itemCount: snapshot.data!.docs.length,
      itemBuilder: (BuildContext context, int index) {
        final DocumentSnapshot device = snapshot.data!.docs[index];
        return Card(
          clipBehavior: Clip.hardEdge,
          child: InkWell(
            splashColor: Colors.blue.withAlpha(30),
            onTap: () {
              // debugPrint('Card tapped.');
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        AdminDashboardPage(deviceId: device.id)),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(device.get('device_name')),
            ),
          ),
        );
      },
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
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const AddDeviceScreen()),
              );
            },
            child: const Icon(Icons.add),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}

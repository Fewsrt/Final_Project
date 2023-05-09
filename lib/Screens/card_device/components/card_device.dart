import 'package:alert/Screens/add_device/add_device.dart';
import 'package:alert/Screens/admin_dashboard/admin_dashboard.dart';
import 'package:alert/controllers/constants.dart';
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
  return firestore
      .collection('Devices')
      .orderBy('created_at', descending: false)
      .snapshots();
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
        final String deviceName = device.get('device_name');
        final String status = device.get('Status');
        final bool isOnline = (status == 'Online');
        final IconData iconData =
            isOnline ? Icons.cloud_outlined : Icons.cloud_off_outlined;
        final Color iconColor = isOnline ? Colors.green : Colors.grey;
        return Card(
          clipBehavior: Clip.hardEdge,
          child: InkWell(
            splashColor: Colors.blue.withAlpha(30),
            onTap: () {
              if (isOnline) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          AdminDashboardPage(deviceId: device.id)),
                );
              }
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Text(
                      deviceName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Icon(
                      iconData,
                      size: 32,
                      color: iconColor,
                    ),
                  ),
                ),
                if (isOnline)
                  Container(
                    padding: const EdgeInsets.all(4.0),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(4.0),
                      border: Border.all(color: Colors.green, width: 2.0),
                    ),
                    child: Center(
                      child: Text(
                        status,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                if (!isOnline)
                  Container(
                    padding: const EdgeInsets.all(4.0),
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(4.0),
                      border: Border.all(color: Colors.grey, width: 2.0),
                    ),
                    child: Center(
                      child: Text(
                        status,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
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

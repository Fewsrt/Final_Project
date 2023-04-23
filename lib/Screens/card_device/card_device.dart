import 'package:alert/Screens/add_device/add_device.dart';
import 'package:alert/Screens/admin_dashboard/admin_dashboard.dart';
import 'package:alert/Screens/signin/signin.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CardDevicePage extends StatefulWidget {
  final User user;
  const CardDevicePage({super.key, required this.user});
  @override
  // ignore: library_private_types_in_public_api
  _CardDeviceState createState() => _CardDeviceState();
}

class _CardDeviceState extends State<CardDevicePage> {
  Stream<QuerySnapshot> fetchDevices() {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    return firestore.collection('Devices').snapshots();
  }

  Widget buildCards(AsyncSnapshot<QuerySnapshot> snapshot) {
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
                    builder: (context) => AdminDashboardPage(deviceId: device.id)),
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

  late final User user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Devices'),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const UserAccountsDrawerHeader(
              accountName: Text('John Doe'),
              accountEmail: Text('johndoe@example.com'),
              currentAccountPicture: CircleAvatar(
                child: Text('JD'),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                // handle navigation to the home page
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                // handle navigation to the settings page
              },
            ),
            const Divider(),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text('Other actions'),
            ),
            // const SizedBox(height: 16.0),
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
            //   child: ElevatedButton(
            //     onPressed: () {
            //       // handle action 1
            //     },
            //     child: const Text('Action 1'),
            //   ),
            // ),
            // const SizedBox(height: 8.0),
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
            //   child: ElevatedButton(
            //     onPressed: () {
            //       // handle action 2
            //     },
            //     child: const Text('Action 2'),
            //   ),
            // ),
            const SizedBox(height: 8.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ElevatedButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  prefs.remove('userId');
                  Future.microtask(() {
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SigninScreen()),
                        (route) => false);
                  });
                },
                child: const Text('Log Out'),
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: fetchDevices(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return const Text('Something went wrong');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }

            return buildCards(snapshot);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddDeviceScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

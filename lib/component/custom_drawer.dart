import 'package:alert/Screens/card_device/card_device.dart';
import 'package:alert/Screens/userlist/userlist.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:alert/Screens/history/history.dart';
import 'package:alert/Screens/signin/signin.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: FutureBuilder(
        future: getUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            final name = snapshot.data!['name'];
            final email = snapshot.data!['email'];
            return ListView(
              children: [
                UserAccountsDrawerHeader(
                  accountName: Text(name),
                  accountEmail: Text(email),
                  currentAccountPicture: CircleAvatar(
                    child: Text(name[0]),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.home),
                  title: const Text('Home'),
                  onTap: () async {
                    final userCredential = FirebaseAuth.instance.currentUser;
                    final uid = userCredential!.uid;
                    final userDoc = await FirebaseFirestore.instance
                        .collection('users')
                        .doc(uid)
                        .get();
                    Future.microtask(() {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              CardDevicePage(user: userCredential),
                        ),
                      );
                    });
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.history),
                  title: const Text('History'),
                  onTap: () {
                    Future.microtask(() {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const HistoryPage()),
                      );
                    });
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.people),
                  title: const Text('Users'),
                  onTap: () {
                    Future.microtask(() {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const UserListScreen()),
                      );
                    });
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Logout'),
                  onTap: () async {
                    await FirebaseAuth.instance.signOut();
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    prefs.remove('userId');
                    Future.microtask(() {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SigninScreen()),
                        (route) => false,
                      );
                    });
                  },
                ),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Future<Map<String, dynamic>?> getUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    final uid = user!.uid;
    final docSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final data = docSnapshot.data();
    return data;
  }
}

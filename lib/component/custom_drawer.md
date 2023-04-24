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
            final name = snapshot.data['name'];
            final email = snapshot.data['email'];
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
                  leading: Icon(Icons.home),
                  title: Text('Home'),
                  onTap: () {
                    // handle navigation to the home page
                  },
                ),
                ListTile(
                  leading: Icon(Icons.history),
                  title: Text('History'),
                  onTap: () {
                    Future.microtask(() {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => HistoryPage()),
                        (route) => false,
                      );
                    });
                  },
                ),
                ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('Logout'),
                  onTap: () async {
                    await FirebaseAuth.instance.signOut();
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    prefs.remove('userId');
                    Future.microtask(() {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => SigninScreen()),
                        (route) => false,
                      );
                    });
                  },
                ),
              ],
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Future<Map<String, dynamic>> getUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    final uid = user.uid;
    final docSnapshot = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final data = docSnapshot.data();
    return data;
  }
}


import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:alert/Screens/history/history.dart';
import 'package:alert/Screens/signin/signin.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
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
            leading: const Icon(Icons.history),
            title: const Text('History'),
            onTap: () {
              Future.microtask(() {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const HistoryPage()),
                    (route) => false);
              });
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.remove('userId');
              Future.microtask(() {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SigninScreen()),
                    (route) => false);
              });
            },
          ),
        ],
      ),
    );
  }
}

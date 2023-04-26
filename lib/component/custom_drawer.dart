// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'package:alert/Screens/map/mapscreen.dart';
import 'package:alert/Screens/usersetting/usersetting.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:alert/Screens/card_device/card_device.dart';
import 'package:alert/Screens/history/history.dart';
import 'package:alert/Screens/signin/signin.dart';
import 'package:alert/Screens/userlist/userlist.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  String _userRole = '';
  String _userName = '';
  String _userEmail = '';

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userRole = prefs.getString('userRole');
    String? userName = prefs.getString('userName');
    String? userEmail = prefs.getString('userEmail');
    setState(() {
      _userRole = userRole ?? '';
      _userName = userName ?? '';
      _userEmail = userEmail ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(_userName),
            accountEmail: Text(_userEmail),
            currentAccountPicture: const CircleAvatar(
              child: Text("TEST"),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.device_hub),
            title: const Text('Devices'),
            onTap: () async {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const CardDevicePage(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.map),
            title: const Text('Maps'),
            onTap: () async {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const MapScreen(),
                ),
              );
            },
          ),
          if (_userRole == 'admin')
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('History'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HistoryPage(),
                  ),
                );
              },
            ),
          if (_userRole == 'admin')
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Users'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UserListScreen(),
                  ),
                );
              },
            ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Setting'),
            onTap: () {
              final uid = FirebaseAuth.instance.currentUser!.uid;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => UserSettingsPage(uid: uid),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.remove('userId');
              prefs.remove('userRole');
              prefs.remove('userName');
              prefs.remove('userEmail');
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const SigninScreen(),
                ),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}

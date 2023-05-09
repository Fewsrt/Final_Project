// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'package:alert/Screens/Welcome/welcome_screen.dart';
import 'package:alert/Screens/card_device/devices.dart';
import 'package:alert/Screens/map/mapscreen.dart';
import 'package:alert/Screens/usersetting/usersetting.dart';
import 'package:alert/controllers/constants.dart';
import 'package:alert/controllers/responsive.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:alert/Screens/history/history.dart';
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
    return Stack(
      children: [
        // Your main content goes here,
        SizedBox(
          width: 200,
          child: Drawer(
            elevation: Responsive.isDesktop(context) ? 0.0 : 16.0,
            child: Container(
              padding: EdgeInsets.zero, // Remove the default padding
              decoration: const BoxDecoration(
                color: kPrimaryLightColor, // Set the desired background color
              ),
              child: ListView(
                children: [
                  SizedBox(
                    height: 180,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 10),
                          Text(
                            _userName,
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight:
                                    FontWeight.bold // Set the desired font size
                                ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _userEmail,
                            style: const TextStyle(
                              fontSize: 16, // Set the desired font size
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.device_hub),
                    title: const Text('Devices'),
                    onTap: () async {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DeviceScreen(),
                        ),
                      );
                    },
                  ),
                  if (Responsive.isMobile(context) || Responsive.isTablet(context))
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
                  if (_userRole == 'admin' && Responsive.isDesktop(context) || Responsive.isTablet(context))
                    ListTile(
                      leading: const Icon(Icons.history),
                      title: const Text('History'),
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HistoryDeviceScreen(),
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
                            builder: (context) => const RoleUserScreen(),
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
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      prefs.remove('userId');
                      prefs.remove('userRole');
                      prefs.remove('userName');
                      prefs.remove('userEmail');
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const WelcomeScreen(),
                        ),
                        (route) => false,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

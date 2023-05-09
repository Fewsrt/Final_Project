// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:alert/Screens/Welcome/welcome_screen.dart';
import 'package:alert/Screens/card_device/devices.dart';
import 'package:alert/Screens/map/mapscreen.dart';
import 'package:alert/Screens/usersetting/usersetting.dart';
import 'package:alert/controllers/constants.dart';
import 'package:alert/controllers/responsive.dart';
import 'package:alert/Screens/history/history.dart';
import 'package:alert/Screens/userlist/userlist.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({Key? key}) : super(key: key);

  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  String _userRole = '';
  String _userName = '';
  String _userEmail = '';

  int _currentIndex = 0;

  List<Widget> _pages(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return [
      const DeviceScreen(key: PageStorageKey('device_screen')),
      const MapScreen(key: PageStorageKey('map_screen')),
      const HistoryDeviceScreen(key: PageStorageKey('history_device_screen')),
      const RoleUserScreen(key: PageStorageKey('role_user_screen')),
      UserSettingsPage(uid: uid, key: const PageStorageKey('user_settings_page')),
    ];
  }

  void _onNavigationItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

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
    Widget drawer = SizedBox(
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
                onTap: () {
                  _onNavigationItemTapped(0);
                  Navigator.of(context).pop(); // Close the drawer
                },
              ),
              if (Responsive.isMobile(context) || Responsive.isTablet(context))
                ListTile(
                  leading: const Icon(Icons.map),
                  title: const Text('Maps'),
                  onTap: () {
                    _onNavigationItemTapped(1);
                    Navigator.of(context).pop(); // Close the drawer
                  },
                ),
              if (_userRole == 'admin' && Responsive.isDesktop(context) ||
                  Responsive.isTablet(context))
                ListTile(
                  leading: const Icon(Icons.history),
                  title: const Text('History'),
                  onTap: () {
                    _onNavigationItemTapped(2);
                    Navigator.of(context).pop(); // Close the drawer
                  },
                ),
              if (_userRole == 'admin')
                ListTile(
                  leading: const Icon(Icons.people),
                  title: const Text('Users'),
                  onTap: () {
                    _onNavigationItemTapped(3);
                    Navigator.of(context).pop(); // Close the drawer
                  },
                ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Setting'),
                onTap: () {
                  _onNavigationItemTapped(4);
                  Navigator.of(context).pop(); // Close the drawer
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
    );

    if (Responsive.isDesktop(context)) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Your App Title'),
        ),
        body: Row(
          children: [
            drawer,
            Expanded(
              child: IndexedStack(
                index: _currentIndex,
                children: _pages(context),
              ),
            ),
          ],
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Your App Title'),
        ),
        drawer: drawer,
        body: IndexedStack(
          index: _currentIndex,
          children: _pages(context),
        ),
      );
    }
  }
}

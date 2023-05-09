import 'package:alert/Screens/Welcome/welcome_screen.dart';
import 'package:alert/controllers/responsive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../components/custom_container.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AuthWrapperState createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  late Stream<User?> _authStateStream;

  @override
  void initState() {
    super.initState();
    // Listen to the authentication state stream
    _authStateStream = FirebaseAuth.instance.authStateChanges();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _authStateStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show a loading spinner while waiting for the authentication state
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else {
          // Check if the user is signed in
          if (snapshot.hasData) {
            User? user = snapshot.data;
            // Save the user's ID to shared preferences or secure storage
            _saveUserRole(user!.uid);
            // User is signed in, navigate to home screen
            return const Responsive(
              mobile: CustomDrawer(),
              desktop: CustomDrawer(),
              tablet: CustomDrawer(),
            );
          } else {
            // User is not signed in, navigate to sign in screen
            return const WelcomeScreen();
          }
        }
      },
    );
  }

  Future<void> _saveUserRole(String userId) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentSnapshot userSnapshot =
        await firestore.collection('users').doc(userId).get();
    String role = userSnapshot.get('role');
    String name = userSnapshot.get('name');
    String email = userSnapshot.get('email');

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('userRole', role);
    prefs.setString('userName', name);
    prefs.setString('userEmail', email);
    prefs.setString('userId', userId);
  }
}

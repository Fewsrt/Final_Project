import 'package:alert/Screens/card_device/card_device.dart';
import 'package:alert/Screens/signin/signin.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
            _saveUserId(user!.uid);
            // User is signed in, navigate to home screen
            return CardDevicePage(user: user);
          } else {
            // User is not signed in, navigate to sign in screen
            return const SigninScreen();
          }
        }
      },
    );
  }

  void _saveUserId(String userId) async {
    // Save the user ID to shared preferences or secure storage
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('userId', userId);
  }
}
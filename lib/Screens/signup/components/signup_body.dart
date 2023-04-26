// ignore_for_file: use_build_context_synchronously

import 'package:alert/Screens/card_device/card_device.dart';
import 'package:alert/Screens/signin/signin.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);
  @override
  // ignore: library_private_types_in_public_api
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUpPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String _name = "";
  String _email = "";
  String _password = "";
  String _role = "user";
  bool _isLoading = false;

  void _handleSignUp() async {
    final FormState? form = _formKey.currentState;
    if (form!.validate()) {
      form.save();
      setState(() {
        _isLoading = true;
      });
      try {
        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: _email,
          password: _password,
        );

        // Store the user data to Cloud Firestore
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'name': _name,
          'email': _email,
          'role': _role,
        });

        await _saveUserRole(userCredential.user!.uid);

        setState(() {
          _isLoading = false;
        });
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => const CardDevicePage(),
          ),
        );
      } on FirebaseAuthException catch (e) {
        setState(() {
          _isLoading = false;
        });
        if (e.code == 'weak-password') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('The password provided is too weak.')),
          );
        } else if (e.code == 'email-already-in-use') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('The account already exists for that email.')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'An error occurred while signing up. Please try again later.')),
          );
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'An error occurred while signing up. Please try again later.')),
        );
      }
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sign Up"),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextFormField(
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(
                      labelText: "Name",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? "Please enter your name" : null,
                    onSaved: (value) => _name = value!,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: "Email",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? "Please enter your email" : null,
                    onSaved: (value) => _email = value!,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextFormField(
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: "Password",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value!.isEmpty
                        ? "Please enter a password"
                        : value.length < 6
                            ? "Password must be at least 6 characters"
                            : null,
                    onSaved: (value) => _password = value!,
                  ),
                ),
                // Padding(
                //   padding: const EdgeInsets.all(16.0),
                //   child: DropdownButtonFormField<String>(
                //     value: _role,
                //     decoration: const InputDecoration(
                //       labelText: "Role",
                //       border: OutlineInputBorder(),
                //     ),
                //     items: <String>['user', 'admin']
                //         .map((value) => DropdownMenuItem(
                //               value: value,
                //               child: Text(value),
                //             ))
                //         .toList(),
                //     onChanged: (value) {
                //       setState(() {
                //         _role = value!;
                //       });
                //     },
                //   ),
                // ),
                const SizedBox(height: 20),
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _handleSignUp,
                        child: const Text("Sign Up"),
                      ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SigninScreen(),
                      ),
                    );
                  },
                  child: const Text('Sign In'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

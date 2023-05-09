// ignore_for_file: library_private_types_in_public_api

import 'package:alert/components/custom_container.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../components/already_have_an_account_acheck.dart';
import '../../../controllers/constants.dart';
import '../../../Screens/signin/signin.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({Key? key}) : super(key: key);

  @override
  _SignUpFormState createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool isLoading = false;

  void _signUp() async {
    final currentTime = DateTime.now();
    if (_formKey.currentState!.validate()) {
      try {
        setState(() {
          isLoading = true; // show loading indicator
        });
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
                email: _emailController.text,
                password: _passwordController.text);
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'name': _nameController.text,
          'surname': _surnameController.text,
          'email': _emailController.text,
          'role': "user",
          'created_at': currentTime.toIso8601String(),
        });

        await _saveUserRole(userCredential.user!.uid);

        Future.microtask(() {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => const CustomDrawer(),
            ),
          );
        });
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message!),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          isLoading = false; // hide loading indicator
        });
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
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          const SizedBox(height: defaultPadding),
          TextFormField(
            controller: _nameController,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            cursorColor: kPrimaryColor,
            onSaved: (name) {},
            validator: (value) {
              if (value!.isEmpty) {
                return 'Please enter your name';
              }
              return null;
            },
            decoration: const InputDecoration(
              labelText: "Your name",
              labelStyle: TextStyle(
                color: Colors.deepPurpleAccent, //<-- SEE HERE
              ),
              prefixIcon: Padding(
                padding: EdgeInsets.all(defaultPadding),
                child: Icon(Icons.person),
              ),
            ),
          ),
          const SizedBox(height: defaultPadding),
          TextFormField(
            controller: _surnameController,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            cursorColor: kPrimaryColor,
            onSaved: (surname) {},
            validator: (value) {
              if (value!.isEmpty) {
                return 'Please enter your surname';
              }
              return null;
            },
            decoration: const InputDecoration(
              labelText: "Your surname",
              labelStyle: TextStyle(
                color: Colors.deepPurpleAccent, //<-- SEE HERE
              ),
              prefixIcon: Padding(
                padding: EdgeInsets.all(defaultPadding),
                child: Icon(Icons.person),
              ),
            ),
          ),
          const SizedBox(height: defaultPadding),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            cursorColor: kPrimaryColor,
            onSaved: (email) {},
            validator: (value) {
              if (value!.isEmpty || !value.contains('@')) {
                return 'Please enter a valid email address.';
              }
              return null;
            },
            decoration: const InputDecoration(
              labelText: "Your email",
              labelStyle: TextStyle(
                color: Colors.deepPurpleAccent, //<-- SEE HERE
              ),
              prefixIcon: Padding(
                padding: EdgeInsets.all(defaultPadding),
                child: Icon(Icons.email),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: defaultPadding),
            child: TextFormField(
              controller: _passwordController,
              textInputAction: TextInputAction.done,
              obscureText: true,
              cursorColor: kPrimaryColor,
              validator: (value) {
                if (value!.isEmpty || value.length < 6) {
                  return 'Please enter a valid password (at least 6 characters).';
                }
                return null;
              },
              decoration: const InputDecoration(
                labelText: "Your password",
                labelStyle: TextStyle(
                  color: Colors.deepPurpleAccent, //<-- SEE HERE
                ),
                prefixIcon: Padding(
                  padding: EdgeInsets.all(defaultPadding),
                  child: Icon(Icons.lock),
                ),
              ),
            ),
          ),
          const SizedBox(height: defaultPadding / 2),
          isLoading
              ? const CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(Colors.deepPurpleAccent))
              : ElevatedButton(
                  onPressed: _signUp,
                  child: const Text("Sign Up"),
                ),
          const SizedBox(height: defaultPadding),
          AlreadyHaveAnAccountCheck(
            login: false,
            press: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return const SigninScreen();
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

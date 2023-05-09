// ignore_for_file: library_private_types_in_public_api

import 'package:alert/controllers/responsive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserSettingsPage extends StatefulWidget {
  final String uid;

  const UserSettingsPage({super.key, required this.uid});

  @override
  _UserSettingsPageState createState() => _UserSettingsPageState();
}

class _UserSettingsPageState extends State<UserSettingsPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  @override
  void initState() {
    super.initState();
    // Fetch user data from Firestore and populate the TextFields and ImageView
    FirebaseFirestore.instance
        .collection("users")
        .doc(widget.uid)
        .get()
        .then((snapshot) {
      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data()!;
        _nameController.text = data["name"];
        _surnameController.text = data["surname"];
        _roleController.text = data["role"];
        _emailController.text = data["email"];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        body: Center(
          child: Container(
            width: 500,
            height: 800,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                if (Responsive.isDesktop(context) || Responsive.isTablet(context)) const SizedBox(height: 30.0),
                if (Responsive.isDesktop(context) || Responsive.isTablet(context))
                  const Text(
                    'Account Settings',
                    style:
                        TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                  ),
                const SizedBox(height: 16.0),
                const Text(
                  'Please enter the following details to change:',
                  style: TextStyle(fontSize: 16.0),
                ),
                const SizedBox(height: 25.0),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: "Name",
                    labelStyle: TextStyle(
                      color: Colors.deepPurpleAccent, //<-- SEE HERE
                    ),
                    hintText: "Enter your name",
                  ),
                ),
                const SizedBox(height: 16.0),
                TextField(
                  controller: _surnameController,
                  decoration: const InputDecoration(
                    labelText: "Surname",
                    labelStyle: TextStyle(
                      color: Colors.deepPurpleAccent, //<-- SEE HERE
                    ),
                    hintText: "Enter your surname",
                  ),
                ),
                const SizedBox(height: 16.0),
                TextField(
                  controller: _roleController,
                  enabled: false,
                  decoration: const InputDecoration(
                    labelText: "Role (It's cannot change)",
                    labelStyle: TextStyle(
                      color: Colors.deepPurpleAccent,
                    ),
                    hintText: "Enter your role",
                  ),
                ),
                const SizedBox(height: 16.0),
                TextField(
                  controller: _emailController,
                  enabled: false,
                  decoration: const InputDecoration(
                    labelText: "Email (It's cannot change)",
                    labelStyle: TextStyle(
                      color: Colors.deepPurpleAccent,
                    ),
                    hintText: "Enter your email",
                  ),
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () async {
                    // Save user data to Firestore
                    FirebaseFirestore.instance
                        .collection("users")
                        .doc(widget.uid)
                        .update({
                      "name": _nameController.text,
                      "surname": _surnameController.text,
                      "role": _roleController.text,
                      "email": _emailController.text,
                    });
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    prefs.setString('userName', _nameController.text);
                  },
                  child: const Text("Save"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

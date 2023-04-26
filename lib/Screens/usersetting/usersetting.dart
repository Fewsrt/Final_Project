// ignore_for_file: library_private_types_in_public_api

import 'package:alert/component/custom_drawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserSettingsPage extends StatefulWidget {
  final String uid;

  const UserSettingsPage({super.key, required this.uid});

  @override
  _UserSettingsPageState createState() => _UserSettingsPageState();
}

class _UserSettingsPageState extends State<UserSettingsPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  String _imageURL = "";

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
        setState(() {
          _imageURL = data["image_url"];
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("User Settings"),
      ),
      drawer: const CustomDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: GestureDetector(
                onTap: () {},
                child: CircleAvatar(
                  radius: 50.0,
                  backgroundImage: _imageURL.isNotEmpty
                      ? NetworkImage(_imageURL)
                      : const NetworkImage(
                          "https://via.placeholder.com/150", // replace with your default avatar URL
                        ),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Name",
                hintText: "Enter your name",
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _surnameController,
              decoration: const InputDecoration(
                labelText: "Surname",
                hintText: "Enter your surname",
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // Save user data to Firestore
                FirebaseFirestore.instance
                    .collection("users")
                    .doc(widget.uid)
                    .set({
                  "name": _nameController.text,
                  "surname": _surnameController.text,
                  "image_url": _imageURL,
                });
              },
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }
}

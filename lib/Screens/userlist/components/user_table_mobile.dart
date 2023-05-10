// ignore_for_file: library_private_types_in_public_api, prefer_interpolation_to_compose_strings, use_build_context_synchronously
import 'package:alert/controllers/responsive.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserMobileScreen extends StatefulWidget {
  const UserMobileScreen({Key? key}) : super(key: key);

  @override
  _UserMobileScreenState createState() => _UserMobileScreenState();
}

class _UserMobileScreenState extends State<UserMobileScreen> {
  late Stream<QuerySnapshot> _usersStream;
  final TextEditingController _searchController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  late FirebaseAuth _auth;
  late User user;

  @override
  void initState() {
    super.initState();
    _usersStream = FirebaseFirestore.instance.collection('users').snapshots();
    _auth = FirebaseAuth.instance;
    user = _auth.currentUser!;
  }

  void _unlockUser(String userId) async {
    final password = passwordController.text;
    final credential =
        EmailAuthProvider.credential(email: user.email!, password: password);

    try {
      await user.reauthenticateWithCredential(credential);
      // Perform unlock action here
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'isLocked': false});

      Navigator.pop(context); // Close the dialog
      passwordController.clear();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Incorrect password. Please try again.')));
      }
    }
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
                const SizedBox(height: 16.0),
                if (Responsive.isDesktop(context) ||
                    Responsive.isTablet(context))
                  const SizedBox(height: 30.0),
                if (Responsive.isDesktop(context) ||
                    Responsive.isTablet(context))
                  const Text(
                    'Role Users',
                    style:
                        TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                  ),
                if (Responsive.isDesktop(context)) const SizedBox(height: 25.0),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: "Search by name or email",
                      labelStyle: TextStyle(
                        color: Colors.deepPurpleAccent,
                      ),
                    ),
                    onChanged: (String query) {
                      setState(() {
                        _usersStream = FirebaseFirestore.instance
                            .collection('users')
                            .where('name', isGreaterThanOrEqualTo: query)
                            .where('name',
                                isLessThanOrEqualTo: query + '\uf8ff')
                            .snapshots();
                      });
                    },
                  ),
                ),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _usersStream,
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Text('Loading...');
                      }

                      List<UserData> users = snapshot.data!.docs.map((doc) {
                        return UserData(
                          name: doc['name'],
                          email: doc['email'],
                          role: doc['role'],
                          id: doc.id,
                          isLocked: doc['isLocked'] ?? false,
                        );
                      }).toList();

                      return ListView.builder(
                          itemCount: users.length,
                          itemBuilder: (BuildContext context, int index) {
                            return ListTile(
                              title: Text(users[index].name),
                              subtitle: Text(users[index].email),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  DropdownButton<String>(
                                    value: users[index].role,
                                    onChanged: users[index].isLocked
                                        ? null
                                        : (String? newRole) {
                                            FirebaseFirestore.instance
                                                .collection('users')
                                                .doc(users[index].id)
                                                .update({'role': newRole});
                                          },
                                    items: <String>['admin', 'user']
                                        .map<DropdownMenuItem<String>>(
                                            (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                    disabledHint: Text(users[index].isLocked
                                        ? 'Locked'
                                        : 'Select Role'),
                                  ),
                                  IconButton(
                                    icon: Icon(users[index].isLocked
                                        ? Icons.lock
                                        : Icons.lock_open),
                                    onPressed: () {
                                      if (users[index].isLocked) {
                                        // Unlock tapped, show the dialog
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                              ),
                                              title: const Text.rich(
                                                TextSpan(
                                                  children: [
                                                    TextSpan(
                                                      text:
                                                          'Confirm Password to Unlock',
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              content: TextField(
                                                obscureText: true,
                                                controller: passwordController,
                                                decoration:
                                                    const InputDecoration(
                                                  labelText:
                                                      'Enter your password',
                                                ),
                                              ),
                                              actions: [
                                                TextButton(
                                                  style: ButtonStyle(
                                                    foregroundColor:
                                                        MaterialStateProperty
                                                            .all<Color>(
                                                                Colors.red),
                                                  ),
                                                  child: const Text('Cancel'),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                    passwordController.clear();
                                                  },
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    _unlockUser(
                                                        users[index].id);
                                                  },
                                                  style: ButtonStyle(
                                                    backgroundColor:
                                                        MaterialStateProperty
                                                            .all<Color>(Colors
                                                                .deepPurpleAccent),
                                                    foregroundColor:
                                                        MaterialStateProperty
                                                            .all<Color>(
                                                                Colors.white),
                                                  ),
                                                  child: const Text('Unlock'),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      } else {
                                        // Lock tapped, perform lock action directly
                                        FirebaseFirestore.instance
                                            .collection('users')
                                            .doc(users[index].id)
                                            .update({
                                          'isLocked': !users[index].isLocked,
                                        });
                                      }
                                    },
                                  ),
                                ],
                              ),
                            );
                          });
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class UserData {
  String name;
  String email;
  String role;
  String id;
  bool isLocked;

  UserData({
    required this.name,
    required this.email,
    required this.role,
    required this.id,
    this.isLocked = false,
  });
}

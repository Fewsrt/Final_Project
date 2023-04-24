// ignore_for_file: library_private_types_in_public_api
import 'package:alert/component/custom_drawer.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({Key? key}) : super(key: key);
  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  late Stream<QuerySnapshot> _usersStream;
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _usersStream = FirebaseFirestore.instance.collection('users').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User List'),
      ),
      drawer: const CustomDrawer(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search by name or email',
              ),
              onChanged: (String query) {
                setState(() {
                  _usersStream = FirebaseFirestore.instance
                      .collection('users')
                      .where('name', isGreaterThanOrEqualTo: query)
                      .where('name', isLessThanOrEqualTo: query + '\uf8ff')
                      .snapshots();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _usersStream,
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text('Loading...');
                }

                List<User> users = snapshot.data!.docs.map((doc) {
                  return User(
                    name: doc['name'],
                    email: doc['email'],
                    role: doc['role'],
                    id: doc.id,
                  );
                }).toList();

                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      title: Text(users[index].name),
                      subtitle: Text(users[index].email),
                      trailing: DropdownButton<String>(
                        value: users[index].role,
                        onChanged: (String? newRole) {
                          FirebaseFirestore.instance
                              .collection('users')
                              .doc(users[index].id)
                              .update({'role': newRole});
                        },
                        items: <String>['admin', 'user']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class User {
  String name;
  String email;
  String role;
  String id;

  User(
      {required this.name,
      required this.email,
      required this.role,
      required this.id});
}

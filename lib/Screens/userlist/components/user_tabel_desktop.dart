// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserDesktopScreen extends StatefulWidget {
  const UserDesktopScreen({Key? key}) : super(key: key);

  @override
  _UserDesktopScreenState createState() => _UserDesktopScreenState();
}

class _UserDesktopScreenState extends State<UserDesktopScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  StreamSubscription<QuerySnapshot>? _userSubscription;
  bool sort = true;
  int _sortColumnIndex = 0;

  List<UserData> _allData = [];
  List<UserData> _filteredData = [];

  @override
  void initState() {
    super.initState();
    _userSubscription = _userStream().listen((devicesSnapshot) {
      final devicesDocs = devicesSnapshot.docs;
      setState(() {
        _allData =
            devicesDocs.map((doc) => UserData.fromFirestore(doc)).toList();
        _filteredData = _allData;
      });
    });
  }

  @override
  void dispose() {
    _userSubscription?.cancel();
    super.dispose();
  }

  Stream<QuerySnapshot> _userStream() {
    return firestore
        .collection('users')
        .orderBy('created_at', descending: false)
        .snapshots();
  }

  void _onSortColumn(int columnIndex, bool ascending) {
    setState(() {
      if (_filteredData.isNotEmpty) {
        if (columnIndex == 0) {
          if (ascending) {
            _filteredData.sort((a, b) => a.name.compareTo(b.name));
          } else {
            _filteredData.sort((a, b) => b.name.compareTo(a.name));
          }
        }
      }
    });
  }

  void _onFilterTextChanged(String value) {
    setState(() {
      if (_allData.isNotEmpty) {
        _filteredData = _allData
            .where((user) =>
                user.name.toLowerCase().contains(value.toLowerCase()) ||
                user.surname.toLowerCase().contains(value.toLowerCase()) ||
                user.email.toLowerCase().contains(value.toLowerCase()) ||
                user.role.toLowerCase().contains(value.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenHeight = screenSize.height;
    final rowsPerPage = (screenHeight / 90).floor();

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.all(0),
              constraints: const BoxConstraints(
                maxHeight: 700,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: Theme(
                      data: ThemeData.light().copyWith(
                        cardColor: Colors.white,
                      ),
                      child: PaginatedDataTable(
                        sortColumnIndex:
                            _sortColumnIndex, // use the state variable
                        sortAscending: sort,
                        header: Container(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  decoration: const InputDecoration(
                                    hintText: 'Enter something to filter',
                                  ),
                                  onChanged: _onFilterTextChanged,
                                ),
                              ),
                            ],
                          ),
                        ),
                        source: RowSource(
                          context: context,
                          myData: _filteredData,
                          count: _filteredData.length,
                          updateRoleCallback: updateRole,
                        ),
                        rowsPerPage: rowsPerPage,
                        columnSpacing: 8,
                        columns: [
                          DataColumn(
                            label: const Row(
                              children: [
                                Text(
                                  'Name',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            onSort: (columnIndex, ascending) {
                              setState(() {
                                sort = !sort;
                                _sortColumnIndex =
                                    columnIndex; // update the index of the sorted column
                              });
                              _onSortColumn(columnIndex, ascending);
                            },
                          ),
                          const DataColumn(
                            label: Text(
                              'Surname',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const DataColumn(
                            label: Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                'Email',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                          const DataColumn(
                            label: Row(
                              children: [
                                Text(
                                  'Role',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void updateRole(String userId, String newRole, bool isLocked) {
    final userRef = firestore.collection('users').doc(userId);
    userRef.update({
      'role': newRole,
      'isLocked': isLocked,
    }).then((value) {
      setState(() {
        final user = _allData.firstWhere((user) => user.id == userId);
        user.setRole(newRole);
        user.isLocked = isLocked;
      });
    }).catchError((error) {
      // print('Error updating role: $error');
    });
  }
}

class RowSource extends DataTableSource {
  final BuildContext context;
  final int count;
  final List<UserData> myData;
  final Function(String, String, bool) updateRoleCallback;
  late FirebaseAuth _auth;
  late User user;

  RowSource({
    required this.context,
    required this.myData,
    required this.count,
    required this.updateRoleCallback,
  }) {
    _auth = FirebaseAuth.instance;
    user = _auth.currentUser!;
  }

  void _updateRole(String userId, String newRole, bool isLocked) {
    if (isLocked) {
      updateRoleCallback(userId, newRole, isLocked);
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          final passwordController = TextEditingController();

          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Confirm Password to Unlock',
                  ),
                ],
              ),
            ),
            content: TextField(
              obscureText: true,
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: 'Enter your password',
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: ButtonStyle(
                  foregroundColor: MaterialStateProperty.all<Color>(Colors.red),
                ),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  final password = passwordController.text;
                  final credential = EmailAuthProvider.credential(
                      email: user.email!, password: password);
                  try {
                    await user.reauthenticateWithCredential(credential);
                    Navigator.pop(context);
                    // Password confirmed, proceed with deleting data
                    await updateRoleCallback(userId, newRole, isLocked);
                  } on FirebaseAuthException catch (e) {
                    // Handle incorrect password error
                    if (e.code == 'wrong-password') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text('Incorrect password. Please try again.')),
                      );
                    }
                  }
                },
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.deepPurpleAccent),
                  foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.white),
                ),
                child: const Text('Unlock'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  DataRow? getRow(int index) {
    if (index >= myData.length) return null;
    final user = myData[index];

    return DataRow(
      cells: [
        DataCell(Text(user.name)),
        DataCell(Text(user.surname)),
        DataCell(Text(user.email)),
        DataCell(
          Row(
            children: [
              DropdownButton<String>(
                value: user.role,
                items: const <String>['admin', 'user']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: user.isLocked
                    ? null
                    : (String? newValue) {
                        if (newValue != null) {
                          _updateRole(user.id, newValue, user.isLocked);
                        }
                      },
              ),
              const SizedBox(width: 8.0),
              IconButton(
                icon: user.isLocked
                    ? const Icon(Icons.lock)
                    : const Icon(Icons.lock_open),
                onPressed: () {
                  final bool shouldUnlock = !user.isLocked;
                  _updateRole(user.id, user.role, shouldUnlock);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => myData.length;

  @override
  int get selectedRowCount => 0;
}

class UserData {
  String name;
  String surname;
  String email;
  String role;
  String id;
  bool isLocked;

  UserData({
    required this.name,
    required this.surname,
    required this.email,
    required this.role,
    required this.id,
    this.isLocked = false,
  });

  factory UserData.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserData(
      id: doc.id,
      name: data['name'] ?? '',
      surname: data['surname'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? '',
      isLocked: data['isLocked'] ?? false,
    );
  }

  void setRole(String newRole) {
    role = newRole;
  }
}

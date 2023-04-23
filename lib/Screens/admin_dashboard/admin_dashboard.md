import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'responsive.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AdminDashboardPage(
    deviceId: '',
  ));
}

class AdminDashboardPage extends StatefulWidget {
  final String deviceId;

  const AdminDashboardPage({Key? key, required this.deviceId}) : super(key: key);

  @override
  _AdminDashboardPageState createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  //... Your existing code for variables, initState, and methods

  @override
  Widget build(BuildContext context) {
    return Responsive(
      mobile: _buildMobileLayout(context),
      desktop: _buildDesktopLayout(context),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text(deviceName),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _buildBody(context),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text(deviceName),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _buildBody(context),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Control:',
          style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16.0),
        Row(
          children: [
            Expanded(
              child: SwitchListTile(
                title: const Text('Auto'),
                value: _auto,
                onChanged: _handleSwitchAuto,
              ),
            ),
            Expanded(
              child: SwitchListTile(
                title: const Text('Drain'),
                value: _drain,
                onChanged: _handleSwitchdrain,
              ),
            ),
          ],
        ),
        //... Rest of the code
      ],
    );
  }
}

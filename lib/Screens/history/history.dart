import 'package:alert/component/custom_drawer.dart';
import 'package:flutter/material.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final List<String> _data = ['row 1', 'row 2', 'row 3', 'row 4', 'row 5'];
  String _searchTerm = '';

  void _onSearch(String value) {
    setState(() {
      _searchTerm = value;
    });
  }

  void _onButton1Pressed() {
    // Add your button 1 logic here
  }

  void _onButton2Pressed() {
    // Add your button 2 logic here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
      ),
      drawer: CustomDrawer(),
      body: Column(
        children: [
          TextField(
            onChanged: _onSearch,
            decoration: const InputDecoration(
              hintText: 'Search...',
            ),
          ),
          Expanded(
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Column 1')),
                DataColumn(label: Text('Column 2')),
              ],
              rows: _data
                  .where((row) =>
                      row.toLowerCase().contains(_searchTerm.toLowerCase()))
                  .map((row) => DataRow(cells: [
                        DataCell(Text(row)),
                        DataCell(Text('Data for $row')),
                      ]))
                  .toList(),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: _onButton1Pressed,
                child: const Text('Button 1'),
              ),
              ElevatedButton(
                onPressed: _onButton2Pressed,
                child: const Text('Button 2'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

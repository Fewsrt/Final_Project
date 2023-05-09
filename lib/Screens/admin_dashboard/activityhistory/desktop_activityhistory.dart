// ignore_for_file: avoid_web_libraries_in_flutter, unused_import, avoid_function_literals_in_foreach_calls, unused_local_variable

import 'dart:async';

import 'package:alert/components/custom_drawer.dart';
import 'package:alert/controllers/constants.dart';
import 'package:alert/controllers/responsive.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:csv/csv.dart';
import 'dart:convert';
import 'package:alert/controllers/csv_exporter_io.dart';

class DesktopActivityHistoryPage extends StatefulWidget {
  final String deviceId;
  final String uuid;

  const DesktopActivityHistoryPage(
      {Key? key, required this.deviceId, required this.uuid})
      : super(key: key);

  @override
  State<DesktopActivityHistoryPage> createState() =>
      _DesktopActivityHistoryPageState();
}

class _DesktopActivityHistoryPageState
    extends State<DesktopActivityHistoryPage> {
  bool sort = true;
  int _sortColumnIndex = 0;
  List<Map<String, dynamic>>? filterData;
  List<Map<String, dynamic>>? myData;
  List<Map<String, dynamic>>? devices;
  int selectedDevicesCount = 0;
  StreamSubscription<List<Map<String, dynamic>>>? dataSubscription;

  final TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();

    fetchDataFromFirestore().then((data) {
      final reversedData =
          data.reversed.toList(); // Reverse the order of the data
      setState(() {
        filterData = reversedData;
        myData = reversedData;
      });

      final stream = FirebaseFirestore.instance
          .collection('Activity')
          .orderBy('timestamp')
          .where('uuid', isEqualTo: widget.uuid)
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());

      dataSubscription = stream.listen((data) {
        final reversedData =
            data.reversed.toList(); // Reverse the order of the data
        setState(() {
          filterData = reversedData;
          myData = reversedData;
        });
      });
    });
  }

  @override
  void dispose() {
    dataSubscription?.cancel();
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> fetchDataFromFirestore() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('Datavalue')
        .where('uuid', isEqualTo: widget.uuid)
        .get();

    final dataList = snapshot.docs.map((doc) => doc.data()).toList();
    return dataList;
  }

  void applyDateRange(DateTime? startDate, DateTime? endDate) {
    if (startDate != null && endDate != null) {
      setState(() {
        myData = filterData!
            .where((element) =>
                element['timestamp']
                    .toDate()
                    .isAfter(startDate.subtract(const Duration(days: 1))) &&
                element['timestamp']
                    .toDate()
                    .isBefore(endDate.add(const Duration(days: 1))))
            .toList();
      });
    } else {
      setState(() {
        myData = filterData;
      });
    }
  }

  void _onSortColumn(int columnIndex, bool ascending) {
    setState(() {
      if (myData != null) {
        if (columnIndex == 0) {
          if (ascending) {
            myData!.sort((a, b) => a['timestamp'].compareTo(b['timestamp']));
          } else {
            myData!.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));
          }
        }
      }
    });
  }

  void performQuery() {
    List<String>? selectedUUIDs = devices
        ?.where((device) => device['selected'] as bool? ?? false)
        .map((device) => device['uuid']?.toString() ?? '')
        .toList();

    if (selectedUUIDs!.isEmpty) {
      setState(() {
        myData = filterData;
      });
    } else {
      final newData = filterData!
          .where(
              (element) => selectedUUIDs.contains(element['uuid'].toString()))
          .toList();

      setState(() {
        myData = newData;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenHeight = screenSize.height;
    final rowsPerPage = (screenHeight / 70).floor();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity History'),
        backgroundColor: kPrimaryColor,
      ),
      body: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Theme.of(context).canvasColor,
          borderRadius: const BorderRadius.all(Radius.circular(10)),
        ),
        child: SizedBox(
          width: double.infinity,
          child: Theme(
            data: ThemeData.light().copyWith(
              cardColor: Colors.white,
            ),
            child: PaginatedDataTable(
              sortColumnIndex: _sortColumnIndex, // use the state variable
              sortAscending: sort,
              header: Container(
                padding: const EdgeInsets.all(5),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: controller,
                            decoration: const InputDecoration(
                              hintText: 'Enter something to filter',
                            ),
                            onChanged: (value) {
                              setState(() {
                                myData = filterData!
                                    .where((element) =>
                                        element.toString().contains(value))
                                    .toList();
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        ElevatedButton(
                          onPressed: () async {
                            final pickedDateRange = await showDateRangePicker(
                              context: context,
                              firstDate: DateTime(2000),
                              lastDate: DateTime.now(),
                              builder: (BuildContext context, Widget? child) {
                                return Theme(
                                  data: ThemeData.light().copyWith(
                                    primaryColor:
                                        kPrimaryColor, // Set the color scheme
                                    buttonTheme: const ButtonThemeData(
                                      textTheme: ButtonTextTheme.primary,
                                    ),
                                    colorScheme: const ColorScheme.light(
                                            primary: kPrimaryColor)
                                        .copyWith(secondary: kPrimaryColor),
                                  ),
                                  child: child!,
                                );
                              },
                            );

                            if (pickedDateRange != null) {
                              final startDate = pickedDateRange.start;
                              final endDate = pickedDateRange.end;

                              // Handle selected date range
                              applyDateRange(startDate, endDate);
                            }
                          },
                          child: const Text('Select Date Range'),
                        ),
                        const SizedBox(width: 8.0),
                        if (Responsive.isDesktop(context))
                          ElevatedButton(
                            onPressed: () {
                              exportactivityToCSV(myData ?? []);
                            },
                            child: const Text('Export CSV'),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              source: RowSource(
                myData: myData,
                count: myData?.length ?? 0,
              ),
              rowsPerPage: rowsPerPage,
              columnSpacing: 8,
              columns: [
                DataColumn(
                  label: const Text(
                    'Created At',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
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
                    'User',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
                const DataColumn(
                  label: Text(
                    'UUID',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
                const DataColumn(
                  label: Text(
                    'Button',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
                const DataColumn(
                  label: Text(
                    'Value',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
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

class RowSource extends DataTableSource {
  final List<Map<String, dynamic>>? myData;
  final int count;

  RowSource({
    required this.myData,
    required this.count,
  });

  @override
  DataRow? getRow(int index) {
    if (index < rowCount) {
      return recentFileDataRow(myData![index]);
    } else {
      return null;
    }
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => count;

  @override
  int get selectedRowCount => 0;
}

DataRow recentFileDataRow(Map<String, dynamic> data) {
  final createdAt =
      data['timestamp']?.toDate(); // Assuming 'createdAt' is a DateTime object

  final dateFormatter = DateFormat('yyyy-MM-dd HH:mm:ss');
  final formattedCreatedAt =
      createdAt != null ? dateFormatter.format(createdAt) : '-';

  return DataRow(
    cells: [
      DataCell(Text(formattedCreatedAt)),
      DataCell(Text(data['user']?.toString() ?? '-')),
      DataCell(Text(data['uuid']?.toString() ?? '-')),
      DataCell(Text(data['button']?.toString() ?? '-')),
      DataCell(Text(data['value']?.toString() ?? '-')),
    ],
  );
}

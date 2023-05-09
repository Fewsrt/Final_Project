// ignore_for_file: avoid_web_libraries_in_flutter, unused_import, avoid_function_literals_in_foreach_calls, unused_local_variable

import 'dart:convert';
import 'dart:html' as html;
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';

void exportToCSV(List<Map<String, dynamic>> data) {
  List<List<dynamic>> rows = [];

  // Add header row
  rows.add([
    'Created At',
    'UUID',
    'Direction',
    'Humidity',
    'Rain Gauge',
    'River Sensor',
    'Temperature',
    'Village Sensor',
    'Wind Speed'
  ]);

  // Add data rows
  data.forEach((row) {
    rows.add([
      row['createdAt']?.toDate()?.toString() ?? '-',
      row['uuid']?.toString() ?? '-',
      row['direction']?.toString() ?? '-',
      row['humidity']?.toString() ?? '-',
      row['rainGuage']?.toString() ?? '-',
      row['riverSensor']?.toString() ?? '-',
      row['temperature']?.toString() ?? '-',
      row['villageSensor']?.toString() ?? '-',
      row['windSpeed']?.toString() ?? '-',
    ]);
  });

  // Convert to CSV string
  String csv = const ListToCsvConverter().convert(rows);

  // Format the current date and time for the file name
  DateTime now = DateTime.now();
  DateFormat dateFormat = DateFormat('yyyy-MM-dd_HH-mm-ss');
  String formattedDateTime = dateFormat.format(now);

  // Create and download the CSV file with the new file name
  final content = html.Blob([csv]);
  final anchorElement = html.AnchorElement(
    href: html.Url.createObjectUrl(content),
  )
    ..setAttribute("download", "export_$formattedDateTime.csv")
    ..click();
}

void exportactivityToCSV(List<Map<String, dynamic>> data) {
  List<List<dynamic>> rows = [];

  // Add header row
  rows.add([
    'Timestamp',
    'User',
    'Button',
    'Value',
  ]);

  // Add data rows
  data.forEach((row) {
    rows.add([
      row['timestamp']?.toDate()?.toString() ?? '-',
      row['user']?.toString() ?? '-',
      row['button']?.toString() ?? '-',
      row['value']?.toString() ?? '-',
    ]);
  });

  // Convert to CSV string
  String csv = const ListToCsvConverter().convert(rows);

  // Format the current date and time for the file name
  DateTime now = DateTime.now();
  DateFormat dateFormat = DateFormat('yyyy-MM-dd_HH-mm-ss');
  String formattedDateTime = dateFormat.format(now);

  // Create and download the CSV file with the new file name
  final content = html.Blob([csv]);
  final anchorElement = html.AnchorElement(
    href: html.Url.createObjectUrl(content),
  )
    ..setAttribute("download", "Activityexport_$formattedDateTime.csv")
    ..click();
}

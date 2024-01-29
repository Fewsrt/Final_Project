// ignore_for_file: library_private_types_in_public_api, avoid_function_literals_in_foreach_calls

import 'dart:async';
import 'package:alert/Screens/admin_dashboard/admin_dashboard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_database/firebase_database.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  final Set<Marker> _markers = {};
  DatabaseReference ref = FirebaseDatabase.instance.ref('/');
  StreamSubscription<DatabaseEvent>? _statusSubscription;
  // ignore: unused_field
  final String _status = '';
  Map<String, dynamic> statusData = {};
  // ignore: unused_field
  bool _isDisposed = false;

  LatLng? _center;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _getDeviceLocations();
  }

  void _onMarkerTapped(String deviceId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AdminDashboardPage(deviceId: deviceId),
      ),
    );
  }

  @override
  void dispose() {
    _statusSubscription?.cancel();
    _isDisposed = true;
    super.dispose();
  }

  void _getCurrentLocation() async {
    bool isLocationEnabled = await Geolocator.isLocationServiceEnabled();
    LocationPermission permission = await Geolocator.checkPermission();

    if (!isLocationEnabled || permission == LocationPermission.denied) {
    } else {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _center = LatLng(position.latitude, position.longitude);
        // debugPrint("Current location: $_center");
      });
    }
  }

  void _getDeviceLocations() {
    FirebaseFirestore.instance
        .collection('Devices')
        .snapshots()
        .listen((QuerySnapshot querySnapshot) {
      querySnapshot.docChanges.forEach((docChange) {
        String deviceId = docChange.doc.id;
        String uuid = docChange.doc.get('uuid');
        double lat = docChange.doc['lat'];
        double long = docChange.doc['long'];
        ref.child(uuid).child('Status').onValue.listen((event) {
          dynamic statusValue = event.snapshot.value;
          if (statusValue != null && statusValue is String) {
            String status = statusValue;
            bool isOffline = status == 'Offline';

            BitmapDescriptor markerIcon = isOffline
                ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed)
                : BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueGreen);

            Marker marker = Marker(
              markerId: MarkerId(deviceId),
              position: LatLng(lat, long),
              icon: markerIcon,
              infoWindow: InfoWindow(
                title: docChange.doc['device_name'],
                snippet: isOffline ? 'Offline' : 'Tap to View more',
                onTap: isOffline ? null : () => _onMarkerTapped(deviceId),
              ),
            );

            setState(() {
              if (docChange.type == DocumentChangeType.added) {
                _markers.add(marker);
              } else if (docChange.type == DocumentChangeType.modified) {
                _markers.removeWhere((existingMarker) =>
                    existingMarker.markerId == MarkerId(deviceId));
                _markers.add(marker);
              } else if (docChange.type == DocumentChangeType.removed) {
                _markers.removeWhere((existingMarker) =>
                    existingMarker.markerId == MarkerId(deviceId));
              }
            });
          }
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        key: ValueKey(_center),
        mapType: MapType.normal,
        initialCameraPosition: _center == null
            ? const CameraPosition(
                target: LatLng(0, 0),
                zoom: 11.0,
              )
            : CameraPosition(
                target: _center!,
                zoom: 14.0,
              ),
        onMapCreated: (GoogleMapController controller) {
          if (!_controller.isCompleted) {
            _controller.complete(controller);
          }
        },
        markers: _markers,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
    );
  }
}

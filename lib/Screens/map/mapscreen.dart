import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:alert/component/custom_drawer.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  final Set<Marker> _markers = {};

  LatLng? _center;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _getDeviceLocations();
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

  void _getDeviceLocations() async {
    // Get the collection of devices from Firestore
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('Devices').get();

    // debugPrint("QuerySnapshot size: ${querySnapshot.size}");

    // Create a marker for each document in the collection
    querySnapshot.docs.forEach((doc) {
      double lat = doc['lat'];
      double long = doc['long'];
      Marker marker = Marker(
        markerId: MarkerId(doc.id),
        position: LatLng(lat, long),
        infoWindow: InfoWindow(title: doc['device_name']),
      );
      _markers.add(marker);
    });

    // debugPrint("Markers size: ${_markers.length}");

    setState(() {}); // Update the UI to show the markers on the map
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Map"),
      ),
      drawer: const CustomDrawer(),
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

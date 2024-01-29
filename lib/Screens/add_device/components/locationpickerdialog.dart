// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class LocationPickerPage extends StatefulWidget {
  final void Function(double, double) onLocationPicked;

  const LocationPickerPage({super.key, required this.onLocationPicked});

  @override
  _LocationPickerPageState createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<LocationPickerPage> {
  LatLng? _pickedLocation;
  LatLng? _center;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Location',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Tap on the map to pick a location. You can zoom in and out using the pinch gesture.',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: GoogleMap(
              key: ValueKey(_center),
              initialCameraPosition: _center == null
                  ? const CameraPosition(
                      target: LatLng(0, 0),
                      zoom: 11.0,
                    )
                  : CameraPosition(
                      target: _center!,
                      zoom: 14.0,
                    ),
              onMapCreated: (controller) {
                setState(() {});
              },
              onCameraMove: (position) {
                setState(() {
                  _pickedLocation = position.target;
                });
              },
              markers: _pickedLocation == null
                  ? {}
                  : {
                      Marker(
                        markerId: const MarkerId('pickedLocation'),
                        position: _pickedLocation!,
                      ),
                    },
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Latitude: ${_pickedLocation?.latitude ?? '-'}',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'Longitude: ${_pickedLocation?.longitude ?? '-'}',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              if (_pickedLocation != null) {
                widget.onLocationPicked(
                  _pickedLocation!.latitude,
                  _pickedLocation!.longitude,
                );
              }
              Navigator.pop(context);
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}

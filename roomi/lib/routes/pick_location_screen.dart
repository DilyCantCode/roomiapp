import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

class PickLocationScreen extends StatefulWidget {
  const PickLocationScreen({super.key});

  @override
  State<PickLocationScreen> createState() => _PickLocationScreenState();
}

class _PickLocationScreenState extends State<PickLocationScreen> {
  LatLng? selectedLatLng;
  String? selectedAddress;
  GoogleMapController? mapController;

  void _onMapTapped(LatLng latLng) async {
    setState(() {
      selectedLatLng = latLng;
      selectedAddress = 'Fetching address...';
    });

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latLng.latitude, latLng.longitude);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        setState(() {
          selectedAddress = '${p.street}, ${p.locality}, ${p.administrativeArea}, ${p.country}';
        });
      } else {
        setState(() {
          selectedAddress = 'No address found.';
        });
      }
    } catch (e) {
      setState(() {
        selectedAddress = 'Failed to get address.';
      });
    }
  }

  void _confirmLocation() {
    if (selectedAddress != null) {
      Navigator.pop(context, selectedAddress);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pick a Location')),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: LatLng(37.7749, -122.4194), // San Francisco default
                zoom: 12,
              ),
              onTap: _onMapTapped,
              markers: selectedLatLng != null
                  ? {
                      Marker(markerId: const MarkerId('selected'), position: selectedLatLng!)
                    }
                  : {},
              onMapCreated: (controller) {
                mapController = controller;
              },
            ),
          ),
          if (selectedAddress != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Selected Address: $selectedAddress'),
            ),
          ElevatedButton(
            onPressed: _confirmLocation,
            child: const Text('Confirm Location'),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

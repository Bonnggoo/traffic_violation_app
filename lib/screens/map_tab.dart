import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart'; // The free map widget
import 'package:latlong2/latlong.dart'; // Coordinate helper
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MapTab extends StatefulWidget {
  const MapTab({super.key});

  @override
  State<MapTab> createState() => _MapTabState();
}

class _MapTabState extends State<MapTab> {
  // Amman, Jordan Coordinates
  final LatLng _ammanCenter = const LatLng(31.9539, 35.9106);
  List<Marker> _markers = [];

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    String myPlate = "Unknown";
    if (user != null && user.email != null) {
      myPlate = user.email!.split('@')[0].toUpperCase();
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('violations')
          .where('licensePlate', isEqualTo: myPlate)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          _markers = _createMarkers(snapshot.data!.docs);
        }

        return Scaffold(
          body: FlutterMap(
            options: MapOptions(
              initialCenter: _ammanCenter, // Center map on Amman
              initialZoom: 13.0,
            ),
            children: [
              // 1. The Map Tiles (The visual map)
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.trafficguard.app',
              ),
              
              // 2. The Pins (Violations)
              MarkerLayer(markers: _markers),
            ],
          ),
        );
      },
    );
  }

  // --- HELPER: Convert Firebase Docs to OSM Markers ---
  List<Marker> _createMarkers(List<QueryDocumentSnapshot> docs) {
    return docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final location = data['location'];
      
      // Default to Amman if location is missing
      double lat = location != null ? location['lat'] : 31.9539;
      double lng = location != null ? location['lng'] : 35.9106;

      return Marker(
        point: LatLng(lat, lng),
        width: 80,
        height: 80,
        child: GestureDetector(
          onTap: () {
            // Show a simple popup when clicked
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: Text(data['violationType'] ?? "Violation"),
                content: Text("Fine: ${data['fineAmount']} JOD\nTime: ${data['timestamp']?.toDate().toString().substring(0,16) ?? 'N/A'}"),
                actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("OK"))],
              ),
            );
          },
          child: const Icon(
            Icons.location_on, 
            color: Colors.red, 
            size: 40,
            shadows: [Shadow(blurRadius: 10, color: Colors.black)],
          ),
        ),
      );
    }).toList();
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart'; // Free Map Widget
import 'package:latlong2/latlong.dart'; // Coordinate Helper
import 'package:cloud_firestore/cloud_firestore.dart';

class ViolationDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> data;

  const ViolationDetailsScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    // --- 1. SAFE DATA PARSING ---
    // Handle coordinates safely (converts int to double if needed)
    final location = data['location'];
    final double lat = location != null ? (location['lat'] as num).toDouble() : 31.9539;
    final double lng = location != null ? (location['lng'] as num).toDouble() : 35.9106;
    final LatLng point = LatLng(lat, lng);

    // Handle date formatting
    String dateStr = "Unknown Date";
    if (data['timestamp'] != null) {
      if (data['timestamp'] is Timestamp) {
        dateStr = (data['timestamp'] as Timestamp).toDate().toString().substring(0, 16);
      } else {
        dateStr = data['timestamp'].toString();
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Light background
      appBar: AppBar(
        title: const Text("Violation Details"),
        backgroundColor: const Color(0xFF556B2F), // Traffic Guard Green
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // --- A. INFO CARD ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
                ],
              ),
              child: Column(
                children: [
                  _row("Violation Type", data['violationType'] ?? "Unknown", isBold: true),
                  const Divider(height: 30),
                  _row("Fine Amount", "${data['fineAmount']} JOD", color: Colors.red),
                  const Divider(height: 30),
                  _row("Date & Time", dateStr),
                  const Divider(height: 30),
                  _row("Vehicle Speed", "${data['speed']} km/h"),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // --- B. MEDIA ROW (Map + Photo) ---
            SizedBox(
              height: 180, 
              child: Row(
                children: [
                  // 1. Mini Map (Clickable)
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        // Navigate to Full Screen Map
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FullScreenMap(point: point),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Stack(
                            children: [
                              // The Map
                              FlutterMap(
                                options: MapOptions(
                                  initialCenter: point,
                                  initialZoom: 14.0,
                                  interactionOptions: const InteractionOptions(
                                    flags: InteractiveFlag.none, // Locked (Mini-mode)
                                  ),
                                ),
                                children: [
                                  TileLayer(
                                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  ),
                                  MarkerLayer(
                                    markers: [
                                      Marker(
                                        point: point,
                                        width: 40,
                                        height: 40,
                                        child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              // "Expand" Icon overlay
                              Positioned(
                                right: 5,
                                bottom: 5,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.8),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.fullscreen, size: 20, color: Colors.black54),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 15),

                  // 2. Car Photo
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                         // Optional: Add full-screen photo logic here later
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          image: DecorationImage(
                            image: NetworkImage(data['imageUrl'] ?? "https://via.placeholder.com/150"),
                            fit: BoxFit.cover,
                          ),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // --- C. ACTION BUTTONS ---
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Dispute request sent to review.")),
                  );
                },
                icon: const Icon(Icons.gavel),
                label: const Text("Dispute This Violation"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF556B2F),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Redirecting to e-Fawateer... (Simulated)")),
                  );
                },
                icon: const Icon(Icons.credit_card),
                label: const Text("Pay Fine Now"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF556B2F),
                  side: const BorderSide(color: Color(0xFF556B2F)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper for rows
  Widget _row(String label, String value, {bool isBold = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 16)),
        Text(
          value, 
          style: TextStyle(
            fontSize: 16, 
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: color ?? Colors.black
          )
        ),
      ],
    );
  }
}

// --- NEW SCREEN: FULL SCREEN MAP ---
class FullScreenMap extends StatelessWidget {
  final LatLng point;
  const FullScreenMap({super.key, required this.point});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Violation Location"),
        backgroundColor: const Color(0xFF556B2F),
        foregroundColor: Colors.white,
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: point,
          initialZoom: 16.0, // Zoomed in closer
          interactionOptions: const InteractionOptions(
            flags: InteractiveFlag.all, // Allow Zoom & Pan!
          ),
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.trafficguard.app',
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: point,
                width: 60,
                height: 60,
                child: const Icon(Icons.location_on, color: Colors.red, size: 60),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
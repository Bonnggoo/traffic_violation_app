import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // For Timestamp handling

class ViolationDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> data;

  const ViolationDetailsScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    // 1. Safe Date Formatting
    String dateString = "Unknown Date";
    if (data['timestamp'] != null) {
      try {
        dateString = (data['timestamp'] as Timestamp).toDate().toString().substring(0, 16);
      } catch (e) {
        dateString = "Invalid Date";
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Violation Details")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // A. INFO CARD
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Card(
                elevation: 0,
                color: const Color(0xFFFFFFF0),
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: Color(0xFF556B2F)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    children: [
                      _row("Violation Type", data['violationType'] ?? 'Unknown', true),
                      const Divider(),
                      _row("Fine Amount", "${data['fineAmount'] ?? 0} JOD", true, Colors.red),
                      const Divider(),
                      _row("Date & Time", dateString, false),
                      const Divider(),
                      _row("Vehicle Speed", "${data['speed'] ?? 0} km/h", false),
                    ],
                  ),
                ),
              ),
            ),

            // B. MAP AND IMAGE (Fixed Size Layout)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: SizedBox(
                height: 180, // LOCK THE HEIGHT
                child: Row(
                  children: [
                    // --- Map Placeholder (Left) ---
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.location_on, color: Colors.red, size: 40),
                            const SizedBox(height: 5),
                            Text(
                              "Lat: ${data['location']?['lat'] ?? '?'}\nLng: ${data['location']?['lng'] ?? '?'}",
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 10, color: Colors.black54),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 10), // Spacing

                    // --- Image Evidence (Right) ---
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black12,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey),
                        ),
                        clipBehavior: Clip.antiAlias, 
                        child: Image.network(
                          data['imageUrl'] ?? "https://via.placeholder.com/150", // Fallback image
                          
                          // FORCE IMAGE TO FILL THE BOX
                          fit: BoxFit.cover, 
                          width: double.infinity, 
                          height: double.infinity,
                          
                          // Loading Builder
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(child: CircularProgressIndicator());
                          },
                          
                          // Error Builder
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.broken_image, size: 40, color: Colors.grey),
                                  Text("No Image", style: TextStyle(fontSize: 12, color: Colors.grey)),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // C. ACTION BUTTONS
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Dispute request sent to Traffic Department.")),
                      );
                    },
                    icon: const Icon(Icons.gavel),
                    label: const Text("Dispute This Violation"),
                    style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: () {
                       // In the future, this could open a payment gateway
                       ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Payment gateway not connected.")),
                      );
                    },
                    icon: const Icon(Icons.payment),
                    label: const Text("Pay Fine Now"),
                    style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget to build rows cleanly
  Widget _row(String label, String value, bool isBold, [Color? color]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                color: color ?? Colors.black,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
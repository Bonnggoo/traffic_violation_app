// --- 8. DETAILS SCREEN ---
import 'package:flutter/material.dart';

class ViolationDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> data;
  const ViolationDetailsScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Violation Details")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Card(
                elevation: 0, color: const Color(0xFFFFFFF0),
                shape: RoundedRectangleBorder(side: const BorderSide(color: Color(0xFF556B2F)), borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(children: [
                    _row(context, "Violation Type", data['violationType'] ?? 'Unknown', true), const Divider(),
                    _row(context, "Fine Amount", "${data['fineAmount']} JOD", true, Colors.red), const Divider(),
                    _row(context, "Location", "Amman, Jordan", false),
                  ]),
                ),
              ),
            ),
            // B. MAP AND IMAGE (Fixed Size Layout)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: SizedBox(
                height: 180, // 1. LOCK THE HEIGHT HERE
                child: Row(
                  children: [
                    // --- Map Box (Left) ---
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.location_on, color: Colors.red, size: 40),
                            Text("Map Location", style: TextStyle(color: Colors.black54)),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 10), // Spacing

                    // --- Image Box (Right) ---
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black12,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey),
                        ),
                        clipBehavior: Clip.antiAlias, // Crops the image to the rounded corners
                        child: Image.network(
                          data['imageUrl'] ?? "https://cdn.pixabay.com/photo/2012/11/02/13/02/car-63930_1280.jpg",
                          
                          // 2. FORCE IMAGE TO FILL THE BOX
                          fit: BoxFit.cover, 
                          width: double.infinity, 
                          height: double.infinity,
                          
                          // Loading Builder (Keeps box size while loading)
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(child: CircularProgressIndicator());
                          },
                          
                          // Error Builder (Keeps box size if link is broken)
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
          ],
        ),
      ),
    );
  }
  Widget _row(BuildContext c, String l, String v, bool b, [Color? col]) => Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(l, style: const TextStyle(color: Colors.grey)), Flexible(child: Text(v, style: TextStyle(fontWeight: b ? FontWeight.bold : FontWeight.normal, color: col ?? Colors.black)))]));
}
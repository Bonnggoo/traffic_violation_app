import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:traffic_violation_app/screens/details_screen.dart';

// --- 6. VIOLATIONS TAB (ONLINE & REAL-TIME) ---
class ViolationsTab extends StatelessWidget {
  const ViolationsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Violations")),
      // STREAMBUILDER: LISTENS TO FIREBASE
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('violations').orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          // 1. Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // 2. Error
          if (snapshot.hasError) {
             return Center(child: Text("Error: ${snapshot.error}"));
          }
          // 3. Empty
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.check_circle, size: 60, color: Colors.green), SizedBox(height: 10), Text("No violations found in database!")]));
          }

          final docs = snapshot.data!.docs;
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final item = docs[index].data();
              // Format Timestamp safely
              String dateString = "Unknown Date";
              if (item['timestamp'] != null) {
                // If it's a real Firebase timestamp, convert it
                try {
                  dateString = (item['timestamp'] as Timestamp).toDate().toString().substring(0, 16);
                } catch (e) {
                   dateString = "Invalid Date";
                }
              }

              return Card(
                color: const Color(0xFFFFFFF0),
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  leading: Icon(
                    (item['violationType'] ?? "").toString().contains('Speeding') ? Icons.speed : Icons.warning_amber_rounded,
                    color: const Color(0xFF556B2F),
                    size: 30
                  ),
                  title: Text(item['violationType'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(dateString),
                  trailing: Text("${item['fineAmount'] ?? 0} JOD", style: const TextStyle(color: Color(0xFF556B2F), fontWeight: FontWeight.bold)),
                  onTap: () {
                    // Navigate to details screen with REAL data
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ViolationDetailsScreen(data: item)));
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

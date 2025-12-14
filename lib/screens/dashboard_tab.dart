import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'details_screen.dart'; // To open the violation when clicked

class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Identify the Driver
    final user = FirebaseAuth.instance.currentUser;
    String myPlateNumber = "Unknown";
    if (user != null && user.email != null) {
      myPlateNumber = user.email!.split('@')[0].toUpperCase();
    }

    return StreamBuilder<QuerySnapshot>(
      // 2. Listen to the Database (Same filter as Violations Tab)
      stream: FirebaseFirestore.instance
          .collection('violations')
          .where('licensePlate', isEqualTo: myPlateNumber)
          .orderBy('timestamp', descending: true)
          .snapshots(),
          
      builder: (context, snapshot) {
        // --- CALCULATIONS ---
        int totalFines = 0;
        int violationCount = 0;
        int safetyScore = 100;
        List<QueryDocumentSnapshot> recentDocs = [];

        if (snapshot.hasData) {
          final docs = snapshot.data!.docs;
          violationCount = docs.length;
          
          // Sum up the fines
          for (var doc in docs) {
            totalFines += (doc['fineAmount'] as num).toInt();
          }

          // Calculate Safety Score (100 - 10 per violation)
          safetyScore = (100 - (violationCount * 10)).clamp(0, 100);

          // Get just the newest 2 violations for the "Recent" section
          if (docs.length > 2) {
            recentDocs = docs.sublist(0, 2);
          } else {
            recentDocs = docs;
          }
        }
        // --------------------

        return Scaffold(
          appBar: AppBar(
            title: const Text("Traffic Guard"),
            centerTitle: false,
            actions: [
              IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none))
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // A. WELCOME HEADER
                Text(
                  "Hello, Driver ($myPlateNumber)",
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const Text(
                  "Dashboard Overview",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                // B. SUMMARY CARDS (Dynamic Data)
                Row(
                  children: [
                    _summaryCard(
                      "Total Fines", 
                      "$totalFines JOD", 
                      Icons.money_off, 
                      Colors.red
                    ),
                    const SizedBox(width: 15),
                    _summaryCard(
                      "Safety Score", 
                      "$safetyScore%", 
                      Icons.shield, 
                      safetyScore > 80 ? Colors.green : Colors.orange
                    ),
                  ],
                ),
                
                const SizedBox(height: 30),

                // C. RECENT ACTIVITY HEADER
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Recent Activity", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Icon(Icons.history, color: Colors.grey),
                  ],
                ),
                const SizedBox(height: 10),

                // D. DYNAMIC RECENT LIST
                if (violationCount == 0)
                  _emptyState()
                else
                  ...recentDocs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return _recentViolationCard(context, data);
                  }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- WIDGET HELPER: Summary Card ---
  Widget _summaryCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 10),
            Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
            Text(title, style: const TextStyle(fontSize: 14, color: Colors.black54)),
          ],
        ),
      ),
    );
  }

  // --- WIDGET HELPER: Recent Violation Item ---
  Widget _recentViolationCard(BuildContext context, Map<String, dynamic> data) {
    // Format Date
    String dateStr = "Recent";
    if (data['timestamp'] != null) {
       dateStr = (data['timestamp'] as Timestamp).toDate().toString().substring(5, 16);
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.red[50], shape: BoxShape.circle),
          child: const Icon(Icons.warning, color: Colors.red),
        ),
        title: Text(data['violationType'] ?? "Violation", style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(dateStr),
        trailing: Text(
          "-${data['fineAmount']} JOD", 
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ViolationDetailsScreen(data: data)),
          );
        },
      ),
    );
  }

  // --- WIDGET HELPER: Empty State ---
  Widget _emptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: const Column(
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 40),
          SizedBox(height: 10),
          Text("No recent violations!", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
          Text("You are driving safely.", style: TextStyle(color: Colors.green)),
        ],
      ),
    );
  }
}
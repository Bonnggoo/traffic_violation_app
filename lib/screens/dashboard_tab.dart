import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'details_screen.dart';

class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  String? _selectedPlate;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Center(child: Text("Error: No User"));

    // 1. Listen to USER PROFILE to get list of cars
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
      builder: (context, userSnap) {
        
        List<dynamic> rawPlates = [];
        String primaryPlate = "UNKNOWN";

        if (userSnap.hasData && userSnap.data!.exists) {
           final data = userSnap.data!.data() as Map<String, dynamic>;
           rawPlates = data['registeredPlates'] ?? [];
           primaryPlate = data['primaryPlate'] ?? (user.email!.split('@')[0].toUpperCase());
        }

        // Fallback
        if (rawPlates.isEmpty) {
          rawPlates = [user.email!.split('@')[0].toUpperCase()];
        }

        // Sort: Primary First
        List<String> myPlates = List<String>.from(rawPlates.map((e) => e.toString()));
        if (myPlates.contains(primaryPlate)) {
          myPlates.remove(primaryPlate);
          myPlates.insert(0, primaryPlate);
        }

        // Default selection logic
        if (_selectedPlate == null || !myPlates.contains(_selectedPlate)) {
          _selectedPlate = myPlates.first;
        }

        // 2. Listen to VIOLATIONS for the SELECTED Plate
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('violations')
              .where('licensePlate', isEqualTo: _selectedPlate)
              .orderBy('timestamp', descending: true)
              .snapshots(),
              
          builder: (context, violationSnap) {
            
            // --- 🧠 SMART SCORING 2.0 (MATCHING PROFILE TAB) ---
            int totalFines = 0;
            double totalDeductions = 0;
            int safetyScore = 100;
            List<QueryDocumentSnapshot> recentDocs = [];

            if (violationSnap.hasData) {
              final docs = violationSnap.data!.docs;
              
              // A. Recent Activity List (Top 2)
              if (docs.length > 2) recentDocs = docs.sublist(0, 2);
              else recentDocs = docs;

              // B. Calculate Score
              for (var doc in docs) {
                final data = doc.data() as Map<String, dynamic>;
                
                // Sum Fines
                totalFines += (data['fineAmount'] as num? ?? 0).toInt();

                // Get Data Points
                String type = (data['violationType'] ?? "").toString();
                int speed = (data['speed'] as num? ?? 0).toInt();
                
                // Safe Date Parsing for Time Decay
                DateTime violationDate = DateTime.now();
                if (data['timestamp'] != null) {
                  try {
                    violationDate = (data['timestamp'] as Timestamp).toDate();
                  } catch (e) { /* ignore */ }
                }
                int daysAgo = DateTime.now().difference(violationDate).inDays;

                // Base Penalty Logic
                double penalty = 0;

                if (type.contains("Wrong") || type.contains("Way")) {
                  penalty = 20; 
                } else if (type.contains("Speeding")) {
                   // Tiered Speeding Logic
                   if (speed > 130) {
                     penalty = 25; // Severe
                   } else if (speed > 100) {
                     penalty = 10; // Moderate
                   } else {
                     penalty = 5;  // Minor
                   }
                } else {
                  penalty = 5; // Unknown/Other
                }

                // Time Decay (50% off if > 30 days)
                if (daysAgo > 30) {
                  penalty = penalty * 0.5;
                }

                totalDeductions += penalty;
              }
              // Final Calculation
              safetyScore = (100 - totalDeductions.toInt()).clamp(0, 100);
            }
            
            // Determine Color based on new thresholds
            Color scoreColor = Colors.red;
            if (safetyScore >= 90) scoreColor = Colors.green;
            else if (safetyScore >= 70) scoreColor = Colors.lightGreen;
            else if (safetyScore >= 50) scoreColor = Colors.orange;

            return Scaffold(
              appBar: AppBar(
                title: const Text("Traffic Guard"),
                actions: [
                  IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none))
                ],
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // A. VEHICLE SELECTOR (Dropdown)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.green.withOpacity(0.5))
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedPlate,
                          isExpanded: true,
                          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF556B2F)),
                          items: myPlates.map<DropdownMenuItem<String>>((value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Row(
                                children: [
                                  const Icon(Icons.directions_car, size: 20, color: Colors.grey),
                                  const SizedBox(width: 10),
                                  Text(
                                    value,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                  ),
                                  // Show star next to primary in dropdown
                                  if (value == primaryPlate) ...[
                                    const SizedBox(width: 5),
                                    const Icon(Icons.star, size: 16, color: Colors.amber)
                                  ]
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedPlate = newValue!;
                            });
                          },
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),

                    // B. DASHBOARD TITLE
                    const Text(
                      "Dashboard Overview",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),

                    // C. STAT CARDS
                    Row(
                      children: [
                        _summaryCard("Total Fines", "$totalFines JOD", Icons.money_off, Colors.red),
                        const SizedBox(width: 15),
                        _summaryCard("Safety Score", "$safetyScore%", Icons.shield, scoreColor),
                      ],
                    ),
                    
                    const SizedBox(height: 30),

                    // D. RECENT ACTIVITY
                    const Text("Recent Activity", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),

                    if (recentDocs.isEmpty)
                      _emptyState()
                    else
                      ...recentDocs.map((doc) => _recentViolationCard(context, doc.data() as Map<String, dynamic>)).toList(),
                  ],
                ),
              ),
            );
          },
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
    String dateStr = "Recent";
    if (data['timestamp'] != null) {
       try {
         dateStr = (data['timestamp'] as Timestamp).toDate().toString().substring(5, 16);
       } catch (e) {
         dateStr = "Recent";
       }
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
        trailing: Text("-${data['fineAmount']} JOD", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => ViolationDetailsScreen(data: data)));
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
        ],
      ),
    );
  }
}
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

    // 1. Listen to USER PROFILE
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

        if (rawPlates.isEmpty) {
          rawPlates = [user.email!.split('@')[0].toUpperCase()];
        }

        List<String> myPlates = List<String>.from(rawPlates.map((e) => e.toString()));
        if (myPlates.contains(primaryPlate)) {
          myPlates.remove(primaryPlate);
          myPlates.insert(0, primaryPlate);
        }

        if (_selectedPlate == null || !myPlates.contains(_selectedPlate)) {
          _selectedPlate = myPlates.first;
        }

        // 2. Listen to VIOLATIONS
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('violations')
              .where('licensePlate', isEqualTo: _selectedPlate)
              // Note: We fetch ALL to calculate the accurate score history
              .snapshots(),
              
          builder: (context, violationSnap) {
            
            // --- 🧠 SMART SCORE ALGORITHM 3.0 (Matches Profile Logic) ---
            int totalFines = 0;
            double totalDeductions = 0;
            int safetyScore = 100;
            List<QueryDocumentSnapshot> recentDocs = [];
            int wrongWayCount = 0;
            DateTime? lastViolationDate;

            if (violationSnap.hasData) {
              final docs = violationSnap.data!.docs;
              
              // 1. Sort by Date Ascending (Oldest First) for Calculation
              List<QueryDocumentSnapshot> sortedDocs = List.from(docs);
              sortedDocs.sort((a, b) {
                 Timestamp t1 = a['timestamp'] ?? Timestamp.now();
                 Timestamp t2 = b['timestamp'] ?? Timestamp.now();
                 return t1.compareTo(t2); 
              });

              // 2. Calculate Score (Progressive)
              for (var doc in sortedDocs) {
                final data = doc.data() as Map<String, dynamic>;
                
                // Track latest violation date
                DateTime vDate = DateTime.now();
                if (data['timestamp'] != null) {
                  vDate = (data['timestamp'] as Timestamp).toDate();
                }
                if (lastViolationDate == null || vDate.isAfter(lastViolationDate!)) {
                  lastViolationDate = vDate;
                }

                totalFines += (data['fineAmount'] as num? ?? 0).toInt();

                String type = (data['violationType'] ?? "").toString();
                int speed = (data['speed'] as num? ?? 0).toInt();
                double penalty = 0;

                // Wrong Way: Progressive
                if (type.contains("Wrong") || type.contains("Way")) {
                  wrongWayCount++;
                  if (wrongWayCount == 1) penalty = 5;
                  else if (wrongWayCount == 2) penalty = 15;
                  else penalty = 30;
                } 
                // Speeding: Tiered (100km/h limit assumed)
                else if (type.contains("Speeding")) {
                   int overLimit = speed - 100;
                   if (overLimit > 30) penalty = 30;
                   else if (overLimit > 15) penalty = 15;
                   else penalty = 5;
                } else {
                  penalty = 5; 
                }

                totalDeductions += penalty;
              }

              // 3. Base Score Calculation
              int rawScore = (100 - totalDeductions.toInt());

              // 4. RECOVERY LOGIC (+2 pts per clean week)
              int recoveryBonus = 0;
              if (lastViolationDate != null) {
                int daysSinceLast = DateTime.now().difference(lastViolationDate!).inDays;
                int cleanWeeks = (daysSinceLast / 7).floor(); 
                recoveryBonus = cleanWeeks * 2;
              } else {
                recoveryBonus = 0; 
              }

              // Final Score
              safetyScore = (rawScore + recoveryBonus).clamp(0, 100);

              // 5. Prepare Recent Docs (Reverse Order so Newest is Top)
              recentDocs = List.from(sortedDocs.reversed);
              if (recentDocs.length > 2) recentDocs = recentDocs.sublist(0, 2);
            }
            
            // Color Logic 
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
                    // A. VEHICLE SELECTOR
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
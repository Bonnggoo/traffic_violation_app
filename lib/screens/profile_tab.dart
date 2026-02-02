import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart'; 

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  bool _notifications = true;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Center(child: Text("Not Logged In"));

    // 1. IDENTITY LOGIC: The Login Email IS the Primary Plate
    String ownerPlate = user.email!.split('@')[0].toUpperCase();

    // 2. Fetch User Data (List of Plates)
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
      builder: (context, userSnap) {
        
        List<dynamic> rawPlates = [];
        
        if (userSnap.hasData && userSnap.data!.exists) {
          final data = userSnap.data!.data() as Map<String, dynamic>;
          rawPlates = data['registeredPlates'] ?? [ownerPlate];
        } else {
          rawPlates = [ownerPlate];
        }
        
        // Safety: Ensure the Owner Plate is ALWAYS in the list
        if (!rawPlates.contains(ownerPlate)) rawPlates.add(ownerPlate);

        // Sort: Owner Plate ALWAYS First
        List<String> myPlates = List<String>.from(rawPlates.map((e) => e.toString()));
        myPlates.sort((a, b) {
          if (a == ownerPlate) return -1;
          if (b == ownerPlate) return 1; 
          return a.compareTo(b);          
        });

        // 3. Fetch Violations ONLY for the OWNER PLATE
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('violations')
              .where('licensePlate', isEqualTo: ownerPlate) 
              .snapshots(),
          builder: (context, violationSnap) {
            
            // --- 🧠 SMART SCORE ALGORITHM 3.0 (Fully Matches Slides) ---
            int totalFines = 0;
            double totalDeductions = 0;
            int wrongWayCount = 0;
            DateTime? lastViolationDate; // To track "violation-free" time

            if (violationSnap.hasData) {
              final docs = violationSnap.data!.docs;
              
              // 1. Sort by Date (Oldest to Newest) to count progressive penalties correctly
              List<QueryDocumentSnapshot> sortedDocs = List.from(docs);
              sortedDocs.sort((a, b) {
                 Timestamp t1 = a['timestamp'] ?? Timestamp.now();
                 Timestamp t2 = b['timestamp'] ?? Timestamp.now();
                 return t1.compareTo(t2); 
              });

              // 2. Calculate Penalties
              for (var doc in sortedDocs) {
                final data = doc.data() as Map<String, dynamic>;
                
                // Update latest violation date
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

                // WRONG WAY (Progressive) -> Matches Slide
                if (type.contains("Wrong") || type.contains("Way")) {
                  wrongWayCount++;
                  if (wrongWayCount == 1) penalty = 5;
                  else if (wrongWayCount == 2) penalty = 15;
                  else penalty = 3;
                } 
                // SPEEDING (Tiered) -> Matches Slide
                else if (type.contains("Speeding")) {
                   int overLimit = speed - 100; // Assuming 100km/h limit
                   
                   if (overLimit > 30) penalty = 30;       // >30 km/h over
                   else if (overLimit > 15) penalty = 15;  // 15-30 km/h over
                   else penalty = 5;                       // 5-15 km/h over
                } else {
                  penalty = 5; // Default minor penalty
                }
                
                totalDeductions += penalty;
              }
            }

            // 3. Base Score Calculation
            int rawScore = (100 - totalDeductions.toInt());

            // 4. RECOVERY LOGIC (+2 pts per clean week) -> Matches Slide
            int recoveryBonus = 0;
            if (lastViolationDate != null) {
              int daysSinceLast = DateTime.now().difference(lastViolationDate!).inDays;
              int cleanWeeks = (daysSinceLast / 7).floor(); // Full weeks only
              recoveryBonus = cleanWeeks * 2;
            } else {
              // Perfect driver (no violations ever)
              recoveryBonus = 0; 
            }

            // Final Score (Base - Deductions + Recovery), Clamped 0-100
            int safetyScore = (rawScore + recoveryBonus).clamp(0, 100);
            
            // -------------------------------------------------------------

            return Scaffold(
              appBar: AppBar(
                title: const Text("Driver Profile"),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    tooltip: "Add Vehicle",
                    onPressed: () => _showAddVehicleDialog(context, user.uid, ownerPlate),
                  )
                ],
              ),
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 30),
                    // A. AVATAR
                    Center(
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: _getScoreColor(safetyScore), width: 4),
                            ),
                            child: CircleAvatar(
                              radius: 50,
                              backgroundColor: _getScoreColor(safetyScore),
                              child: const Icon(Icons.person, size: 50, color: Colors.white),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(ownerPlate, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                          Text(
                            _getScoreLabel(safetyScore), 
                            style: TextStyle(color: _getScoreColor(safetyScore), fontWeight: FontWeight.bold)
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 30),

                    // B. STATS ROW
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          _statBox("Safety Score", "$safetyScore%", _getScoreColor(safetyScore), Icons.shield),
                          const SizedBox(width: 15),
                          _statBox("Total Fines", "$totalFines JOD", Colors.red, Icons.money_off),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // C. MY VEHICLES LIST
                    _header("My Registered Vehicles"),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: myPlates.length,
                      itemBuilder: (ctx, index) {
                        String plate = myPlates[index];
                        bool isOwner = (plate == ownerPlate);

                        return ListTile(
                          leading: Icon(
                            Icons.directions_car, 
                            color: isOwner ? const Color(0xFF556B2F) : Colors.grey
                          ),
                          title: Text(
                            plate, 
                            style: TextStyle(
                              fontWeight: isOwner ? FontWeight.bold : FontWeight.normal,
                              color: Colors.black87
                            )
                          ),
                          subtitle: isOwner 
                              ? const Text("Owner's Vehicle", style: TextStyle(fontSize: 12, color: Colors.amber, fontWeight: FontWeight.bold))
                              : const Text("Monitored Vehicle", style: TextStyle(fontSize: 12, color: Colors.grey)),
                          
                          trailing: isOwner
                              ? const Icon(Icons.lock, color: Colors.grey, size: 18) 
                              : IconButton( 
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _removeVehicle(user.uid, plate),
                                ),
                        );
                      },
                    ),

                    const SizedBox(height: 20),
                    _header("App Preferences"),
                    SwitchListTile(
                      title: const Text("Push Notifications"),
                      value: _notifications,
                      onChanged: (v) => setState(() => _notifications = v),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          await FirebaseAuth.instance.signOut();
                          if (mounted) {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (_) => const LoginScreen()),
                              (route) => false,
                            );
                          }
                        },
                        icon: const Icon(Icons.logout, color: Colors.red),
                        label: const Text("Log Out"),
                        style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // --- LOGIC FUNCTIONS ---
  void _showAddVehicleDialog(BuildContext context, String uid, String ownerPlate) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Monitor New Vehicle"),
        content: TextField(controller: controller, decoration: const InputDecoration(hintText: "Plate Number")),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              String newPlate = controller.text.trim().toUpperCase();
              if (newPlate.isNotEmpty) {
                await FirebaseFirestore.instance.collection('users').doc(uid).set({
                  'registeredPlates': FieldValue.arrayUnion([ownerPlate, newPlate])
                }, SetOptions(merge: true));
                if (ctx.mounted) Navigator.pop(ctx);
              }
            },
            child: const Text("Add"),
          )
        ],
      ),
    );
  }

  Future<void> _removeVehicle(String uid, String plate) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).update({'registeredPlates': FieldValue.arrayRemove([plate])});
  }

  // --- UI HELPERS ---
  Widget _statBox(String label, String value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 5),
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _header(String t) => Container(
    width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), color: Colors.grey[200],
    child: Text(t, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
  );

  // --- COLOR & LABEL LOGIC ---
  Color _getScoreColor(int score) {
    if (score >= 90) return Colors.green;
    if (score >= 70) return Colors.lightGreen;
    if (score >= 50) return Colors.orange;
    return Colors.red;
  }

  String _getScoreLabel(int score) {
    if (score >= 90) return "Excellent Driver";
    if (score >= 70) return "Good Driver";
    if (score >= 50) return "At Risk";
    return "Dangerous Driver";
  }
}
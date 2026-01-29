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

        // 3. Fetch Violations ONLY for the OWNER PLATE (Profile Stats are personal)
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('violations')
              .where('licensePlate', isEqualTo: ownerPlate) 
              .snapshots(),
          builder: (context, violationSnap) {
            
            // --- 🧠 SMART SCORING (For Owner Only) ---
            int totalFines = 0;
            double totalDeductions = 0;
            int safetyScore = 100;

            if (violationSnap.hasData) {
              final docs = violationSnap.data!.docs;
              
              for (var doc in docs) {
                final data = doc.data() as Map<String, dynamic>;
                
                // Sum Fines
                totalFines += (data['fineAmount'] as num? ?? 0).toInt();

                // Get Data Points
                String type = (data['violationType'] ?? "").toString();
                int speed = (data['speed'] as num? ?? 0).toInt();
                
                DateTime violationDate = DateTime.now();
                if (data['timestamp'] != null) {
                  try {
                    violationDate = (data['timestamp'] as Timestamp).toDate();
                  } catch (e) { /* ignore */ }
                }
                int daysAgo = DateTime.now().difference(violationDate).inDays;

                // Base Penalty
                double penalty = 0;
                if (type.contains("Wrong") || type.contains("Way")) {
                  penalty = 20; 
                } else if (type.contains("Speeding")) {
                   if (speed > 130) penalty = 25;
                   else if (speed > 100) penalty = 10;
                   else penalty = 5;
                } else {
                  penalty = 5;
                }

                if (daysAgo > 30) penalty *= 0.5;
                totalDeductions += penalty;
              }
              safetyScore = (100 - totalDeductions.toInt()).clamp(0, 100);
            }
            // --------------------------

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
                    // A. AVATAR (Reflects OWNER Stats)
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

                    // B. STATS ROW (Reflects OWNER Stats)
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

                    // C. MY VEHICLES LIST (Static / Read-Only)
                    _header("My Registered Vehicles"),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: myPlates.length,
                      itemBuilder: (ctx, index) {
                        String plate = myPlates[index];
                        bool isOwner = (plate == ownerPlate);

                        return ListTile(
                          // onTap is REMOVED to make it non-clickable
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
                // Ensure owner plate is preserved
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
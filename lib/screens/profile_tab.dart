import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart'; // To navigate back on logout

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  // Local state for toggles (Visual only for now)
  bool _notifications = true;
  bool _emailAlerts = false;

  @override
  Widget build(BuildContext context) {
    // 1. Identify the Driver
    final user = FirebaseAuth.instance.currentUser;
    String myPlateNumber = "Unknown";
    if (user != null && user.email != null) {
      myPlateNumber = user.email!.split('@')[0].toUpperCase();
    }

    return StreamBuilder<QuerySnapshot>(
      // 2. Listen to Database for Stats
      stream: FirebaseFirestore.instance
          .collection('violations')
          .where('licensePlate', isEqualTo: myPlateNumber)
          .snapshots(),
          
      builder: (context, snapshot) {
        // --- CALCULATIONS ---
        int totalFines = 0;
        int violationCount = 0;
        int safetyScore = 100;

        if (snapshot.hasData) {
          final docs = snapshot.data!.docs;
          violationCount = docs.length;
          
          for (var doc in docs) {
            totalFines += (doc['fineAmount'] as num).toInt();
          }
          // Simple Safety Formula: Start at 100, lose 10 per violation
          safetyScore = (100 - (violationCount * 10)).clamp(0, 100);
        }
        // --------------------

        return Scaffold(
          appBar: AppBar(title: const Text("Driver Profile")),
          body: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 30),
                
                // A. IDENTITY CARD
                Center(
                  child: Column(
                    children: [
                      // Avatar with Safety Color Ring
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _getScoreColor(safetyScore), 
                            width: 4
                          ),
                        ),
                        child: const CircleAvatar(
                          radius: 50,
                          backgroundColor: Color(0xFF556B2F),
                          child: Icon(Icons.person, size: 50, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 15),
                      
                      // License Plate Display
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.amber[300],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.black, width: 2),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4, offset: const Offset(2, 2))
                          ]
                        ),
                        child: Text(
                          myPlateNumber,
                          style: const TextStyle(
                            fontSize: 24, 
                            fontWeight: FontWeight.bold, 
                            letterSpacing: 2,
                            color: Colors.black
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(user?.email ?? "", style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // B. LIVE STATS ROW
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

                // C. SETTINGS SECTION
                _header("App Preferences"),
                SwitchListTile(
                  secondary: const Icon(Icons.notifications_active),
                  title: const Text("Push Notifications"),
                  subtitle: const Text("Get alerted instantly for new fines"),
                  value: _notifications,
                  activeColor: const Color(0xFF556B2F),
                  onChanged: (v) => setState(() => _notifications = v),
                ),
                SwitchListTile(
                  secondary: const Icon(Icons.email),
                  title: const Text("Email Reports"),
                  subtitle: const Text("Receive monthly summaries"),
                  value: _emailAlerts,
                  activeColor: const Color(0xFF556B2F),
                  onChanged: (v) => setState(() => _emailAlerts = v),
                ),

                const SizedBox(height: 40),

                // D. LOGOUT BUTTON
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      // 1. Sign out from Firebase
                      await FirebaseAuth.instance.signOut();
                      
                      // 2. Navigate back to Login Screen
                      if (mounted) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                          (route) => false, // Remove all previous routes
                        );
                      }
                    },
                    icon: const Icon(Icons.logout, color: Colors.red),
                    label: const Text("Log Out", style: TextStyle(color: Colors.red, fontSize: 16)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- HELPER: Stat Box ---
  Widget _statBox(String label, String value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
             BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))
          ],
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

  // --- HELPER: Header Text ---
  Widget _header(String t) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    color: Colors.grey[100],
    child: Text(t, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))
  );

  // --- HELPER: Color Logic ---
  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 50) return Colors.orange;
    return Colors.red;
  }
}
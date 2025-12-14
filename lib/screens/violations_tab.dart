import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'details_screen.dart'; // Make sure you have this file created!

class ViolationsTab extends StatelessWidget {
  const ViolationsTab({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Get the current logged-in user
    final user = FirebaseAuth.instance.currentUser;
    
    // 2. EXTRACT THE PLATE
    // Logic: If email is "50-TEST@traffic.app", split returns ["50-TEST", "traffic.app"]. 
    // We take the first part [0].
    String myPlateNumber = "Unknown";
    if (user != null && user.email != null) {
      myPlateNumber = user.email!.split('@')[0].toUpperCase();
    }
    return Scaffold(
      appBar: AppBar(title: Text("Plate: $myPlateNumber")),
      
      // 3. LISTEN TO FIREBASE
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('violations')
            // --- THE FILTER ---
            // Only show violations where 'licensePlate' matches the user's login
            .where('licensePlate', isEqualTo: myPlateNumber) 
            .orderBy('timestamp', descending: true)
            .snapshots(),
            
        builder: (context, snapshot) {
          // A. Loading State
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // B. Error State
          if (snapshot.hasError) {
             // NOTE: If you see "Requires an Index" error here, check your Debug Console for the link!
             return Center(child: Padding(
               padding: const EdgeInsets.all(20.0),
               child: Text("Error: ${snapshot.error}", textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
             ));
          }

          // C. Empty State (Good News!)
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle, size: 80, color: Colors.green),
                  const SizedBox(height: 20),
                  Text(
                    "No Violations for $myPlateNumber",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Text("Drive safely!", style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          // D. Data Exists - Build the List
          final docs = snapshot.data!.docs;
          
          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final item = docs[index].data();
              
              // Safe Date Parsing
              String dateString = "Unknown Date";
              if (item['timestamp'] != null) {
                try {
                  dateString = (item['timestamp'] as Timestamp).toDate().toString().substring(0, 16);
                } catch (e) {
                   dateString = "Invalid Date";
                }
              }

              return Card(
                elevation: 3,
                color: const Color(0xFFFFFFF0), // Off-white theme color
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF556B2F).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      (item['violationType'] ?? "").toString().contains('Speeding') 
                          ? Icons.speed 
                          : Icons.warning_amber_rounded,
                      color: const Color(0xFF556B2F),
                      size: 28,
                    ),
                  ),
                  title: Text(
                    item['violationType'] ?? 'Unknown Violation',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 5.0),
                    child: Text(dateString, style: TextStyle(color: Colors.grey[600])),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "${item['fineAmount'] ?? 0} JOD",
                        style: const TextStyle(
                          color: Colors.red, 
                          fontWeight: FontWeight.bold, 
                          fontSize: 16
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
                    ],
                  ),
                  onTap: () {
                    // Navigate to Details Screen
                    Navigator.push(
                      context, 
                      MaterialPageRoute(
                        builder: (context) => ViolationDetailsScreen(data: item)
                      )
                    );
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
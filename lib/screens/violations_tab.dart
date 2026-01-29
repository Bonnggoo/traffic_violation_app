import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'details_screen.dart';

class ViolationsTab extends StatefulWidget {
  const ViolationsTab({super.key});

  @override
  State<ViolationsTab> createState() => _ViolationsTabState();
}

class _ViolationsTabState extends State<ViolationsTab> {
  String _selectedFilter = "All"; 

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Center(child: Text("Error: No User"));

    // 1. IDENTITY LOGIC: Login Email = Owner Plate
    String ownerPlate = user.email!.split('@')[0].toUpperCase();

    // 2. FIRST STREAM: Fetch User Profile
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
      builder: (context, userSnap) {
        
        // --- DATA PREPARATION ---
        List<dynamic> myPlates = [];
        
        if (userSnap.hasData && userSnap.data!.exists) {
           final data = userSnap.data!.data() as Map<String, dynamic>;
           myPlates = data['registeredPlates'] ?? [ownerPlate];
        } else {
           myPlates = [ownerPlate];
        }

        // Safety check & Sorting
        if (!myPlates.contains(ownerPlate)) myPlates.add(ownerPlate);
        
        // Sort Owner First
        List<String> sortedPlates = List<String>.from(myPlates.map((e) => e.toString()));
        sortedPlates.sort((a, b) {
          if (a == ownerPlate) return -1;
          if (b == ownerPlate) return 1;
          return a.compareTo(b);
        });

        // 3. CONSTRUCT QUERY
        Query violationsQuery = FirebaseFirestore.instance
            .collection('violations')
            .orderBy('timestamp', descending: true);

        if (_selectedFilter == "All") {
          violationsQuery = violationsQuery.where('licensePlate', whereIn: sortedPlates);
        } else {
          violationsQuery = violationsQuery.where('licensePlate', isEqualTo: _selectedFilter);
        }

        // 4. SECOND STREAM: Fetch Violations
        return StreamBuilder<QuerySnapshot>(
          stream: violationsQuery.snapshots(),
          builder: (context, snapshot) {
            
            return Scaffold(
              appBar: AppBar(
                title: const Text("My Violations"),
                elevation: 0,
              ),
              body: Column(
                children: [
                  // --- A. VEHICLE FILTER DROPDOWN ---
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    color: const Color(0xFF556B2F).withOpacity(0.1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF556B2F).withOpacity(0.3))
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: sortedPlates.contains(_selectedFilter) ? _selectedFilter : "All",
                          icon: const Icon(Icons.filter_list, color: Color(0xFF556B2F)),
                          isExpanded: true,
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                _selectedFilter = newValue;
                              });
                            }
                          },
                          items: [
                            const DropdownMenuItem(
                              value: "All",
                              child: Text("All Vehicles", style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            ...sortedPlates.map<DropdownMenuItem<String>>((plate) {
                              // Check if this is the owner's plate
                              bool isOwner = (plate == ownerPlate);
                              
                              return DropdownMenuItem(
                                value: plate,
                                child: Row(
                                  children: [
                                    Text("Plate: $plate"),
                                    // --- THE STAR ICON LOGIC ---
                                    if (isOwner) ...[
                                      const SizedBox(width: 8),
                                      const Icon(Icons.star, size: 16, color: Colors.amber),
                                    ]
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // --- B. VIOLATIONS LIST ---
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle_outline, size: 80, color: Colors.grey[300]),
                                const SizedBox(height: 10),
                                Text(
                                  _selectedFilter == "All" 
                                      ? "No violations found for any vehicle." 
                                      : "No violations for $_selectedFilter.",
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          );
                        }

                        final docs = snapshot.data!.docs;
                        return ListView.builder(
                          padding: const EdgeInsets.all(10),
                          itemCount: docs.length,
                          itemBuilder: (context, index) {
                            final item = docs[index].data() as Map<String, dynamic>;
                            return _buildViolationCard(context, item);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // --- HELPER: Card Widget ---
  Widget _buildViolationCard(BuildContext context, Map<String, dynamic> item) {
    String dateString = "Unknown Date";
    if (item['timestamp'] != null) {
      try {
        dateString = (item['timestamp'] as Timestamp).toDate().toString().substring(0, 16);
      } catch (e) {
         dateString = "Invalid Date";
      }
    }

    bool isSpeeding = (item['violationType'] ?? "").toString().contains('Speeding');
    bool isWrongWay = (item['violationType'] ?? "").toString().contains('Wrong');

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isSpeeding ? Colors.red[50] : Colors.orange[50],
            shape: BoxShape.circle,
          ),
          child: Icon(
            isSpeeding ? Icons.speed : (isWrongWay ? Icons.back_hand : Icons.warning),
            color: isSpeeding ? Colors.red : Colors.orange,
            size: 28,
          ),
        ),
        title: Text(
          item['violationType'] ?? 'Unknown',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(5)
              ),
              child: Text(
                item['licensePlate'] ?? "Unknown",
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ),
            const SizedBox(height: 4),
            Text(dateString, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ],
        ),
        trailing: Text(
          "${item['fineAmount'] ?? 0} JOD",
          style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        onTap: () {
          Navigator.push(
            context, 
            MaterialPageRoute(builder: (context) => ViolationDetailsScreen(data: item))
          );
        },
      ),
    );
  }
}
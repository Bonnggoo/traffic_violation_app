import 'package:flutter/material.dart';
import 'package:traffic_violation_app/screens/details_screen.dart';

// --- 5. DASHBOARD TAB ---
class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy alert for the dashboard (separate from the real list for now)
    final Map<String, dynamic> recentAlertData = {
      "violationType": "Speeding Detected",
      "date": "Just now",
      "fineAmount": "50",
      "imageUrl": "https://cdn.pixabay.com/photo/2012/11/02/13/02/car-63930_1280.jpg"
    };

    return Scaffold(
      appBar: AppBar(title: const Text("Traffic Guard Home")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(bottom: 30, top: 10),
              decoration: const BoxDecoration(
                color: Color(0xFF556B2F),
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
              ),
              child: Column(
                children: [
                  const Text("Safety Score", style: TextStyle(color: Colors.white70, fontSize: 18)),
                  const SizedBox(height: 20),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(width: 120, height: 120, child: CircularProgressIndicator(value: 1.0, color: Colors.white24, strokeWidth: 10)),
                      const SizedBox(width: 120, height: 120, child: CircularProgressIndicator(value: 0.85, color: Colors.white, strokeWidth: 10, strokeCap: StrokeCap.round)),
                      const Column(children: [Text("85", style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold)), Text("Good", style: TextStyle(color: Colors.white, fontSize: 12))]),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  Expanded(child: _buildStatCard("Pending Fines", "150 JOD", Icons.money_off, Colors.red)),
                  const SizedBox(width: 15),
                  Expanded(child: _buildStatCard("Clean Days", "12 Days", Icons.check_circle, const Color(0xFF556B2F))),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Recent Alert", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF556B2F))),
                  const SizedBox(height: 10),
                  Card(
                    color: const Color(0xFFFFFFF0),
                    child: ListTile(
                      leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.warning, color: Colors.red)),
                      title: const Text("Speeding Detected"),
                      subtitle: const Text("Just now • Airport Road"),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                      onTap: () {
                         Navigator.push(context, MaterialPageRoute(builder: (context) => ViolationDetailsScreen(data: recentAlertData)));
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildStatCard(String t, String v, IconData i, Color c) => Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(i, color: c, size: 30), const SizedBox(height: 10), Text(v, style: TextStyle(color: c, fontSize: 22, fontWeight: FontWeight.bold)), Text(t, style: const TextStyle(color: Colors.grey, fontSize: 14))]));
}

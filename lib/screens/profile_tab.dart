import 'package:flutter/material.dart';
import 'package:traffic_violation_app/screens/login_screen.dart';

// --- 7. PROFILE TAB ---
class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  bool _notifications = true;
  bool _email = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Driver Profile")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 30),
            const CircleAvatar(radius: 50, backgroundColor: Color(0xFF556B2F), child: Icon(Icons.person, size: 50, color: Colors.white)),
            const SizedBox(height: 15),
            const Text("Laith Abu-Abbas", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const Text("License: 99-12345", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 30),
            _header("Account Settings"),
            Container(color: Colors.white, child: SwitchListTile(title: const Text("Push Notifications"), value: _notifications, activeColor: const Color(0xFF556B2F), onChanged: (v) => setState(() => _notifications = v))),
            Container(color: Colors.white, child: SwitchListTile(title: const Text("Email Alerts"), value: _email, activeColor: const Color(0xFF556B2F), onChanged: (v) => setState(() => _email = v))),
            _header("My Vehicle"),
            const Card(color: Colors.white, margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5), child: ListTile(leading: Icon(Icons.directions_car, color: Color(0xFF556B2F)), title: Text("Toyota Prius"), subtitle: Text("Plate: 50-99999"))),
            const SizedBox(height: 40),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: OutlinedButton.icon(onPressed: () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen())), icon: const Icon(Icons.logout, color: Colors.red), label: const Text("Log Out", style: TextStyle(color: Colors.red)), style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red), minimumSize: const Size(double.infinity, 50)))),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
  Widget _header(String t) => Container(width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), color: Colors.grey[200], child: Text(t, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)));
}

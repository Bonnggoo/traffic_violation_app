import 'package:flutter/material.dart';
import 'package:traffic_violation_app/screens/main_layout.dart';

// --- 3. LOGIN SCREEN ---
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.traffic_rounded, size: 80, color: Color(0xFF556B2F)),
            const SizedBox(height: 20),
            const Text("Welcome Back", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF556B2F))),
            const SizedBox(height: 40),
            const TextField(
              decoration: InputDecoration(
                labelText: "Vehicle ID / Email",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person, color: Color(0xFF556B2F)),
                filled: true, fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 15),
            const TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock, color: Color(0xFF556B2F)),
                filled: true, fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const MainAppLayout()),
                );
              },
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              child: const Text("Login", style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}

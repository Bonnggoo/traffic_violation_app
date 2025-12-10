import 'package:flutter/material.dart';

void main() {
  runApp(const TrafficApp());
}

class TrafficApp extends StatelessWidget {
  const TrafficApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Traffic Violation Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // --- NEW COLOR SCHEME ---
        // Primary: Olive Green, Background: Beige
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF556B2F), // Dark Olive Green
          primary: const Color(0xFF556B2F),
          secondary: const Color(0xFF8F9779), // Lighter Olive
          surface: const Color(0xFFF5F5DC),   // Beige
          onSurface: const Color(0xFF3E3E3E), // Dark Grey Text (for readability)
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F5DC), // Beige Background
        useMaterial3: true,
        
        // Customizing App Bar to be Olive
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF556B2F),
          foregroundColor: Colors.white, // Text color on AppBar
        ),
        
        // Customizing Buttons
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF556B2F), // Olive Button
            foregroundColor: const Color(0xFFF5F5DC), // Beige Text
          ),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}

// --- 1. LOGIN SCREEN ---
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
            // Updated Icon Color
            const Icon(Icons.traffic_rounded, size: 80, color: Color(0xFF556B2F)),
            const SizedBox(height: 20),
            const Text(
              "Traffic Guard",
              style: TextStyle(
                fontSize: 28, 
                fontWeight: FontWeight.bold,
                color: Color(0xFF556B2F), // Olive Text
              ),
            ),
            const SizedBox(height: 40),
            
            // Text Fields
            const TextField(
              decoration: InputDecoration(
                labelText: "Vehicle ID / Email",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person, color: Color(0xFF556B2F)),
                filled: true,
                fillColor: Colors.white, // White box to pop against beige
              ),
            ),
            const SizedBox(height: 15),
            const TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock, color: Color(0xFF556B2F)),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 30),
            
            // Login Button
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text("Login", style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}

// --- 2. HOME SCREEN (VIOLATION LIST) ---
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> fakeViolations = [
      {
        "type": "Wrong-Way Driving",
        "date": "2024-05-12 14:30",
        "fine": "100 JOD",
        "icon": Icons.warning,
      },
      {
        "type": "Speeding (140 km/h)",
        "date": "2024-05-10 09:15",
        "fine": "50 JOD",
        "icon": Icons.speed,
      },
      {
        "type": "Speeding (120 km/h)",
        "date": "2024-05-08 18:20",
        "fine": "30 JOD",
        "icon": Icons.speed,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Violations"),
      ),
      body: ListView.builder(
        itemCount: fakeViolations.length,
        itemBuilder: (context, index) {
          final item = fakeViolations[index];
          return Card(
            // Making the card slightly off-white/lighter beige for contrast
            color: const Color(0xFFFFFFF0), 
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: ListTile(
              leading: Icon(item['icon'], color: const Color(0xFF556B2F), size: 30),
              title: Text(
                item['type'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(item['date']),
              trailing: Text(
                item['fine'],
                style: const TextStyle(
                    color: Color(0xFF556B2F), 
                    fontWeight: FontWeight.bold, 
                    fontSize: 15),
              ),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Loading Violation Details..."),
                    backgroundColor: Color(0xFF556B2F),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
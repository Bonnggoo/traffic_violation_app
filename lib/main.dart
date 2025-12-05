import 'package:flutter/material.dart';

void main() {
  // We removed 'WidgetsFlutterBinding' and 'Firebase.initializeApp'
  // so this will run instantly on your simulator/phone.
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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
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
            const Icon(Icons.traffic_rounded, size: 80, color: Colors.red),
            const SizedBox(height: 20),
            const Text(
              "Traffic Guard",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            const TextField(
              decoration: InputDecoration(
                labelText: "Vehicle ID / Email",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 15),
            const TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                // Navigate to the Home Screen
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text("Login"),
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
    // This is "Mock Data" to simulate what the Pi would send
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
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: fakeViolations.length,
        itemBuilder: (context, index) {
          final item = fakeViolations[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: ListTile(
              leading: Icon(item['icon'], color: Colors.red, size: 30),
              title: Text(
                item['type'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(item['date']),
              trailing: Text(
                item['fine'],
                style: const TextStyle(
                    color: Colors.red, fontWeight: FontWeight.bold, fontSize: 15),
              ),
              onTap: () {
                // Later: Navigate to Details Screen with Map
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Loading Violation Details...")),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
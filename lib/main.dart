import 'dart:async'; // For the Splash Screen timer
import 'package:flutter/material.dart';

// --- 1. INITIALIZATION (OFFLINE MODE) ---
void main() {
  // No Firebase initialization needed here for offline mode
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
        // --- OLIVE & BEIGE THEME ---
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF556B2F), // Dark Olive Green
          primary: const Color(0xFF556B2F),
          secondary: const Color(0xFF8F9779),
          surface: const Color(0xFFF5F5DC),   // Beige
          onSurface: const Color(0xFF3E3E3E), // Dark Grey
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F5DC),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF556B2F),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF556B2F),
            foregroundColor: const Color(0xFFF5F5DC),
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFFFFFFF0),
          selectedItemColor: Color(0xFF556B2F),
          unselectedItemColor: Colors.grey,
        ),
      ),
      // Start with the Splash Screen
      home: const SplashScreen(),
    );
  }
}

// --- 2. SPLASH SCREEN ---
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Wait 3 seconds, then go to Login
    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF556B2F), // Full Olive Background
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo Icon (White)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.traffic_rounded, size: 80, color: Color(0xFF556B2F)),
            ),
            const SizedBox(height: 20),
            // App Name
            const Text(
              "Traffic Guard",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Smart Detection System",
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 50),
            // Loading Spinner
            const CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}

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
            const Text(
              "Welcome Back",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF556B2F)),
            ),
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

// --- 4. MAIN LAYOUT (BOTTOM NAV) ---
class MainAppLayout extends StatefulWidget {
  const MainAppLayout({super.key});

  @override
  State<MainAppLayout> createState() => _MainAppLayoutState();
}

class _MainAppLayoutState extends State<MainAppLayout> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    const DashboardTab(),
    const ViolationsTab(),
    const ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Dashboard"),
          BottomNavigationBarItem(icon: Icon(Icons.warning_amber_rounded), label: "Violations"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}

// --- 5. DASHBOARD TAB (SPEEDOMETER UI) ---
class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Traffic Guard Home")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Green Header with Gauge
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
            // Stats Row
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
            // Recent Alert
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

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, color: color, size: 30), const SizedBox(height: 10), Text(value, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.bold)), Text(title, style: const TextStyle(color: Colors.grey, fontSize: 14))]),
    );
  }
}

// --- 6. VIOLATIONS TAB (OFFLINE DUMMY DATA) ---
class ViolationsTab extends StatelessWidget {
  const ViolationsTab({super.key});

  @override
  Widget build(BuildContext context) {
    // FAKE DATA FOR OFFLINE MODE
    final List<Map<String, dynamic>> fakeViolations = [
      {
        "violationType": "Wrong-Way Driving",
        "date": "2024-05-12 14:30",
        "fineAmount": "100",
        "imageUrl": "https://cdn.pixabay.com/photo/2012/11/02/13/02/car-63930_1280.jpg"
      },
      {
        "violationType": "Speeding (140 km/h)",
        "date": "2024-05-10 09:15",
        "fineAmount": "50",
        "imageUrl": "https://cdn.pixabay.com/photo/2012/11/02/13/02/car-63930_1280.jpg"
      },
      {
        "violationType": "Speeding (120 km/h)",
        "date": "2024-05-08 18:20",
        "fineAmount": "30",
        "imageUrl": "https://cdn.pixabay.com/photo/2012/11/02/13/02/car-63930_1280.jpg"
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("My Violations")),
      body: ListView.builder(
        itemCount: fakeViolations.length,
        itemBuilder: (context, index) {
          final item = fakeViolations[index];
          return Card(
            color: const Color(0xFFFFFFF0),
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: ListTile(
              leading: Icon(
                  item['violationType'].contains('Speeding') ? Icons.speed : Icons.warning_amber_rounded,
                  color: const Color(0xFF556B2F),
                  size: 30
              ),
              title: Text(item['violationType'], style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(item['date']),
              trailing: Text("${item['fineAmount']} JOD", style: const TextStyle(color: Color(0xFF556B2F), fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ViolationDetailsScreen(data: item))
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// --- 7. PROFILE TAB (SETTINGS) ---
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
            const Text("Abdullah Al-Ajlouny", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
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

// --- 8. DETAILS SCREEN (SPLIT LAYOUT) ---
class ViolationDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> data;
  const ViolationDetailsScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Violation Details")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // A. Text Details
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Card(
                elevation: 0, color: const Color(0xFFFFFFF0),
                shape: RoundedRectangleBorder(side: const BorderSide(color: Color(0xFF556B2F)), borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(children: [
                    _row(context, "Violation Type", data['violationType'] ?? 'Unknown', true), const Divider(),
                    _row(context, "Date & Time", data['date'] ?? 'Unknown', false), const Divider(),
                    _row(context, "Fine Amount", "${data['fineAmount']} JOD", true, Colors.red), const Divider(),
                    _row(context, "Location", "Amman, Jordan", false),
                  ]),
                ),
              ),
            ),
            // B. Map & Image
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: SizedBox(
                height: 180,
                child: Row(children: [
                  Expanded(child: Container(decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey)), child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.location_on, color: Colors.red, size: 40), Text("Map Location")]))),
                  const SizedBox(width: 10),
                  Expanded(child: Container(decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey)), clipBehavior: Clip.antiAlias, child: Image.network(data['imageUrl'] ?? "", fit: BoxFit.cover, errorBuilder: (c, e, s) => const Center(child: Icon(Icons.broken_image, size: 40, color: Colors.grey))))),
                ]),
              ),
            ),
            // C. Button
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: ElevatedButton.icon(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Dispute sent."))), icon: const Icon(Icons.gavel), label: const Text("Dispute This Violation"), style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50))),
            ),
          ],
        ),
      ),
    );
  }
  Widget _row(BuildContext c, String l, String v, bool b, [Color? col]) => Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(l, style: const TextStyle(color: Colors.grey)), Flexible(child: Text(v, style: TextStyle(fontWeight: b ? FontWeight.bold : FontWeight.normal, color: col ?? Colors.black)))]));
}
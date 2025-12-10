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
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF556B2F), // Dark Olive Green
          primary: const Color(0xFF556B2F),
          secondary: const Color(0xFF8F9779),
          surface: const Color(0xFFF5F5DC),   // Beige
          onSurface: const Color(0xFF3E3E3E),
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F5DC),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF556B2F),
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF556B2F),
            foregroundColor: const Color(0xFFF5F5DC),
          ),
        ),
        // Navigation Bar Theme
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFFFFFFF0), // Off-white bar
          selectedItemColor: Color(0xFF556B2F), // Olive for active
          unselectedItemColor: Colors.grey,     // Grey for inactive
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
            const Icon(Icons.traffic_rounded, size: 80, color: Color(0xFF556B2F)),
            const SizedBox(height: 20),
            const Text(
              "Traffic Guard",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF556B2F)),
            ),
            const SizedBox(height: 40),
            const TextField(
              decoration: InputDecoration(
                labelText: "Vehicle ID / Email",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person, color: Color(0xFF556B2F)),
                filled: true,
                fillColor: Colors.white,
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
            ElevatedButton(
              onPressed: () {
                // Navigate to the NEW Main Layout (Bottom Nav)
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

// --- 2. MAIN LAYOUT (Holds the Bottom Navigation) ---
class MainAppLayout extends StatefulWidget {
  const MainAppLayout({super.key});

  @override
  State<MainAppLayout> createState() => _MainAppLayoutState();
}

class _MainAppLayoutState extends State<MainAppLayout> {
  int _currentIndex = 0;

  // These are the 3 screens for the bottom buttons
  final List<Widget> _screens = [
    const DashboardTab(),   // Index 0: Home
    const ViolationsTab(),  // Index 1: Violations List
    const ProfileTab(),     // Index 2: Profile
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The body changes based on which button is clicked
      body: _screens[_currentIndex],
      
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.warning_amber_rounded), label: "Violations"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}

// --- TAB 1: DASHBOARD (Home) ---
class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Traffic Guard Home")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Safety Score Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF556B2F),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Column(
                children: [
                  Text("Safety Score", style: TextStyle(color: Colors.white, fontSize: 18)),
                  SizedBox(height: 10),
                  Text("85", style: TextStyle(color: Colors.white, fontSize: 60, fontWeight: FontWeight.bold)),
                  Text("Good Driver", style: TextStyle(color: Colors.white70)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Quick Stats
            Row(
              children: [
                Expanded(child: _buildStatCard(context, "Pending Fines", "150 JOD", Colors.red)),
                const SizedBox(width: 10),
                Expanded(child: _buildStatCard(context, "Clean Days", "12", Colors.green)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 5),
          Text(value, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// --- TAB 2: VIOLATIONS LIST (Your old HomeScreen) ---
class ViolationsTab extends StatelessWidget {
  const ViolationsTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Fake data for offline mode
    final List<Map<String, dynamic>> fakeViolations = [
      {"type": "Wrong-Way Driving", "date": "2024-05-12 14:30", "fine": "100 JOD", "icon": Icons.warning},
      {"type": "Speeding (140 km/h)", "date": "2024-05-10 09:15", "fine": "50 JOD", "icon": Icons.speed},
      {"type": "Speeding (120 km/h)", "date": "2024-05-08 18:20", "fine": "30 JOD", "icon": Icons.speed},
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
              leading: Icon(item['icon'], color: const Color(0xFF556B2F), size: 30),
              title: Text(item['type'], style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(item['date']),
              trailing: Text(item['fine'], style: const TextStyle(color: Color(0xFF556B2F), fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ViolationDetailsScreen(data: item)),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// --- TAB 3: PROFILE SCREEN ---
class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Profile")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CircleAvatar(radius: 50, backgroundColor: Color(0xFF556B2F), child: Icon(Icons.person, size: 50, color: Colors.white)),
            const SizedBox(height: 10),
            const Text("Abdullah Al-Ajlouny", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const Text("License: 99-12345", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 30),
            _buildProfileOption(Icons.car_rental, "My Vehicles"),
            _buildProfileOption(Icons.notifications, "Notifications"),
            _buildProfileOption(Icons.language, "Language"),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                // Logout Logic
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
              }, 
              child: const Text("Logout")
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption(IconData icon, String title) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF556B2F)),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }
}

// --- DETAIL SCREEN (Same as before) ---
// --- 3. VIOLATION DETAILS SCREEN (UPDATED LAYOUT) ---
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
            // A. TEXT DETAILS (Now on Top)
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Card(
                elevation: 0,
                color: const Color(0xFFFFFFF0), // Light Ivory background
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: Color(0xFF556B2F), width: 1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    children: [
                      _row(context, "Violation Type", data['type'], true),
                      const Divider(),
                      _row(context, "Date & Time", data['date'], false),
                      const Divider(),
                      _row(context, "Fine Amount", data['fine'], true, Colors.red),
                      const Divider(),
                      _row(context, "Location", "Amman, Jordan", false),
                    ],
                  ),
                ),
              ),
            ),

            // B. MAP AND IMAGE (Side-by-Side)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: SizedBox(
                height: 180, // Fixed height for both boxes
                child: Row(
                  children: [
                    // 1. The Map (Left Side)
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.location_on, color: Colors.red, size: 40),
                            Text("Map Location", style: TextStyle(color: Colors.black54)),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 10), // Spacing between them

                    // 2. The Snapshot (Right Side)
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black12,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey),
                        ),
                        clipBehavior: Clip.antiAlias, // Clips the image to rounded corners
                        child: Image.network(
                          // Use the real image URL if available, otherwise placeholder
                          data['imageUrl'] ?? "https://cdn.pixabay.com/photo/2012/11/02/13/02/car-63930_1280.jpg",
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => const Center(
                            child: Icon(Icons.broken_image, size: 40, color: Colors.grey),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // C. DISPUTE BUTTON (Bottom)
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Dispute request submitted.")),
                  );
                },
                icon: const Icon(Icons.gavel),
                label: const Text("Dispute This Violation"),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget for text rows
  Widget _row(BuildContext context, String label, String value, bool bold, [Color? color]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          Flexible( // Prevents long text from breaking the layout
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 16,
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                color: color ?? Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
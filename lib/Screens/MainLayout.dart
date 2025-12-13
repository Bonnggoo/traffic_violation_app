import 'package:flutter/material.dart';
import 'package:traffic_violation_app/Screens/DashboardTab.dart';
import 'package:traffic_violation_app/Screens/ProfileTab.dart';
import 'package:traffic_violation_app/Screens/ViolationsTab.dart';

// --- 4. MAIN LAYOUT ---
class MainAppLayout extends StatefulWidget {
  const MainAppLayout({super.key});

  @override
  State<MainAppLayout> createState() => _MainAppLayoutState();
}

class _MainAppLayoutState extends State<MainAppLayout> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    const DashboardTab(),
    const ViolationsTab(), // This is the online one now
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
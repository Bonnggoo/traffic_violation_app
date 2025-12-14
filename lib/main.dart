import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // REQUIRED FOR ONLINE
import 'package:traffic_violation_app/screens/splash_screen.dart'; // REQUIRED FOR DATABASE

// --- 1. INITIALIZATION (ONLINE MODE) ---
void main() async {
  // We must wait for Flutter to wake up before connecting to the internet
  WidgetsFlutterBinding.ensureInitialized();
  
  // Start the connection to Firebase
  await Firebase.initializeApp();

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
          seedColor: const Color(0xFF556B2F),
          primary: const Color(0xFF556B2F),
          secondary: const Color(0xFF8F9779),
          surface: const Color(0xFFF5F5DC),
          onSurface: const Color(0xFF3E3E3E),
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
      home: const SplashScreen(),
    );
  }
}
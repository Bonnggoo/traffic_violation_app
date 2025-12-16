import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart'; // New Package
import 'screens/login_screen.dart'; 
import 'firebase_options.dart'; 

// Background Handler (Must be outside any class)
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 1. Setup Notifications
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  
  // Request permission (Required for Apple, good practice for Android 13+)
  await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  // 2. Get the Device Token (The "Phone Number" for notifications)
  String? token = await messaging.getToken();
  print("📲 My Device Token: $token");

  // 3. Save Token to Database so the Pi knows who to message
  if (token != null) {
    await FirebaseFirestore.instance.collection('settings').doc('admin_phone').set({
      'fcmToken': token,
      'updatedAt': DateTime.now(),
    });
  }

  // 4. Set Background Handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const TrafficApp());
}

class TrafficApp extends StatelessWidget {
  const TrafficApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Traffic Guard',
      theme: ThemeData(
        primaryColor: const Color(0xFF556B2F),
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});
  @override
  Widget build(BuildContext context) {
    // Basic check: If token exists locally (logic depends on your auth setup)
    // For now, we default to LoginScreen for safety
    return const LoginScreen();
  }
}
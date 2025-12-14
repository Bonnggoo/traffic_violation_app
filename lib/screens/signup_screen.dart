import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:traffic_violation_app/screens/main_layout.dart';
import '../main.dart'; // To access MainAppLayout

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // 1. Controllers (Using 'plate' instead of email)
  final _plateController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isLoading = false;

  Future<void> _signUp() async {
    // Hide keyboard
    FocusScope.of(context).unfocus();

    // 1. Basic Validation
    if (_plateController.text.trim().isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a License Plate!"), backgroundColor: Colors.red),
      );
      return;
    }

    if (_passwordController.text.trim() != _confirmPasswordController.text.trim()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match!"), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    // --- THE TRICK: Convert Plate to Email ---
    String plateInput = _plateController.text.trim();
    String hiddenEmail = "$plateInput@traffic.app";

    try {
      // 2. Artificial Delay (Optional, for effect)
      await Future.delayed(const Duration(seconds: 2));

      // 3. Create User in Firebase
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: hiddenEmail,
        password: _passwordController.text.trim(),
      );

      // (Optional) You could save extra profile data to Firestore here if needed later
      
      // 4. Navigate to Home on Success
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainAppLayout()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = "Sign up failed";
      if (e.code == 'weak-password') {
        message = "The password provided is too weak.";
      } else if (e.code == 'email-already-in-use') {
        message = "This License Plate is already registered.";
      } else if (e.code == 'invalid-email') {
        message = "Invalid License Plate format.";
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _plateController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register Vehicle")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Icon(Icons.person_add, size: 80, color: Color(0xFF556B2F)),
              const SizedBox(height: 20),
              
              const Text(
                "Create Account",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF556B2F)),
              ),
              const SizedBox(height: 30),
              
              // License Plate Field
              TextField(
                controller: _plateController,
                decoration: const InputDecoration(
                  labelText: "License Plate Number",
                  hintText: "e.g. 50-TEST",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.directions_car, color: Color(0xFF556B2F)),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 15),
              
              // Password Field
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock, color: Color(0xFF556B2F)),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 15),
              
              // Confirm Password Field
              TextField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Confirm Password",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock_outline, color: Color(0xFF556B2F)),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 30),
              
              // Sign Up Button
              _isLoading
                  ? const CircularProgressIndicator(color: Color(0xFF556B2F))
                  : ElevatedButton(
                      onPressed: _signUp,
                      style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                      child: const Text("Sign Up", style: TextStyle(fontSize: 18)),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
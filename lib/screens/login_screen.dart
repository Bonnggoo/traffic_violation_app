import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // REQUIRED FOR AUTH
import 'package:traffic_violation_app/screens/main_layout.dart';
import '../main.dart'; // To access MainAppLayout
import 'signup_screen.dart'; // To access the Sign Up page

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // 1. Controllers (We use 'plate' instead of email now)
  final _plateController = TextEditingController();
  final _passwordController = TextEditingController();
  
  // Loading state
  bool _isLoading = false;

  // 2. The Login Function
  Future<void> _login() async {
    // Hide keyboard
    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
    });

    // --- THE TRICK: Convert Plate to Email ---
    String plateInput = _plateController.text.trim();
    
    // Check if empty first
    if (plateInput.isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enter a License Plate"), backgroundColor: Colors.red),
       );
       setState(() => _isLoading = false);
       return;
    }

    // Append the fake domain so Firebase accepts it
    String hiddenEmail = "$plateInput@traffic.app"; 

    try {
      // Fake loading delay (2 seconds) for effect
      await Future.delayed(const Duration(seconds: 2)); 

      // Attempt to sign in with Firebase
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: hiddenEmail,
        password: _passwordController.text.trim(),
      );

      // If successful, navigate to Home
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainAppLayout()),
        );
      }
    } on FirebaseAuthException catch (e) {
      // Handle Errors
      String message = "Login failed";
      if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
        message = "License Plate not found or wrong password.";
      } else if (e.code == 'wrong-password') {
        message = "Wrong password provided.";
      } else if (e.code == 'invalid-email') {
        message = "Invalid License Plate format.";
      }
      
      // Show error popup
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${e.toString()}"), backgroundColor: Colors.red),
        );
      }
    } finally {
      // Stop loading spinner
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _plateController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.traffic_rounded, size: 80, color: Color(0xFF556B2F)),
                const SizedBox(height: 20),
                const Text(
                  "Traffic Guard",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF556B2F)),
                ),
                const SizedBox(height: 10),
                const Text("Driver Login", style: TextStyle(color: Colors.grey, fontSize: 16)),
                const SizedBox(height: 40),
                
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
                const SizedBox(height: 30),
                
                // Login Button
                _isLoading 
                  ? const CircularProgressIndicator(color: Color(0xFF556B2F))
                  : ElevatedButton(
                      onPressed: _login, // Call the login function
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text("Login", style: TextStyle(fontSize: 18)),
                    ),
                
                const SizedBox(height: 20),

                // Link to Sign Up Screen
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?"),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SignUpScreen()),
                        );
                      },
                      child: const Text(
                        "Register Plate", 
                        style: TextStyle(color: Color(0xFF556B2F), fontWeight: FontWeight.bold)
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
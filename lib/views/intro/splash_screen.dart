import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:student_sahara_program/views/auth/login_screen.dart';
import 'package:student_sahara_program/views/home/dashboard_screen.dart'; // make sure this path is correct

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  void _checkLoginStatus() async {
    await Future.delayed(const Duration(seconds: 3));

    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // User is logged in
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
    } else {
      // No user logged in
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) =>  LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/icons/mylogo3.png',
              height: 200,
              width: 200,
            ),
            const SizedBox(height: 25),
            Text(
              'Student Sahara Foundation',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 24,
                color: Colors.blue.shade600,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Empowering Students to continue their education',
                textAlign: TextAlign.center,
                style: GoogleFonts.aBeeZee(
                  fontSize: 15,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 50),
            SizedBox(
              width: screenWidth * 0.65,
              child: const LinearProgressIndicator(
                color: Colors.blueAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

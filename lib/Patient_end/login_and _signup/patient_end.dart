import 'package:flutter/material.dart';
import 'patient_login.dart';
import 'patient_signup.dart';

class PatientPage extends StatelessWidget {
  const PatientPage({super.key});

  static const Color appPrimary = Color(0xFF007069);
  static const Color appSecondary = Color(0xFFC5D4E5);
  static const Color appBackground = Color(0xFFFFFFFF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBackground,
      appBar: AppBar(
        title: const Text("Patient Portal"),
        backgroundColor: appPrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person, size: 90, color: appPrimary),

            const SizedBox(height: 40),

            const Text(
              "Welcome Patient",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: appPrimary,
              ),
            ),

            const SizedBox(height: 50),

            // LOGIN BUTTON
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PatientLoginPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: appPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  "LOGIN",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // SIGNUP BUTTON
            SizedBox(
              width: double.infinity,
              height: 55,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PatientSignupPage(),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: appPrimary, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  "SIGN UP",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: appPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
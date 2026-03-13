import 'package:flutter/material.dart';
import 'package:skit_bfb/Patient_end/ambs.dart';
import 'package:skit_bfb/Patient_end/diet_screen.dart';
import 'package:skit_bfb/Patient_end/doc_prescription/first_page.dart';
import 'package:skit_bfb/Patient_end/healthupdates.dart';
import 'package:skit_bfb/Patient_end/take_appointment.dart';
import 'Patient_end/diet_screen.dart';
import 'hosp_end/hosp_end.dart';
import 'Patient_end/patient_end.dart';
import 'admin_end/admin_end.dart';
import 'hosp_list.dart';
void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginGateway(),
        '/hospital': (context) => const HealthUpdatePage(),
        '/patient': (context) => const TakeAppointmentPage(),
        '/admin': (context) => const PatientDietScreen(),
      },
    ),
  );
}

class LoginGateway extends StatelessWidget {
  const LoginGateway({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF007069), Color(0xFFC5D4E5)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.health_and_safety, size: 80, color: Colors.white),
            const SizedBox(height: 50),

            // Major Button: Hospital
            _buildMajorButton(
              context,
              "HOSPITAL LOGIN",
              Icons.local_hospital,
              '/hospital',
            ),
            const SizedBox(height: 20),

            // Major Button: Patient
            _buildMajorButton(
              context,
              "PATIENT LOGIN",
              Icons.person,
              '/patient',
            ),
            const SizedBox(height: 50),

            // Minor Button: Admin
            TextButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/admin'),
              icon: const Icon(Icons.security, color: Colors.white70),
              label: const Text(
                "Admin End",
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMajorButton(
    BuildContext context,
    String label,
    IconData icon,
    String route,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: SizedBox(
        width: double.infinity,
        height: 60,
        child: ElevatedButton.icon(
          onPressed: () => Navigator.pushNamed(context, route),
          icon: Icon(icon),
          label: Text(label),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFFFFF),
            foregroundColor: const Color(0xFF007069),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
// Import your new screens
import 'hosp_end/hosp_end.dart';
import 'Patient_end/patient_end.dart';
import 'admin_end/admin_end.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginGateway(),
        '/hospital': (context) => const HospitalPage(),
        '/patient': (context) => const PatientPage(),
        '/admin': (context) => const AdminPage(),
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
            colors: [Color(0xFF1A237E), Color(0xFF3949AB)],
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
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF1A237E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
      ),
    );
  }
}

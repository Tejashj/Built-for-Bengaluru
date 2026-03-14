import 'package:flutter/material.dart';
import 'package:skit_bfb/Patient_end/chatbot.dart';
import 'package:skit_bfb/Patient_end/voice_agent_page.dart';
import 'dart:ui';
import 'patient_login.dart';
import 'patient_signup.dart';

// Your Dummy Class for the top button
class DummySettingsPage extends StatelessWidget {
  const DummySettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: const Center(child: Text("This is a dummy settings/info page.")),
    );
  }
}

class PatientPage extends StatelessWidget {
  const PatientPage({super.key});

  static const Color appPrimary = Color(0xFF007069);
  static const Color appAccent = Color(0xFF4DB6AC);
  static const Color bgColor = Color(0xFFF0F7F7);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // 1. Organic Background Shapes
          const Positioned.fill(child: _MedicalBackgroundPainter()),

          // 2. Top Navigation Button (The New Addition)
          
          // 3. Main Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 60),
                  
                  // Brand Header
                  _buildHeader(),

                  const Spacer(),

                  // Glassmorphic Action Card
                  _buildActionCard(context),
                  
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  

  // ... rest of your header, card, and button builders remain the same ...
  // (Included below for completeness of the file structure)

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: appPrimary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.health_and_safety_rounded, 
            size: 40, color: appPrimary),
        ),
        const SizedBox(height: 24),
        const Text(
          "MedFlow\nPatient Portal",
          style: TextStyle(
            fontSize: 40,
            height: 1.1,
            fontWeight: FontWeight.w900,
            color: Color(0xFF1A1C1E),
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          "Your health journey starts here.\nSecure, seamless, and smart.",
          style: TextStyle(fontSize: 16, color: Colors.black54, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildActionCard(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.7),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
          ),
          child: Column(
            children: [
              _buildButton(
                label: "SIGN IN",
                isPrimary: true,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PatientLoginPage()),
                ),
              ),
              const SizedBox(height: 16),
              _buildButton(
                label: "CREATE ACCOUNT",
                isPrimary: false,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PatientSignupPage()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton({required String label, required bool isPrimary, required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? appPrimary : Colors.transparent,
          foregroundColor: isPrimary ? Colors.white : appPrimary,
          elevation: isPrimary ? 8 : 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: isPrimary ? BorderSide.none : const BorderSide(color: appPrimary, width: 2),
          ),
        ),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}

// Custom Painter Classes remain unchanged...
class _MedicalBackgroundPainter extends StatelessWidget {
  const _MedicalBackgroundPainter();
  @override
  Widget build(BuildContext context) => CustomPaint(painter: _BlobPainter());
}

class _BlobPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..maskFilter = const MaskFilter.blur(BlurStyle.normal, 50);
    paint.color = const Color(0xFF007069).withOpacity(0.15);
    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.1), 150, paint);
    paint.color = const Color(0xFF4DB6AC).withOpacity(0.1);
    canvas.drawCircle(Offset(size.width * 0.1, size.height * 0.8), 200, paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
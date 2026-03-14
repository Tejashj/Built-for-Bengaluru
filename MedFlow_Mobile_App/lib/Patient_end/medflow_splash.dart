import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:skit_bfb/Patient_end/login_and%20_signup/patient_end.dart';
// Import your patient page file here if it's in another file
// import 'package:your_app/patient_page.dart'; 

class MedFlowLoadingScreen extends StatefulWidget {
  const MedFlowLoadingScreen({super.key});

  @override
  State<MedFlowLoadingScreen> createState() => _MedFlowLoadingScreenState();
}

class _MedFlowLoadingScreenState extends State<MedFlowLoadingScreen>
    with SingleTickerProviderStateMixin {
  // Brand Colors
  static const Color appPrimary = Color(0xFF007069);
  static const Color appSecondary = Color(0xFFC5D4E5);
  static const Color appBackground = Color(0xFFFFFFFF);

  late AnimationController _controller;
  bool _showFinalLogo = false;
  final Random _random = Random();

  final int _elementCount = 35;
  late List<Offset> _startPositions;
  late List<IconData> _shards;

  @override
  void initState() {
    super.initState();

    _startPositions = List.generate(_elementCount, (index) => Offset(
      (_random.nextDouble() * 2 - 1) * 500,
      (_random.nextDouble() * 2 - 1) * 800,
    ));

    _shards = List.generate(_elementCount, (index) => [
      Icons.add_rounded,
      Icons.shield_outlined,
      Icons.health_and_safety_rounded,
      Icons.emergency_rounded,
      Icons.local_pharmacy_outlined
    ][_random.nextInt(5)]);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    // Start animation and trigger navigation sequence
    Timer(const Duration(milliseconds: 200), () {
      _controller.forward().then((_) async {
        setState(() => _showFinalLogo = true);

        // Give the user a moment to see the brand logo (1.5 seconds)
        await Future.delayed(const Duration(milliseconds: 1500));

        if (!mounted) return;

        // Navigate to the PatientPage
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            // Ensure PatientPage() is defined elsewhere as you mentioned
            pageBuilder: (context, animation, secondaryAnimation) => const PatientPage(), 
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBackground,
      body: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [appSecondary.withOpacity(0.2), appBackground],
                radius: 1.5,
              ),
            ),
          ),

          // 1. THE FLYING SHARDS
          if (!_showFinalLogo)
            ...List.generate(_elementCount, (index) => _buildFlyingShard(index)),

          // 2. THE BRAND LOGO & TEXT
          AnimatedOpacity(
            duration: const Duration(milliseconds: 800),
            opacity: _showFinalLogo ? 1.0 : 0.0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Replace with your asset path
                Image.asset(
                  'assets/medflow_app_logo.png', 
                  width: 280,
                  height: 280,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.health_and_safety, 
                    size: 150, 
                    color: appPrimary
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "MedFlow",
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    color: appPrimary,
                    letterSpacing: 3,
                  ),
                ),
              ],
            ),
          ),

          // 3. PROGRESS BAR
          Positioned(
            bottom: 80,
            child: _buildAmbulanceProgress(),
          ),
        ],
      ),
    );
  }

  Widget _buildFlyingShard(int index) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        double t = CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.0, 1.0, curve: Curves.easeInOutExpo),
        ).value;

        return Transform.translate(
          offset: Offset(
            _startPositions[index].dx * (1 - t),
            _startPositions[index].dy * (1 - t),
          ),
          child: Transform.rotate(
            angle: (1 - t) * pi * 2,
            child: Opacity(
              opacity: (1 - t).clamp(0, 1),
              child: Icon(
                _shards[index],
                color: appPrimary.withOpacity(0.4),
                size: 24,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAmbulanceProgress() {
    return Column(
      children: [
        SizedBox(
          width: 250,
          child: Stack(
            children: [
              Container(
                height: 4,
                width: 250,
                decoration: BoxDecoration(
                  color: appSecondary.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Container(
                    height: 4,
                    width: 250 * _controller.value,
                    decoration: BoxDecoration(
                      color: appPrimary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          "Saving Lives, One Second at a Time", 
          style: TextStyle(
            color: appPrimary, 
            fontSize: 13, 
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5
          )
        ),
      ],
    );
  }
}
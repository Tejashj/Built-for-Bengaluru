import 'package:flutter/material.dart';

class EmergencyAmbulancePage extends StatelessWidget {
  static const Color appPrimary = Color(0xFF007069);
  static const Color appSecondary = Color(0xFFC5D4E5);
  static const Color appBackground = Color(0xFFFFFFFF);

  const EmergencyAmbulancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBackground,
      appBar: AppBar(
        title: const Text(
          'Emergency Services',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: appPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            // Location Status Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: appSecondary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: appSecondary),
              ),
              child: Row(
                children: const [
                  Icon(Icons.location_on, color: appPrimary),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Detecting your location...",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: appPrimary,
                      ),
                    ),
                  ),
                  CircularProgressIndicator(strokeWidth: 2, color: appPrimary),
                ],
              ),
            ),

            const Spacer(),

            // Main SOS Button
            GestureDetector(
              onTap: () => _handleEmergencyCall(context),
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  color: appPrimary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: appPrimary.withOpacity(0.4),
                      spreadRadius: 10,
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.medical_services_rounded,
                      size: 60,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "SOS",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),
            const Text(
              "Pressing the button will call the\nnearest ambulance immediately.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),

            const Spacer(),

            // Alternative Manual Options
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.phone),
                    label: const Text("Manual Call"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: appPrimary,
                      side: const BorderSide(color: appPrimary),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: appSecondary,
                      foregroundColor: appPrimary,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: const Text("Hospital Info"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _handleEmergencyCall(BuildContext context) {
    // Logic for geolocation and API call to nearest ambulance would go here
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Emergency Triggered"),
        content: const Text(
          "Connecting to the nearest ambulance and sharing your coordinates...",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

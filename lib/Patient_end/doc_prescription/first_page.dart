import 'package:flutter/material.dart';
import 'camera_page.dart';

class Doctor_Homepage extends StatelessWidget {
  const Doctor_Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Analyse your prescription',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
        backgroundColor: const Color(0xFF007069),
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Color(0xFFC5D4E5),
        ), // This makes the back arrow grey
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        color: Colors.white, // White background
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CameraPage()),
                  );
                },
                icon: const Icon(
                  Icons.camera_alt,
                  size: 30,
                  color: Colors.white, // White icon
                ),
                label: const Text(
                  'Take Photo',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white, // White text
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF007069), // Custom button color
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 4, // Adds subtle shadow to button
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class PatientPage extends StatelessWidget {
  const PatientPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Patient Portal"), backgroundColor: Colors.green),
      body: const Center(child: Text("Welcome to the Patient End")),
    );
  }
}
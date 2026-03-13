import 'package:flutter/material.dart';

class HospitalPage extends StatelessWidget {
  const HospitalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Hospital Portal"), backgroundColor: Colors.blue),
      body: const Center(child: Text("Welcome to the Hospital End")),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PatientDashboard extends StatefulWidget {
  const PatientDashboard({super.key});

  @override
  State<PatientDashboard> createState() => _PatientDashboardState();
}

class _PatientDashboardState extends State<PatientDashboard> {

  final supabase = Supabase.instance.client;

  Map<String, dynamic>? patientData;

  static const Color appPrimary = Color(0xFF007069);
  static const Color appBackground = Color(0xFFFFFFFF);

  @override
  void initState() {
    super.initState();
    loadPatientData();
  }

  Future<void> loadPatientData() async {

    final user = supabase.auth.currentUser;

    if (user == null) return;

    final response = await supabase
        .from('patients')
        .select()
        .eq('id', user.id)
        .single();

    setState(() {
      patientData = response;
    });
  }

  Future<void> logout() async {

    await supabase.auth.signOut();

    if (!mounted) return;

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: appBackground,

      appBar: AppBar(
        title: const Text("Patient Dashboard"),
        backgroundColor: appPrimary,
        actions: [
          IconButton(
            onPressed: logout,
            icon: const Icon(Icons.logout),
          )
        ],
      ),

      body: patientData == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text(
              "Welcome ${patientData!['name']}",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            infoTile("Email", patientData!['email']),
            infoTile("Phone", patientData!['phone']),
            infoTile("Age", patientData!['age'].toString()),
            infoTile("Gender", patientData!['gender']),
            infoTile("Blood Group", patientData!['blood_group']),
            infoTile("City", patientData!['city']),

          ],
        ),
      ),
    );
  }

  Widget infoTile(String label, String value) {

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [

          Text(
            "$label: ",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),

          Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),

        ],
      ),
    );
  }
}
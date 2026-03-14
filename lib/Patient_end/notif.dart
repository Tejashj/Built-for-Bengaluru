import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart'; // Add intl to your pubspec.yaml

class MedicalTrackerPage extends StatefulWidget {
  const MedicalTrackerPage({super.key});

  static const Color appPrimary = Color(0xFF007069);
  static const Color appBg = Color(0xFFF0F4F4);

  @override
  State<MedicalTrackerPage> createState() => _MedicalTrackerPageState();
}

class _MedicalTrackerPageState extends State<MedicalTrackerPage> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> appointments = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAppointments();
  }

  Future<void> _fetchAppointments() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      final data = await supabase
          .from('appointments')
          .select()
          .eq('patient_id', user.id)
          .order('appointment_date', ascending: true);

      setState(() {
        appointments = List<Map<String, dynamic>>.from(data);
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MedicalTrackerPage.appBg,
      appBar: AppBar(
        title: const Text("Medical Tracker", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: MedicalTrackerPage.appPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchAppointments,
        color: MedicalTrackerPage.appPrimary,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader("Upcoming Appointments"),
              const SizedBox(height: 12),
              _buildAppointmentSection(),
              
              const SizedBox(height: 30),
              _buildHeader("Pharmacy Orders"),
              const SizedBox(height: 12),
              _buildPharmacyOrders(),

              const SizedBox(height: 30),
              _buildHeader("Health Alerts"),
              const SizedBox(height: 12),
              _buildHealthAlerts(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18, 
        fontWeight: FontWeight.w800, 
        color: Colors.blueGrey[900],
        letterSpacing: 0.5
      ),
    );
  }

  Widget _buildAppointmentSection() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (appointments.isEmpty) {
      return _buildEmptyState("No appointments found", Icons.event_busy);
    }

    return Column(
      children: appointments.map((apt) => _appointmentCard(apt)).toList(),
    );
  }

  Widget _appointmentCard(Map<String, dynamic> apt) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: MedicalTrackerPage.appPrimary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Icon(Icons.calendar_month, color: MedicalTrackerPage.appPrimary, size: 20),
                const SizedBox(height: 4),
                Text(
                  apt['appointment_date'].toString().split('-')[2].substring(0, 2),
                  style: const TextStyle(fontWeight: FontWeight.bold, color: MedicalTrackerPage.appPrimary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(apt['doctor_name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text("${apt['hospital_name']} • ${apt['department']}", 
                  style: TextStyle(color: Colors.grey[600], fontSize: 13)),
              ],
            ),
          ),
          Text(apt['appointment_time'], 
            style: const TextStyle(fontWeight: FontWeight.w600, color: MedicalTrackerPage.appPrimary)),
        ],
      ),
    );
  }

  Widget _buildPharmacyOrders() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.teal.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          _orderTile("Order #8821", "In Transit", Colors.blue),
          const Divider(height: 25),
          _orderTile("Order #8750", "Delivered", Colors.green),
        ],
      ),
    );
  }

  Widget _orderTile(String id, String status, Color color) {
    return Row(
      children: [
        Icon(Icons.local_shipping_rounded, color: color.withOpacity(0.7)),
        const SizedBox(width: 15),
        Expanded(child: Text(id, style: const TextStyle(fontWeight: FontWeight.w600))),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: Text(status, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
        ),
      ],
    );
  }

  Widget _buildHealthAlerts() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFFFF3E0), Color(0xFFFFF9C4)]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 30),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Vitals Check Reminder", style: TextStyle(fontWeight: FontWeight.bold)),
                Text("It's been 7 days since your last BP update.", style: TextStyle(fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String text, IconData icon) {
    return Center(
      child: Column(
        children: [
          Icon(icon, size: 40, color: Colors.grey[400]),
          const SizedBox(height: 10),
          Text(text, style: TextStyle(color: Colors.grey[500])),
        ],
      ),
    );
  }
}
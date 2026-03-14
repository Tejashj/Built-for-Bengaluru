import 'package:flutter/material.dart';
import 'package:skit_bfb/Patient_end/voice_agent_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TakeAppointmentPage extends StatefulWidget {
  const TakeAppointmentPage({super.key});

  static const Color appPrimary = Color(0xFF007069);
  static const Color appAccent = Color(0xFFE0F2F1);
  static const Color appBackground = Color(0xFFF8F9FA);
  static const Color textDark = Color(0xFF2D3142);

  @override
  State<TakeAppointmentPage> createState() => _TakeAppointmentPageState();
}

class _TakeAppointmentPageState extends State<TakeAppointmentPage> {
  final supabase = Supabase.instance.client;

  String? selectedHospital;
  String? selectedDepartment;
  String? selectedDoctor;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  final TextEditingController reasonController = TextEditingController();

  final List<String> hospitals = ["Apollo Hospital", "Manipal Hospital", "Fortis Hospital"];
  final Map<String, List<String>> departments = {
    "Apollo Hospital": ["Cardiology", "Orthopedics", "Neurology"],
    "Manipal Hospital": ["Dermatology", "ENT", "Cardiology"],
    "Fortis Hospital": ["Neurology", "Orthopedics"]
  };
  final Map<String, List<String>> doctors = {
    "Cardiology": ["Dr. Sharma", "Dr. Patel"],
    "Orthopedics": ["Dr. Rao"],
    "Neurology": ["Dr. Mehta"],
    "Dermatology": ["Dr. Singh"],
    "ENT": ["Dr. Kapoor"]
  };

  // Logic remains identical to your original code
  Future<void> selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      initialDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: TakeAppointmentPage.appPrimary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  Future<void> selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) setState(() => selectedTime = picked);
  }

  Future<void> saveAppointment() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;
    await supabase.from('appointments').insert({
      'patient_id': user.id,
      'hospital_name': selectedHospital,
      'department': selectedDepartment,
      'doctor_name': selectedDoctor,
      'appointment_date': selectedDate.toString(),
      'appointment_time': selectedTime!.format(context),
      'reason': reasonController.text
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Appointment Booked Successfully"),
        backgroundColor: TakeAppointmentPage.appPrimary,
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TakeAppointmentPage.appBackground,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text("New Appointment", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: TakeAppointmentPage.appPrimary,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      
      floatingActionButton: Container(
        height: 70,
        width: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 2)],
        ),
        child: FloatingActionButton(
          backgroundColor: TakeAppointmentPage.appPrimary,
          elevation: 4,
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AIAgentPage())),
          child: const Icon(Icons.mic, size: 35, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader("Hospital Details"),
            _buildCustomDropdown(
              label: "Select Hospital",
              value: selectedHospital,
              icon: Icons.local_hospital,
              items: hospitals,
              onChanged: (val) => setState(() {
                selectedHospital = val;
                selectedDepartment = null;
                selectedDoctor = null;
              }),
            ),
            
            if (selectedHospital != null) ...[
              const SizedBox(height: 15),
              _buildCustomDropdown(
                label: "Select Department",
                value: selectedDepartment,
                icon: Icons.category,
                items: departments[selectedHospital]!,
                onChanged: (val) => setState(() {
                  selectedDepartment = val;
                  selectedDoctor = null;
                }),
              ),
            ],

            if (selectedDepartment != null) ...[
              const SizedBox(height: 15),
              _buildCustomDropdown(
                label: "Select Doctor",
                value: selectedDoctor,
                icon: Icons.person,
                items: doctors[selectedDepartment]!,
                onChanged: (val) => setState(() => selectedDoctor = val),
              ),
            ],

            const SizedBox(height: 30),
            _buildSectionHeader("Schedule & Reason"),
            
            Row(
              children: [
                Expanded(child: _buildDateTimeTile(
                  label: "Date",
                  value: selectedDate == null ? "Pick Date" : selectedDate.toString().split(' ')[0],
                  icon: Icons.calendar_today,
                  onTap: selectDate,
                )),
                const SizedBox(width: 15),
                Expanded(child: _buildDateTimeTile(
                  label: "Time",
                  value: selectedTime == null ? "Pick Time" : selectedTime!.format(context),
                  icon: Icons.access_time,
                  onTap: selectTime,
                )),
              ],
            ),

            const SizedBox(height: 20),
            TextField(
              controller: reasonController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Why are you visiting?",
                labelText: "Reason for Appointment",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: TakeAppointmentPage.appPrimary, width: 2)),
              ),
            ),

            const SizedBox(height: 40),
            _buildConfirmButton(),
            const SizedBox(height: 100), // Safety space for FAB
          ],
        ),
      ),
    );
  }

  // --- UI HELPER COMPONENTS ---

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: TakeAppointmentPage.textDark)),
    );
  }

  Widget _buildCustomDropdown({required String label, required String? value, required IconData icon, required List<String> items, required ValueChanged<String?> onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            icon: Icon(icon, color: TakeAppointmentPage.appPrimary),
            labelText: label,
            border: InputBorder.none,
          ),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildDateTimeTile({required String label, required String value, required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: value.contains("Pick") ? Colors.transparent : TakeAppointmentPage.appPrimary.withOpacity(0.3)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          children: [
            Icon(icon, color: TakeAppointmentPage.appPrimary),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmButton() {
    bool isReady = selectedDoctor != null && selectedDate != null && selectedTime != null;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isReady ? TakeAppointmentPage.appPrimary : Colors.grey.shade400,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: isReady ? 5 : 0,
        ),
        onPressed: isReady ? saveAppointment : null,
        child: const Text("Confirm Appointment", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }
}
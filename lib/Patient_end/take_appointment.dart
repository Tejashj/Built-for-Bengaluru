import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TakeAppointmentPage extends StatefulWidget {
  const TakeAppointmentPage({super.key});

  static const Color appPrimary = Color(0xFF007069);
  static const Color appAccent = Color(0xFFE0F2F1);
  static const Color surface = Color(0xFFFFFFFF);

  @override
  State<TakeAppointmentPage> createState() => _TakeAppointmentPageState();
}

class _TakeAppointmentPageState extends State<TakeAppointmentPage> {
  final supabase = Supabase.instance.client;
  final TextEditingController reasonController = TextEditingController();

  String? selectedHospital;
  String? selectedDepartment;
  String? selectedDoctor;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

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

  int get currentStep {
    if (selectedDoctor != null) return 3;
    if (selectedDepartment != null) return 2;
    if (selectedHospital != null) return 1;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F7),
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text("Appointment Manager", 
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20)),
        backgroundColor: TakeAppointmentPage.appPrimary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildStepIndicator(),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionLabel("Choose Hospital"),
                  _buildHospitalGrid(),
                  
                  if (selectedHospital != null) ...[
                    const SizedBox(height: 25),
                    _buildSectionLabel("Department"),
                    _buildDepartmentChips(),
                  ],

                  if (selectedDepartment != null) ...[
                    const SizedBox(height: 25),
                    _buildSectionLabel("Specialist"),
                    _buildDoctorList(),
                  ],

                  if (selectedDoctor != null) ...[
                    const SizedBox(height: 25),
                    _buildSectionLabel("Select Slot"),
                    _buildDateTimeRow(),
                    const SizedBox(height: 20),
                    _buildReasonInput(),
                    const SizedBox(height: 40),
                    _buildConfirmButton(),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      color: TakeAppointmentPage.appPrimary,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(4, (index) {
          bool isActive = index <= currentStep;
          return Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: isActive ? Colors.white : Colors.white24,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text("${index + 1}", 
                    style: TextStyle(color: isActive ? TakeAppointmentPage.appPrimary : Colors.white70, fontWeight: FontWeight.bold)),
                ),
              ),
              if (index < 3)
                Container(
                  width: 40,
                  height: 2,
                  color: index < currentStep ? Colors.white : Colors.white24,
                ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(text, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey[800])),
    );
  }

  Widget _buildHospitalGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 2,
      ),
      itemCount: hospitals.length,
      itemBuilder: (context, i) {
        bool isSel = selectedHospital == hospitals[i];
        return GestureDetector(
          onTap: () => setState(() {
            selectedHospital = hospitals[i];
            selectedDepartment = null;
            selectedDoctor = null;
          }),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              color: isSel ? TakeAppointmentPage.appPrimary : Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
            ),
            child: Center(
              child: Text(hospitals[i], 
                style: TextStyle(color: isSel ? Colors.white : TakeAppointmentPage.appPrimary, fontWeight: FontWeight.bold)),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDepartmentChips() {
    return Wrap(
      spacing: 8,
      children: departments[selectedHospital!]!.map((dept) {
        bool isSel = selectedDepartment == dept;
        return ChoiceChip(
          label: Text(dept),
          selected: isSel,
          onSelected: (val) => setState(() { selectedDepartment = dept; selectedDoctor = null; }),
          selectedColor: TakeAppointmentPage.appPrimary,
          backgroundColor: Colors.white,
          labelStyle: TextStyle(color: isSel ? Colors.white : Colors.black87, fontWeight: FontWeight.w600),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        );
      }).toList(),
    );
  }

  Widget _buildDoctorList() {
    return Column(
      children: doctors[selectedDepartment!]!.map((doc) {
        bool isSel = selectedDoctor == doc;
        return GestureDetector(
          onTap: () => setState(() => selectedDoctor = doc),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSel ? TakeAppointmentPage.appAccent : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isSel ? TakeAppointmentPage.appPrimary : Colors.transparent, width: 2),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: TakeAppointmentPage.appPrimary,
                  child: const Icon(Icons.person_search, color: Colors.white),
                ),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(doc, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const Text("Availability: 09:00 AM - 05:00 PM", style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
                const Spacer(),
                if (isSel) const Icon(Icons.check_circle, color: TakeAppointmentPage.appPrimary),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDateTimeRow() {
    return Row(
      children: [
        Expanded(child: _buildPickerTile(Icons.calendar_today, selectedDate == null ? "Date" : selectedDate!.toString().split(' ')[0], selectDate)),
        const SizedBox(width: 12),
        Expanded(child: _buildPickerTile(Icons.alarm, selectedTime == null ? "Time" : selectedTime!.format(context), selectTime)),
      ],
    );
  }

  Widget _buildPickerTile(IconData icon, String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
        child: Column(
          children: [
            Icon(icon, color: TakeAppointmentPage.appPrimary),
            const SizedBox(height: 8),
            Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildReasonInput() {
    return TextField(
      controller: reasonController,
      maxLines: 3,
      decoration: InputDecoration(
        hintText: "Reason for visit (optional)...",
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildConfirmButton() {
    bool isEnabled = selectedDate != null && selectedTime != null;
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: isEnabled ? const LinearGradient(colors: [TakeAppointmentPage.appPrimary, Color(0xFF004D40)]) : null,
        color: isEnabled ? null : Colors.grey[400],
        boxShadow: [if(isEnabled) BoxShadow(color: TakeAppointmentPage.appPrimary.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent),
        onPressed: isEnabled ? saveAppointment : null,
        child: const Text("Confirm Appointment", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }

  // Same logic as your original code
  Future<void> selectDate() async {
    final picked = await showDatePicker(context: context, firstDate: DateTime.now(), lastDate: DateTime(2030), initialDate: DateTime.now());
    if (picked != null) setState(() => selectedDate = picked);
  }

  Future<void> selectTime() async {
    final picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
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
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Appointment Booked Successfully"), behavior: SnackBarBehavior.floating));
    Navigator.pop(context);
  }
}
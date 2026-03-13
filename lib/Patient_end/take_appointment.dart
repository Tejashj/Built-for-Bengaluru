import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TakeAppointmentPage extends StatefulWidget {
  const TakeAppointmentPage({super.key});

  static const Color appPrimary = Color(0xFF007069);
  static const Color appBackground = Color(0xFFFFFFFF);

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

  final List<String> hospitals = [
    "Apollo Hospital",
    "Manipal Hospital",
    "Fortis Hospital"
  ];

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

  Future<void> selectDate() async {

    final DateTime? picked = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      initialDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> selectTime() async {

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        selectedTime = picked;
      });
    }
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
      const SnackBar(content: Text("Appointment Booked Successfully")),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: TakeAppointmentPage.appBackground,

      appBar: AppBar(
        title: const Text("Book Appointment"),
        backgroundColor: TakeAppointmentPage.appPrimary,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text("Select Hospital"),
            const SizedBox(height: 8),

            DropdownButtonFormField<String>(
              value: selectedHospital,
              items: hospitals.map((hospital) {
                return DropdownMenuItem(
                  value: hospital,
                  child: Text(hospital),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedHospital = value;
                  selectedDepartment = null;
                  selectedDoctor = null;
                });
              },
            ),

            const SizedBox(height: 20),

            if (selectedHospital != null) ...[

              const Text("Select Department"),
              const SizedBox(height: 8),

              DropdownButtonFormField<String>(
                value: selectedDepartment,
                items: departments[selectedHospital]!
                    .map((dept) => DropdownMenuItem(
                  value: dept,
                  child: Text(dept),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedDepartment = value;
                    selectedDoctor = null;
                  });
                },
              ),
            ],

            const SizedBox(height: 20),

            if (selectedDepartment != null) ...[

              const Text("Select Doctor"),
              const SizedBox(height: 8),

              DropdownButtonFormField<String>(
                value: selectedDoctor,
                items: doctors[selectedDepartment]!
                    .map((doc) => DropdownMenuItem(
                  value: doc,
                  child: Text(doc),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedDoctor = value;
                  });
                },
              ),
            ],

            const SizedBox(height: 20),

            if (selectedDoctor != null) ...[

              Row(
                children: [

                  Expanded(
                    child: ElevatedButton(
                      onPressed: selectDate,
                      child: Text(
                        selectedDate == null
                            ? "Select Date"
                            : selectedDate.toString().split(' ')[0],
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: ElevatedButton(
                      onPressed: selectTime,
                      child: Text(
                        selectedTime == null
                            ? "Select Time"
                            : selectedTime!.format(context),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              TextField(
                controller: reasonController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Reason for Appointment",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 50,

                child: ElevatedButton(

                  style: ElevatedButton.styleFrom(
                    backgroundColor: TakeAppointmentPage.appPrimary,
                  ),

                  onPressed: saveAppointment,

                  child: const Text(
                    "Confirm Appointment",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              )
            ]
          ],
        ),
      ),
    );
  }
}
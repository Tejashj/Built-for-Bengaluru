import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TakeAppointmentPage extends StatefulWidget {
  const TakeAppointmentPage({super.key});

  // Your custom color palette
  static const Color appPrimary = Color(0xFF007069);
  static const Color appSecondary = Color(0xFFC5D4E5);
  static const Color appBackground = Color(0xFFFFFFFF);

  @override
  State<TakeAppointmentPage> createState() => _TakeAppointmentPageState();
}

class _TakeAppointmentPageState extends State<TakeAppointmentPage> {
  final TextEditingController _nameController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
      // Theming the picker to match app colors
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: TakeAppointmentPage.appPrimary),
        ),
        child: child!,
      ),
    );
    if (pickedDate != null) setState(() => _selectedDate = pickedDate);
  }

  Future<void> _pickTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: TakeAppointmentPage.appPrimary),
        ),
        child: child!,
      ),
    );
    if (pickedTime != null) setState(() => _selectedTime = pickedTime);
  }

  Future<void> _bookAppointment() async {
    if (_nameController.text.isEmpty || _selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter name, date, and time')),
      );
      return;
    }

    try {
      final appointmentDateTime = DateTime(
        _selectedDate!.year, _selectedDate!.month, _selectedDate!.day,
        _selectedTime!.hour, _selectedTime!.minute,
      );

      await Supabase.instance.client.from('user_data').insert({
        'name': _nameController.text,
        'time': appointmentDateTime.toIso8601String(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(backgroundColor: TakeAppointmentPage.appPrimary, content: Text('Appointment booked!')),
      );

      _nameController.clear();
      setState(() {
        _selectedDate = null;
        _selectedTime = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TakeAppointmentPage.appBackground,
      appBar: AppBar(
        title: const Text('Book Appointment', style: TextStyle(color: Colors.white)),
        backgroundColor: TakeAppointmentPage.appPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Schedule your visit",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: TakeAppointmentPage.appPrimary),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Full Name',
                labelStyle: const TextStyle(color: TakeAppointmentPage.appPrimary),
                filled: true,
                fillColor: TakeAppointmentPage.appSecondary.withOpacity(0.2),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: TakeAppointmentPage.appPrimary, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildSelectionTile(
              icon: Icons.calendar_today,
              label: _selectedDate == null 
                  ? 'Select Date' 
                  : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
              onTap: _pickDate,
            ),
            const SizedBox(height: 12),
            _buildSelectionTile(
              icon: Icons.access_time,
              label: _selectedTime == null 
                  ? 'Select Time' 
                  : _selectedTime!.format(context),
              onTap: _pickTime,
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _bookAppointment,
              style: ElevatedButton.styleFrom(
                backgroundColor: TakeAppointmentPage.appPrimary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Text('Confirm Appointment', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget to keep the UI clean
  Widget _buildSelectionTile({required IconData icon, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: TakeAppointmentPage.appSecondary.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: TakeAppointmentPage.appPrimary),
            const SizedBox(width: 15),
            Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
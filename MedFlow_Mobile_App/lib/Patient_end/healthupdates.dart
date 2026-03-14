import 'package:flutter/material.dart';

class HealthUpdatePage extends StatefulWidget {
  const HealthUpdatePage({super.key});

  static const Color appPrimary = Color(0xFF007069);
  static const Color appSecondary = Color(0xFFC5D4E5);
  static const Color appBackground = Color(0xFFFFFFFF);

  @override
  State<HealthUpdatePage> createState() => _HealthUpdatePageState();
}

class _HealthUpdatePageState extends State<HealthUpdatePage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _sysController = TextEditingController();
  final TextEditingController _diaController = TextEditingController();
  final TextEditingController _heartRateController = TextEditingController();
  final TextEditingController _spo2Controller = TextEditingController();
  final TextEditingController _glucoseController = TextEditingController();
  final TextEditingController _geneticNotesController = TextEditingController();

  // Genetic Disease Selection
  final Map<String, bool> _geneticConditions = {
    "Diabetes": false,
    "Hypertension": false,
    "Heart Disease": false,
    "Cancer History": false,
    "Asthma": false,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HealthUpdatePage.appBackground,
      appBar: AppBar(
        title: const Text('Advanced Health Profile', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: HealthUpdatePage.appPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader("Current Physiological Data", Icons.analytics_outlined),
              const SizedBox(height: 15),
              
              // Row 1: Weight & Height
              Row(
                children: [
                  Expanded(child: _buildNumericField(_weightController, "Weight", "kg", 30, 250)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildNumericField(_heightController, "Height", "cm", 50, 250)),
                ],
              ),
              const SizedBox(height: 15),

              // Row 2: Blood Pressure
              Row(
                children: [
                  Expanded(child: _buildNumericField(_sysController, "Systolic", "mmHg", 70, 200)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildNumericField(_diaController, "Diastolic", "mmHg", 40, 130)),
                ],
              ),
              const SizedBox(height: 15),

              // Row 3: Heart Rate & SpO2
              Row(
                children: [
                  Expanded(child: _buildNumericField(_heartRateController, "Heart Rate", "bpm", 40, 200)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildNumericField(_spo2Controller, "SpO2", "%", 70, 100)),
                ],
              ),
              const SizedBox(height: 15),

              // Blood Sugar
              _buildNumericField(_glucoseController, "Blood Glucose (Fasting)", "mg/dL", 50, 500),

              const SizedBox(height: 30),
              _buildSectionHeader("Genetic / Ancestral Risks", Icons.family_restroom),
              const SizedBox(height: 10),
              const Text("Select conditions present in your direct lineage:", 
                style: TextStyle(color: Colors.grey, fontSize: 13)),
              const SizedBox(height: 10),

              // Chips for Genetic Selection
              Wrap(
                spacing: 8.0,
                children: _geneticConditions.keys.map((String key) {
                  return FilterChip(
                    label: Text(key),
                    selected: _geneticConditions[key]!,
                    onSelected: (bool value) {
                      setState(() { _geneticConditions[key] = value; });
                    },
                    selectedColor: HealthUpdatePage.appSecondary,
                    checkmarkColor: HealthUpdatePage.appPrimary,
                  );
                }).toList(),
              ),

              const SizedBox(height: 15),
              _buildTextArea(_geneticNotesController, "Detailed Ancestral Notes"),

              const SizedBox(height: 40),
              _buildSubmitButton(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: HealthUpdatePage.appPrimary, size: 28),
        const SizedBox(width: 10),
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: HealthUpdatePage.appPrimary)),
      ],
    );
  }

  Widget _buildNumericField(TextEditingController controller, String label, String unit, double min, double max) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: "$label ($unit)",
        labelStyle: const TextStyle(color: HealthUpdatePage.appPrimary),
        filled: true,
        fillColor: HealthUpdatePage.appSecondary.withOpacity(0.1),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: HealthUpdatePage.appSecondary), borderRadius: BorderRadius.circular(10)),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Required';
        final n = num.tryParse(value);
        if (n == null || n < min || n > max) return 'Invalid range';
        return null;
      },
    );
  }

  Widget _buildTextArea(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      maxLines: 3,
      decoration: InputDecoration(
        labelText: label,
        alignLabelWithHint: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: HealthUpdatePage.appPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            // Log logic here
          }
        },
        child: const Text("Save Health Data", style: TextStyle(color: Colors.white, fontSize: 18)),
      ),
    );
  }
}
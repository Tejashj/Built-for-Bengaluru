import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PatientSignupPage extends StatefulWidget {
  const PatientSignupPage({super.key});

  @override
  State<PatientSignupPage> createState() => _PatientSignupPageState();
}

class _PatientSignupPageState extends State<PatientSignupPage> {
  final PageController pageController = PageController();
  int _currentPage = 0;

  // Controllers
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final cityController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  String? gender;
  String? bloodGroup;
  bool isLoading = false;
  bool _obscurePassword = true;

  static const Color appPrimary = Color(0xFF007069);
  static const Color accentColor = Color(0xFFE0F2F1);

  final List<String> genders = ["Male", "Female", "Other"];
  final List<String> bloodGroups = ["A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-"];

  void _nextPage() {
    pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _previousPage() {
    pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> signupPatient() async {
    setState(() => isLoading = true);
    final supabase = Supabase.instance.client;

    try {
      final auth = await supabase.auth.signUp(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (auth.user == null) throw Exception("Signup failed.");

      await supabase.from('patients').insert({
        'id': auth.user!.id,
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'phone': phoneController.text.trim(),
        'age': int.tryParse(ageController.text.trim()),
        'gender': gender,
        'blood_group': bloodGroup,
        'city': cityController.text.trim(),
      });

      if (!mounted) return;
      Navigator.pop(context);
      _showSnackBar("Account Created Successfully!", Colors.green);
    } catch (e) {
      _showSnackBar(e.toString(), Colors.redAccent);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color, behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appPrimary,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: PageView(
                  controller: pageController,
                  onPageChanged: (index) => setState(() => _currentPage = index),
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildStepOne(),
                    _buildStepTwo(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              const Text(
                "Create Account",
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Step Indicator
          Row(
            children: [
              _stepIndicator("Personal", 0),
              const Expanded(child: Divider(color: Colors.white38, thickness: 1)),
              _stepIndicator("Security", 1),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stepIndicator(String label, int index) {
    bool isActive = _currentPage >= index;
    return Column(
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: isActive ? Colors.white : Colors.white24,
          child: Text("${index + 1}", 
            style: TextStyle(color: isActive ? appPrimary : Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }

  Widget _buildStepOne() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(30),
      child: Column(
        children: [
          _buildInput(nameController, "Full Name", Icons.person_outline),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(child: _buildInput(ageController, "Age", Icons.calendar_today_outlined, isNumber: true)),
              const SizedBox(width: 15),
              Expanded(child: _buildDropdown(gender, genders, "Gender", (val) => setState(() => gender = val))),
            ],
          ),
          const SizedBox(height: 15),
          _buildDropdown(bloodGroup, bloodGroups, "Blood Group", (val) => setState(() => bloodGroup = val)),
          const SizedBox(height: 15),
          _buildInput(cityController, "City", Icons.location_city_outlined),
          const SizedBox(height: 40),
          _buildActionButton("NEXT", _nextPage),
        ],
      ),
    );
  }

  Widget _buildStepTwo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(30),
      child: Column(
        children: [
          _buildInput(emailController, "Email Address", Icons.email_outlined),
          const SizedBox(height: 15),
          _buildInput(phoneController, "Phone Number", Icons.phone_android_outlined, isNumber: true),
          const SizedBox(height: 15),
          _buildInput(
            passwordController, 
            "Create Password", 
            Icons.lock_outline, 
            isPassword: true,
            suffix: IconButton(
              icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
          const SizedBox(height: 40),
          _buildActionButton(isLoading ? "CREATING..." : "COMPLETE SIGNUP", signupPatient, isPrimary: true),
          TextButton(onPressed: _previousPage, child: const Text("Go Back", style: TextStyle(color: Colors.grey))),
        ],
      ),
    );
  }

  Widget _buildInput(TextEditingController controller, String label, IconData icon, {bool isNumber = false, bool isPassword = false, Widget? suffix}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      obscureText: isPassword ? _obscurePassword : false,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: appPrimary),
        suffixIcon: suffix,
        filled: true,
        fillColor: accentColor.withOpacity(0.2),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildDropdown(String? value, List<String> items, String label, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: accentColor.withOpacity(0.2),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildActionButton(String label, VoidCallback onPressed, {bool isPrimary = true}) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: appPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 2,
        ),
        onPressed: isLoading ? null : onPressed,
        child: isLoading && isPrimary 
          ? const CircularProgressIndicator(color: Colors.white) 
          : Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
      ),
    );
  }
}
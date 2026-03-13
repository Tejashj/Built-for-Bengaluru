import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PatientSignupPage extends StatefulWidget {
  const PatientSignupPage({super.key});

  @override
  State<PatientSignupPage> createState() => _PatientSignupPageState();
}

class _PatientSignupPageState extends State<PatientSignupPage> {

  final PageController pageController = PageController();

  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final cityController = TextEditingController();

  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  String? gender;
  String? bloodGroup;

  bool isLoading = false;

  static const Color appPrimary = Color(0xFF007069);

  final List<String> genders = ["Male", "Female", "Other"];

  final List<String> bloodGroups = [
    "A+","A-","B+","B-","AB+","AB-","O+","O-"
  ];

  Future<void> signupPatient() async {

    final supabase = Supabase.instance.client;

    setState(() {
      isLoading = true;
    });

    try {

      print("Signup started");

      final auth = await supabase.auth.signUp(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final user = auth.user;

      if (user == null) {
        throw Exception("Signup failed. Email confirmation may be enabled.");
      }

      print("User created: ${user.id}");

      await supabase.from('patients').insert({
        'id': user.id,
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'phone': phoneController.text.trim(),
        'age': int.tryParse(ageController.text.trim()),
        'gender': gender,
        'blood_group': bloodGroup,
        'city': cityController.text.trim(),
      });

      print("Patient inserted");

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Signup Successful")),
      );

      Navigator.pop(context);

    } catch (e) {

      print("Signup error: $e");

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );

    } finally {

      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }

    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Patient Signup"),
        backgroundColor: appPrimary,
      ),

      body: PageView(
        controller: pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [

          /// PAGE 1 – PERSONAL INFO
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [

                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Name"),
                ),

                const SizedBox(height: 15),

                TextField(
                  controller: ageController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Age"),
                ),

                const SizedBox(height: 15),

                DropdownButtonFormField<String>(
                  value: gender,
                  decoration: const InputDecoration(labelText: "Gender"),
                  items: genders.map((g) {
                    return DropdownMenuItem(
                      value: g,
                      child: Text(g),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      gender = value;
                    });
                  },
                ),

                const SizedBox(height: 15),

                DropdownButtonFormField<String>(
                  value: bloodGroup,
                  decoration: const InputDecoration(labelText: "Blood Group"),
                  items: bloodGroups.map((b) {
                    return DropdownMenuItem(
                      value: b,
                      child: Text(b),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      bloodGroup = value;
                    });
                  },
                ),

                const SizedBox(height: 15),

                TextField(
                  controller: cityController,
                  decoration: const InputDecoration(labelText: "City"),
                ),

                const Spacer(),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: appPrimary,
                    ),
                    onPressed: () {
                      pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.ease,
                      );
                    },
                    child: const Text("NEXT"),
                  ),
                )

              ],
            ),
          ),

          /// PAGE 2 – ACCOUNT INFO
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [

                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: "Email"),
                ),

                const SizedBox(height: 15),

                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: "Phone"),
                ),

                const SizedBox(height: 15),

                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: "Password"),
                ),

                const Spacer(),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: appPrimary,
                    ),
                    onPressed: isLoading ? null : signupPatient,
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("SIGN UP"),
                  ),
                )

              ],
            ),
          )

        ],
      ),
    );
  }
}
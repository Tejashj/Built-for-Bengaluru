import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:ui';

class PatientDashboard extends StatefulWidget {
  const PatientDashboard({super.key});

  @override
  State<PatientDashboard> createState() => _PatientDashboardState();
}

class _PatientDashboardState extends State<PatientDashboard> {
  final supabase = Supabase.instance.client;
  Map<String, dynamic>? patientData;

  // Refined Color Palette
  static const Color appPrimary = Color(0xFF007069);
  static const Color appSurface = Color(0xFFFFFFFF);
  static const Color appBg = Color(0xFFF0F4F4); // Medical soft grey-blue
  static const Color appTextDark = Color(0xFF1A1C1E);

  @override
  void initState() {
    super.initState();
    loadPatientData();
  }

  Future<void> loadPatientData() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      final response = await supabase
          .from('patients')
          .select()
          .eq('id', user.id)
          .single();

      setState(() {
        patientData = response;
      });
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  Future<void> logout() async {
    await supabase.auth.signOut();
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBg,
      body: patientData == null
          ? const Center(child: CircularProgressIndicator(color: appPrimary))
          : CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildModernAppBar(),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionHeader("Medical Summary"),
                        const SizedBox(height: 15),
                        
                        // Horizontal Vitals Strip
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            children: [
                              _vialChip("Age", "${patientData!['age']} yrs", Icons.event),
                              _vialChip("Blood", patientData!['blood_group'], Icons.water_drop),
                              _vialChip("Gender", patientData!['gender'], Icons.wc),
                              _vialChip("Weight", "72 kg", Icons.monitor_weight), // Placeholder for future data
                            ],
                          ),
                        ),

                        const SizedBox(height: 35),
                        _sectionHeader("Personal Details"),
                        const SizedBox(height: 15),

                        // Grouped Info Container
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: appSurface,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              )
                            ],
                          ),
                          child: Column(
                            children: [
                              _infoRow(Icons.alternate_email_rounded, "Email Address", patientData!['email']),
                              _divider(),
                              _infoRow(Icons.phone_iphone_rounded, "Contact Number", patientData!['phone']),
                              _divider(),
                              _infoRow(Icons.map_rounded, "Residential City", patientData!['city']),
                            ],
                          ),
                        ),

                        const SizedBox(height: 40),
                        
                        // Styled Logout Button
                        _buildLogoutButton(),
                        const SizedBox(height: 50),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildModernAppBar() {
    return SliverAppBar(
      expandedHeight: 260,
      pinned: true,
      stretch: true,
      backgroundColor: appPrimary,
      elevation: 0,
      actions: [
        IconButton(
          onPressed: () {}, // Future: Edit Profile
          icon: const Icon(Icons.edit_note_rounded, color: Colors.white),
        )
      ],
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground, StretchMode.blurBackground],
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Abstract Background Pattern
            Positioned(
              right: -50, top: -50,
              child: CircleAvatar(radius: 120, backgroundColor: Colors.white.withOpacity(0.05)),
            ),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [appPrimary, Color(0xFF004D40)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  Hero(
                    tag: 'profile_pic',
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
                      child: const CircleAvatar(
                        radius: 45,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person_rounded, size: 55, color: appPrimary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    patientData!['name'],
                    style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: -0.5),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(20)),
                    child: Text(
                      "PATIENT ID: #${patientData!['id'].toString().substring(0, 8).toUpperCase()}",
                      style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _vialChip(String label, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      width: 110,
      decoration: BoxDecoration(
        color: appSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: appPrimary, size: 20),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: appTextDark)),
          Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF007069).withOpacity(0.6), size: 22),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: Colors.grey.shade500, fontSize: 11, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: appTextDark)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Colors.black12),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(color: Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.5),
    );
  }

  Widget _divider() => Divider(height: 1, indent: 55, color: Colors.grey.shade100);

  Widget _buildLogoutButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(colors: [Colors.red.shade50, const Color(0xFFFFF5F5)]),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: logout,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.power_settings_new_rounded, color: const Color(0xFF007069), size: 20),
                const SizedBox(width: 10),
                Text(
                  "Sign Out Securely",
                  style: TextStyle(color: const Color(0xFF007069), fontWeight: FontWeight.w800, fontSize: 15),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
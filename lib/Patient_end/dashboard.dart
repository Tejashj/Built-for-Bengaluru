import 'package:flutter/material.dart';
import 'package:skit_bfb/Patient_end/ambs.dart';
import 'package:skit_bfb/Patient_end/blockchain/bc_list.dart';
import 'package:skit_bfb/Patient_end/chatbot.dart';
import 'package:skit_bfb/Patient_end/doc_prescription/first_page.dart';
import 'package:skit_bfb/Patient_end/healthupdates.dart';
import 'package:skit_bfb/Patient_end/patient_data.dart';
import 'package:skit_bfb/Patient_end/sos.dart';
import 'package:skit_bfb/Patient_end/take_appointment.dart';
import 'package:skit_bfb/hosp_list.dart';

// --- NAVIGATION LOGIC ---
// Helper to navigate to specific pages
void _navigateTo(BuildContext context, Widget page) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => page),
  );
}

class MedicalDashboard extends StatefulWidget {
  const MedicalDashboard({super.key});

  @override
  State<MedicalDashboard> createState() => _MedicalDashboardState();
}

class _MedicalDashboardState extends State<MedicalDashboard> {
  static const Color appPrimary = Color(0xFF007069);
  static const Color appSecondary = Color(0xFFC5D4E5);
  static const Color appBackground = Color(0xFFFFFFFF);

  final ScrollController _scrollController = ScrollController();

  // Updated categories with their respective Page Classes
  final List<Map<String, dynamic>> categories = [
    {"title": "Ambulance", "icon": Icons.airport_shuttle_rounded, "page": const EmergencyAmbulancePage()},
    {"title": "Hospitals", "icon": Icons.local_hospital_rounded, "page": const HospitalMapPage()},
    {"title": "Pharmacy", "icon": Icons.medical_information_rounded, "page": const MedicalChatbotPage()},
    {"title": "Doctors", "icon": Icons.person_search_rounded, "page": const TakeAppointmentPage()},
    {"title": "Blood Bank", "icon": Icons.bloodtype_rounded, "page": const Sos()},
    {"title": "Update Health Status", "icon": Icons.biotech_rounded, "page": const HealthUpdatePage()},
    {"title": "Insurance", "icon": Icons.verified_user_rounded, "page": const PatientDashboard()},
    {"title": "Doctor Prescription", "icon": Icons.medical_services_rounded, "page": const Doctor_Homepage()},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBackground,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: appPrimary,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  Positioned(top: -50, right: -50, child: _circle(200)),
                  Positioned(bottom: 20, left: -30, child: _circle(100)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 40),
                        const Text("Welcome back,", style: TextStyle(color: appSecondary, fontSize: 16)),
                        const Text("Health Explorer", 
                          style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 15),
                        _buildSearchBar(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: AnimatedBuilder(
              animation: _scrollController,
              builder: (context, child) {
                return SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 20,
                    childAspectRatio: 1.1,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return _buildEnhancedButton(context, index);
                    },
                    childCount: categories.length,
                  ),
                );
              },
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 50)),
        ],
      ),
    );
  }

  Widget _buildEnhancedButton(BuildContext context, int index) {
    // Proximity logic for pair highlighting (Visual feedback on scroll)
    double itemPosition = 0.0;
    try {
      final RenderBox box = context.findRenderObject() as RenderBox;
      itemPosition = box.localToGlobal(Offset.zero).dy;
    } catch (_) {}
    double screenCenter = MediaQuery.of(context).size.height / 2;
    bool isHighlighted = (itemPosition - screenCenter).abs() < 160;

    final category = categories[index];

    return AnimatedScale(
      scale: isHighlighted ? 1.05 : 1.0,
      duration: const Duration(milliseconds: 300),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: isHighlighted ? appPrimary : appBackground,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: isHighlighted ? appPrimary : appSecondary.withOpacity(0.6),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isHighlighted ? appPrimary.withOpacity(0.4) : Colors.black12,
              blurRadius: isHighlighted ? 20 : 8,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: InkWell(
          onTap: () => _navigateTo(context, category['page']),
          borderRadius: BorderRadius.circular(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: isHighlighted ? Colors.white.withOpacity(0.2) : appSecondary.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(category['icon'], color: isHighlighted ? Colors.white : appPrimary, size: 32),
              ),
              const SizedBox(height: 12),
              Text(
                category['title'],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: isHighlighted ? Colors.white : appPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Row(
        children: [
          Icon(Icons.search, color: Colors.white70),
          SizedBox(width: 10),
          Text("Search services...", style: TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _circle(double size) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle),
    );
  }
}

// --- BASE PAGE TEMPLATE ---
// This ensures all 10 pages have a premium, consistent look
class CategoryBasePage extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget content;

  const CategoryBasePage({super.key, required this.title, required this.icon, required this.content});

  @override
  Widget build(BuildContext context) {
    const Color appPrimary = Color(0xFF007069);
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: appPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: appPrimary.withOpacity(0.2)),
            const SizedBox(height: 20),
            Text("$title Services", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: appPrimary)),
            const Padding(
              padding: EdgeInsets.all(30.0),
              child: Text("This section will list all available services nearby.", textAlign: TextAlign.center),
            ),
            content,
          ],
        ),
      ),
    );
  }
}


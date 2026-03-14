import 'dart:convert';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:skit_bfb/Patient_end/notif.dart';
import 'package:url_launcher/url_launcher.dart';

// Your existing project imports - Ensure these paths are correct in your project
import 'package:skit_bfb/Patient_end/Pharmacy.dart';
import 'package:skit_bfb/Patient_end/ambs.dart';
import 'package:skit_bfb/Patient_end/chatbot.dart';
import 'package:skit_bfb/Patient_end/doc_prescription/first_page.dart';
import 'package:skit_bfb/Patient_end/healthupdates.dart';
import 'package:skit_bfb/Patient_end/patient_data.dart'; // This is your PatientDashboard
import 'package:skit_bfb/Patient_end/precaution.dart';
import 'package:skit_bfb/Patient_end/sos.dart';
import 'package:skit_bfb/Patient_end/take_appointment.dart';
import 'package:skit_bfb/hosp_list.dart';

class MedicalDashboard extends StatefulWidget {
  const MedicalDashboard({super.key});

  @override
  State<MedicalDashboard> createState() => _MedicalDashboardState();
}

class _MedicalDashboardState extends State<MedicalDashboard> with SingleTickerProviderStateMixin {
  static const Color appPrimary = Color(0xFF007069);
  static const Color appSecondary = Color(0xFFC5D4E5);
  static const Color appBackground = Color(0xFFFFFFFF);

  final ScrollController _scrollController = ScrollController();
  late AnimationController _animationController;

  String _newsTitle = "Fetching live health advisories...";
  String _newsUrl = "https://news.google.com";
  bool _isLoadingNews = true;

  final List<Map<String, dynamic>> categories = [
    {"title": "Ambulance", "icon": Icons.airport_shuttle_rounded, "page": const EmergencyAmbulancePage()},
    {"title": "Hospitals", "icon": Icons.local_hospital_rounded, "page": const HospitalMapPage()},
    {"title": "Doctors", "icon": Icons.person_search_rounded, "page": const TakeAppointmentPage()},
    {"title": "Precautions & News", "icon": Icons.newspaper_rounded, "page": const PrecautionNewsPage()},
    {"title": "Pharmacy", "icon": Icons.medical_information_rounded, "page": const SmartPharmacyPage()},
    {"title": "Update Health Status", "icon": Icons.biotech_rounded, "page": const HealthUpdatePage()},
    {"title": "Blood Bank", "icon": Icons.bloodtype_rounded, "page": const Sos()},
    {"title": "Doctor Prescription", "icon": Icons.medical_services_rounded, "page": const PrescriptionScanner()},
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _fetchDynamicNews();
  }

  Future<void> _fetchDynamicNews() async {
    setState(() => _isLoadingNews = true);
    try {
      const String apiKey = "9dd561daf77c43c59cdfb8be20ddd2e1"; 
      const String url = 'https://newsapi.org/v2/top-headlines?category=health&country=in';

      final response = await http.get(
        Uri.parse(url),
        headers: {'X-Api-Key': apiKey},
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['articles'] != null && data['articles'].isNotEmpty) {
          final articles = data['articles'];
          final randomIdx = Random().nextInt(min(articles.length as int, 5));
          final article = articles[randomIdx];

          setState(() {
            _newsTitle = article['title'] ?? "New health alert issued.";
            _newsUrl = article['url'] ?? "https://news.google.com";
            _isLoadingNews = false;
          });
        } else { _handleNewsError(); }
      } else { _handleNewsError(); }
    } catch (e) { _handleNewsError(); }
  }

  void _handleNewsError() {
    if (mounted) {
      setState(() {
        _newsTitle = "Advisory: High Pollen Count in your area – Allergy Precaution Recommended.";
        _newsUrl = "https://www.google.com";
        _isLoadingNews = false;
      });
    }
  }

  Future<void> _launchUrl() async {
    final Uri url = Uri.parse(_newsUrl);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Could not open news source.")));
    }
  }

  void _navigateTo(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

  Widget _circle(double size) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle),
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
          Text("Search health services...", style: TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildDynamicHeroCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal.shade50, Colors.teal.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: appPrimary.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(color: appPrimary.withOpacity(0.1), blurRadius: 12, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: _isLoadingNews 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: appPrimary))
                  : const Icon(Icons.notifications_active_rounded, color: appPrimary, size: 24),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("LIVE HEALTH ADVISORY", 
                      style: TextStyle(fontWeight: FontWeight.bold, color: appPrimary, fontSize: 10, letterSpacing: 1.2)),
                    const SizedBox(height: 4),
                    Text(
                      _newsTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w600, height: 1.3),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _launchUrl,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text("Read Full Story", style: TextStyle(color: appPrimary, fontWeight: FontWeight.bold, fontSize: 13)),
                SizedBox(width: 4),
                Icon(Icons.arrow_right_alt_rounded, size: 18, color: appPrimary),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildEnhancedButton(BuildContext context, int index) {
    final category = categories[index];
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: appBackground,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: appSecondary.withOpacity(0.5), width: 1.2),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 8))],
      ),
      child: InkWell(
        onTap: () => _navigateTo(context, category['page']),
        borderRadius: BorderRadius.circular(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: appSecondary.withOpacity(0.2), shape: BoxShape.circle),
              child: Icon(category['icon'], color: appPrimary, size: 30),
            ),
            const SizedBox(height: 10),
            Text(category['title'], textAlign: TextAlign.center, 
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: appPrimary)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBackground,
      floatingActionButton: ScaleTransition(
        scale: Tween(begin: 1.0, end: 1.15).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut)),
        child: FloatingActionButton(
          backgroundColor: appPrimary,
          onPressed: () => _navigateTo(context, const ModernMedicalChatbot()),
          child: const Icon(Icons.forum_rounded, color: Colors.white),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchDynamicNews,
        color: appPrimary,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverAppBar(
              expandedHeight: 220,
              pinned: true,
              elevation: 0,
              backgroundColor: appPrimary,
              // --- ACTIONS: NOTIFICATION BELL AND PROFILE ---
              actions: [
                IconButton(
                  onPressed: () => _navigateTo(context, const MedicalTrackerPage()),
                  icon: Stack(
                    children: [
                      const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 26),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
                          constraints: const BoxConstraints(minWidth: 8, minHeight: 8),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 12, left: 4),
                  child: IconButton(
                    onPressed: () => _navigateTo(context, const PatientDashboard()),
                    icon: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white38, width: 1.5),
                        shape: BoxShape.circle,
                      ),
                      child: const CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.white24,
                        child: Icon(Icons.person_rounded, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ),
              ],
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
                          const Text("Hello,", style: TextStyle(color: appSecondary, fontSize: 16)),
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
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: 15),
                  _buildDynamicHeroCard(),
                  const SizedBox(height: 5),
                ],
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                  childAspectRatio: 1.1,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildEnhancedButton(context, index),
                  childCount: categories.length,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}


import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PrecautionNewsPage extends StatefulWidget {
  const PrecautionNewsPage({super.key});

  @override
  State<PrecautionNewsPage> createState() => _PrecautionNewsPageState();
}

class _PrecautionNewsPageState extends State<PrecautionNewsPage> {
  static const Color appPrimary = Color(0xFF007069);
  
  // Controller for the search bar
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = "All";
  String _searchQuery = "";

  final List<Map<String, String>> newsItems = [
    {
      "title": "New Protocol for Seasonal Flu",
      "date": "Feb 24, 2026",
      "desc": "Authorities recommend updated masking in crowded public transport due to rising cases.",
      "category": "Advisory"
    },
    {
      "title": "Hydration Guidelines: Heatwave",
      "date": "Feb 22, 2026",
      "desc": "Upcoming summer safety measures include mandatory cooling breaks for outdoor workers.",
      "category": "Safety"
    },
    {
      "title": "Vaccination Drive 2.0",
      "date": "Feb 20, 2026",
      "desc": "Precautionary booster shots will be available at all local clinics starting next Monday.",
      "category": "Health"
    },
    {
      "title": "International Travel Safety",
      "date": "Feb 18, 2026",
      "desc": "New guidelines for travelers arriving from tropical regions. Screening at Terminal 3.",
      "category": "Travel"
    },
    {
      "title": "Dengue Prevention Notice",
      "date": "Feb 15, 2026",
      "desc": "Municipal health departments advise clearing stagnant water to prevent mosquito breeding.",
      "category": "Health"
    },
    {
      "title": "Workplace Ergonomics Alert",
      "date": "Feb 12, 2026",
      "desc": "Safety council releases new standards for home-office setups to prevent spinal issues.",
      "category": "Safety"
    },
    {
      "title": "Monsoon Travel Advisory",
      "date": "Feb 10, 2026",
      "desc": "Travelers to hilly regions advised to check weather updates daily due to landslide risks.",
      "category": "Travel"
    },
    {
      "title": "Mental Health Support Program",
      "date": "Feb 08, 2026",
      "desc": "Free tele-consultation services launched for students struggling with burnout.",
      "category": "Health"
    },
    {
      "title": "Emergency First Aid Seminar",
      "date": "Feb 05, 2026",
      "desc": "Join the upcoming webinar on life-saving CPR techniques and emergency responses.",
      "category": "Advisory"
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _launchURL(String query) async {
    final String url = "https://www.google.com/search?q=${Uri.encodeComponent(query)}";
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Combined Filter Logic (Category + Search)
    final filteredItems = newsItems.where((item) {
      final matchesCategory = _selectedCategory == "All" || item['category'] == _selectedCategory;
      final matchesSearch = item['title']!.toLowerCase().contains(_searchQuery.toLowerCase()) || 
                            item['desc']!.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Precautions & News"),
        backgroundColor: appPrimary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Search Bar Section
          Container(
            padding: const EdgeInsets.all(16),
            color: appPrimary,
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
              decoration: InputDecoration(
                hintText: "Search precautions...",
                prefixIcon: const Icon(Icons.search, color: appPrimary),
                suffixIcon: _searchQuery.isNotEmpty 
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: appPrimary),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = "");
                      },
                    )
                  : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),
          
          // Category Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
            child: Row(
              children: ["All", "Health", "Safety", "Travel", "Advisory"].map((cat) {
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat),
                  child: _NewsChip(label: cat, isActive: _selectedCategory == cat),
                );
              }).toList(),
            ),
          ),

          // News List
          Expanded(
            child: filteredItems.isEmpty 
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_off_rounded, size: 80, color: Colors.grey[300]),
                    const SizedBox(height: 10),
                    const Text("No matches found for your search."),
                  ],
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredItems.length,
                  itemBuilder: (context, index) => _buildNewsCard(filteredItems[index]),
                ),
          ),
        ],
      ),
    );
  }

  // Helper methods (_buildNewsCard, _badge, etc.) remain the same as previous response...
  Widget _buildNewsCard(Map<String, String> item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _badge(item['category']!),
                Text(item['date']!, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 10),
            Text(item['title']!, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(item['desc']!, style: TextStyle(color: Colors.grey[700], height: 1.4)),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => _launchURL(item['title']!),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Read More", style: TextStyle(color: appPrimary, fontWeight: FontWeight.bold)),
                  Icon(Icons.arrow_forward, size: 16, color: appPrimary),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: appPrimary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: const TextStyle(color: appPrimary, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }
}

class _NewsChip extends StatelessWidget {
  final String label;
  final bool isActive;
  const _NewsChip({required this.label, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Chip(
        label: Text(label),
        backgroundColor: isActive ? const Color(0xFF007069) : Colors.grey[200],
        labelStyle: TextStyle(color: isActive ? Colors.white : Colors.black87),
      ),
    );
  }
}
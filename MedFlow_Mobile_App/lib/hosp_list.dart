import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

// --- DATA MODELS ---
class Treatment {
  final String disease;
  final String estimate;
  Treatment(this.disease, this.estimate);
}

class DepartmentInfo {
  final String name;
  final int availableBeds;
  final int totalBeds;
  final int doctors;
  final int staff;
  final List<Treatment> treatments;

  DepartmentInfo(this.name, this.availableBeds, this.totalBeds, this.doctors, this.staff, this.treatments);
}

class Hospital {
  final String name;
  final double lat;
  final double lon;
  final double distance;
  final List<DepartmentInfo> inventory;

  Hospital(this.name, this.lat, this.lon, this.distance, this.inventory);
}

class HospitalMapPage extends StatefulWidget {
  const HospitalMapPage({super.key});

  @override
  State<HospitalMapPage> createState() => _HospitalMapPageState();
}

class _HospitalMapPageState extends State<HospitalMapPage> {
  LatLng? userLocation;
  List<Marker> hospitalMarkers = [];
  List<Hospital> hospitals = [];
  final MapController mapController = MapController();
  static const Color appPrimary = Color(0xFF007069);

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  // --- VARIED DATA ENGINE ---
  // Uses the hospital name as a seed so each hospital gets unique, persistent data
  List<DepartmentInfo> _generateVariedData(String hospitalName) {
    // Create a unique seed based on the name string
    final int seed = hospitalName.codeUnits.reduce((a, b) => a + b);
    final Random rand = Random(seed);

    return [
      DepartmentInfo(
        "Cardiology", 
        rand.nextInt(8), // Available beds 0-7
        20 + rand.nextInt(20), // Total beds 20-39
        5 + rand.nextInt(10), // Doctors 5-14
        20 + rand.nextInt(30), // Staff 20-49
        [
          Treatment("Angioplasty", "₹${150 + rand.nextInt(100)}k - ₹300k"),
          Treatment("Heart Bypass", "₹400k - ₹${600 + rand.nextInt(200)}k"),
        ]
      ),
      DepartmentInfo(
        "Emergency / ICU", 
        rand.nextInt(5), 
        10 + rand.nextInt(15), 
        8 + rand.nextInt(8), 
        30 + rand.nextInt(40), 
        [
          Treatment("ICU Care", "₹${20 + rand.nextInt(15)}k / Day"),
          Treatment("Ventilator", "₹10k - ₹18k"),
        ]
      ),
      DepartmentInfo(
        "Orthopedics", 
        rand.nextInt(15), 
        30 + rand.nextInt(20), 
        4 + rand.nextInt(6), 
        15 + rand.nextInt(15), 
        [
          Treatment("Knee Replace", "₹250k - ₹450k"),
          Treatment("Fracture Fix", "₹40k - ₹90k"),
        ]
      ),
    ];
  }

  Future<void> _getLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    if (!mounted) return;
    setState(() {
      userLocation = LatLng(position.latitude, position.longitude);
    });
    _fetchHospitals();
  }

  Future<void> _fetchHospitals() async {
    if (userLocation == null) return;
    double lat = userLocation!.latitude;
    double lon = userLocation!.longitude;

    String query = """
    [out:json];
    node["amenity"="hospital"](around:5000,$lat,$lon);
    out;
    """;

    final response = await http.post(Uri.parse("https://overpass-api.de/api/interpreter"), body: query);
    final data = json.decode(response.body);

    List<Marker> markers = [];
    List<Hospital> hospitalList = [];

    for (var h in data["elements"]) {
      double hLat = h["lat"];
      double hLon = h["lon"];
      String name = h["tags"]?["name"] ?? "Health Center";

      double distance = Geolocator.distanceBetween(lat, lon, hLat, hLon);
      
      // Pass the name to get varied data
      Hospital hospital = Hospital(name, hLat, hLon, distance, _generateVariedData(name));
      hospitalList.add(hospital);

      markers.add(
        Marker(
          point: LatLng(hLat, hLon),
          width: 40,
          height: 40,
          child: GestureDetector(
            onTap: () => _openDetails(hospital),
            child: const Icon(Icons.location_on, color: appPrimary, size: 38),
          ),
        ),
      );
    }

    hospitalList.sort((a, b) => a.distance.compareTo(b.distance));
    setState(() {
      hospitalMarkers = markers;
      hospitals = hospitalList;
    });
  }

  void _openDetails(Hospital hospital) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ResourceDetailSheet(hospital: hospital),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (userLocation == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Varied Resource Map"),
        backgroundColor: appPrimary,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(initialCenter: userLocation!, initialZoom: 15),
            children: [
              TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                userAgentPackageName: "com.example.skit_bfb",
              ),
              MarkerLayer(markers: [
                Marker(point: userLocation!, child: const Icon(Icons.my_location, color: Colors.blue, size: 30)),
                ...hospitalMarkers,
              ]),
            ],
          ),
          
          // --- HORIZONTAL SLIDING OVERLAY ---
          Positioned(
            bottom: 25,
            left: 15,
            right: 15,
            height: 110,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: hospitals.length,
              itemBuilder: (context, index) {
                final h = hospitals[index];
                return GestureDetector(
                  onTap: () {
                    mapController.move(LatLng(h.lat, h.lon), 16);
                    _openDetails(h);
                  },
                  child: Container(
                    width: 260,
                    margin: const EdgeInsets.only(right: 15),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(h.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1),
                        Text("${(h.distance / 1000).toStringAsFixed(1)} km away", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        const Spacer(),
                        Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.green, size: 14),
                            const SizedBox(width: 5),
                            Text("${h.inventory[0].availableBeds} Cardo Beds Available", style: const TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold)),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ResourceDetailSheet extends StatelessWidget {
  final Hospital hospital;
  const _ResourceDetailSheet({required this.hospital});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF4F7F7),
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: ListView(
          controller: controller,
          padding: const EdgeInsets.all(24),
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 20),
            Text(hospital.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF007069))),
            const Text("Hospital Infrastructure & Estimations", style: TextStyle(color: Colors.blueGrey)),
            const Divider(height: 30),
            
            const Text("Resources by Department", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            ...hospital.inventory.map((dept) => _buildDeptCard(dept)),
            
            const SizedBox(height: 25),
            const Text("Treatment Cost Estimates", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
              child: Column(
                children: hospital.inventory
                    .expand((d) => d.treatments)
                    .map((t) => ListTile(
                          leading: const Icon(Icons.price_check, color: Colors.green),
                          title: Text(t.disease, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                          trailing: Text(t.estimate, style: const TextStyle(fontWeight: FontWeight.bold)),
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildDeptCard(DepartmentInfo dept) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(dept.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(10)),
                child: Text("${dept.availableBeds} Vacant", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 11)),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _miniStat(Icons.people, "${dept.doctors} Doctors"),
              _miniStat(Icons.medical_services, "${dept.staff} Staff"),
              _miniStat(Icons.bed, "${dept.totalBeds} Total"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniStat(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF007069)),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
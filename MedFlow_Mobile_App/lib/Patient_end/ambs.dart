import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart'; // Ensure this is in pubspec.yaml

class EmergencyAmbulancePage extends StatefulWidget {
  const EmergencyAmbulancePage({super.key});

  @override
  State<EmergencyAmbulancePage> createState() => _EmergencyAmbulancePageState();
}

class _EmergencyAmbulancePageState extends State<EmergencyAmbulancePage> {
  final supabase = Supabase.instance.client;
  static const Color appPrimary = Color(0xFF007069);
  
  LatLng? userLocation;
  List<Map<String, dynamic>> drivers = [];
  Map<String, LatLng> _livePositions = {};
  Map<String, bool> _isOccupied = {}; 
  
  final MapController _mapController = MapController();
  StreamSubscription? _refreshTimer;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _initMapLogic();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _initMapLogic() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) return;
    Position pos = await Geolocator.getCurrentPosition();
    
    if (!mounted) return;
    setState(() {
      userLocation = LatLng(pos.latitude, pos.longitude);
    });

    await _syncSupabaseAndScatter();
    _refreshTimer = Stream.periodic(const Duration(seconds: 5)).listen((_) {
      _syncSupabaseAndScatter();
    });
  }

  Future<void> _syncSupabaseAndScatter() async {
    try {
      final response = await supabase.from('drivers').select();
      final List<Map<String, dynamic>> rawData = List<Map<String, dynamic>>.from(response);

      if (!mounted) return;

      setState(() {
        drivers = rawData;
        for (int i = 0; i < 10; i++) {
          String id = "marker_$i";
          if (!_livePositions.containsKey(id)) {
            _livePositions[id] = LatLng(
              userLocation!.latitude + (_random.nextDouble() - 0.5) * 0.004,
              userLocation!.longitude + (_random.nextDouble() - 0.5) * 0.004,
            );
            _isOccupied[id] = _random.nextBool(); 
          } else {
            _livePositions[id] = LatLng(
              _livePositions[id]!.latitude + (_random.nextDouble() - 0.5) * 0.0008,
              _livePositions[id]!.longitude + (_random.nextDouble() - 0.5) * 0.0008,
            );
            if (_random.nextDouble() > 0.85) _isOccupied[id] = !_isOccupied[id]!;
          }
        }
      });
    } catch (e) {
      debugPrint("Sync Error: $e");
    }
  }

  // Action to open Phone Dialer
  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      debugPrint("Could not launch $phoneNumber");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nearby Ambulances"),
        backgroundColor: appPrimary,
        foregroundColor: Colors.white,
      ),
      body: userLocation == null
          ? const Center(child: CircularProgressIndicator(color: appPrimary))
          : FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: userLocation!,
                initialZoom: 16,
              ),
              children: [
                TileLayer(
                  urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                  userAgentPackageName: 'com.ambulance.live.tracker',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: userLocation!,
                      width: 50,
                      height: 50,
                      child: const Icon(Icons.person_pin_circle, color: Colors.blue, size: 40),
                    ),
                    ...List.generate(10, (index) {
                      String id = "marker_$index";
                      LatLng pos = _livePositions[id] ?? userLocation!;
                      bool occupied = _isOccupied[id] ?? false;
                      final driver = drivers.isNotEmpty ? drivers[index % drivers.length] : null;

                      return Marker(
                        point: pos,
                        width: 80,
                        height: 80,
                        child: GestureDetector(
                          onTap: () => _showSnack(driver?['ambulance_number'] ?? "Checking..."),
                          onDoubleTap: () => _showDetails(driver, occupied),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(color: occupied ? Colors.red : Colors.green, width: 2),
                                ),
                                child: Text(
                                  occupied ? "BUSY" : "FREE",
                                  style: TextStyle(
                                    fontSize: 9, 
                                    fontWeight: FontWeight.bold, 
                                    color: occupied ? Colors.red : Colors.green
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.airport_shuttle,
                                color: occupied ? Colors.red : Colors.green,
                                size: 38,
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ],
            ),
    );
  }

  void _showSnack(String plate) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Vehicle No: $plate"),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        backgroundColor: appPrimary,
      ),
    );
  }

  void _showDetails(Map<String, dynamic>? driver, bool occupied) {
    if (driver == null) return;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(driver['name'], style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                Chip(
                  label: Text(occupied ? "Occupied" : "Available"),
                  backgroundColor: occupied ? Colors.red[50] : Colors.green[50],
                  labelStyle: TextStyle(color: occupied ? Colors.red : Colors.green, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Text("Vehicle: ${driver['ambulance_number']}", style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 5),
            Text("Mobile: ${driver['phone']}", style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 25),
            
            // --- UPDATED CALL BUTTON ---
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, 
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.pop(context); // Close sheet first
                _makePhoneCall(driver['phone']);
              },
              icon: const Icon(Icons.call, color: Colors.white),
              label: const Text("CALL DRIVER NOW", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
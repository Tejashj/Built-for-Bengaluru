import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class Hospital {
  final String name;
  final double lat;
  final double lon;
  final double distance;

  Hospital(this.name, this.lat, this.lon, this.distance);
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

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  Future<void> _getLocation() async {

    LocationPermission permission = await Geolocator.requestPermission();

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

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

    final response = await http.post(
      Uri.parse("https://overpass-api.de/api/interpreter"),
      body: query,
    );

    final data = json.decode(response.body);

    List<Marker> markers = [];
    List<Hospital> hospitalList = [];

    for (var h in data["elements"]) {

      double hLat = h["lat"];
      double hLon = h["lon"];

      String name = h["tags"]?["name"] ?? "Hospital";

      double distance = Geolocator.distanceBetween(
        lat,
        lon,
        hLat,
        hLon,
      );

      hospitalList.add(Hospital(name, hLat, hLon, distance));

      markers.add(
        Marker(
          point: LatLng(hLat, hLon),
          width: 40,
          height: 20,
          child: const Icon(
            Icons.local_hospital,
            color: Color(0xFF007069),
            size: 30,
          ),
        ),
      );
    }

    hospitalList.sort((a, b) => a.distance.compareTo(b.distance));

    setState(() {
      hospitalMarkers = markers;
      hospitals = hospitalList.take(6).toList();
    });
  }

  void _focusHospital(Hospital hospital) {

    mapController.move(
      LatLng(hospital.lat, hospital.lon),
      16,
    );
  }

  @override
  Widget build(BuildContext context) {

    if (userLocation == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(

      appBar: AppBar(
        title: const Text("Nearby Hospitals"),
        backgroundColor: const Color(0xFF007069),
      ),

      body: Column(
        children: [

          // 🔹 MAP SECTION
          Expanded(
            flex: 1,
            child: FlutterMap(

              mapController: mapController,

              options: MapOptions(
                initialCenter: userLocation!,
                initialZoom: 16,
              ),

              children: [

                TileLayer(
                  urlTemplate:
                      "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                  userAgentPackageName: "com.example.skit_bfb",
                ),

                MarkerLayer(
                  markers: [

                    Marker(
                      point: userLocation!,
                      width: 40,
                      height: 20,
                      child: const Icon(
                        Icons.my_location,
                        color: Color.fromARGB(255, 124, 1, 1),
                        size: 30,
                      ),
                    ),

                    ...hospitalMarkers
                  ],
                ),

              ],
            ),
          ),

          // 🔹 HOSPITAL LIST SECTION
          Expanded(
            flex: 1,
            child: ListView.builder(

              itemCount: hospitals.length,

              itemBuilder: (context, index) {

                final hospital = hospitals[index];

                return ListTile(

                  leading: const Icon(
                    Icons.local_hospital,
                    color: Color(0xFF007069),
                  ),

                  title: Text(hospital.name),

                  subtitle: Text(
                    "${(hospital.distance / 1000).toStringAsFixed(2)} km away",
                  ),

                  onTap: () {
                    _focusHospital(hospital);
                  },
                );
              },
            ),
          ),

        ],
      ),
    );
  }
}
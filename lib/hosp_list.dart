import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class HospitalMapPage extends StatefulWidget {
  const HospitalMapPage({super.key});

  @override
  State<HospitalMapPage> createState() => _HospitalMapPageState();
}

class _HospitalMapPageState extends State<HospitalMapPage> {

  GoogleMapController? _mapController;

  Set<Marker> _markers = {};

  Position? _currentPosition;

  static const Color appPrimary = Color(0xFF007069);

  @override
  void initState() {
    super.initState();
    _loadLocation();
  }

  Future<void> _loadLocation() async {

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      throw Exception("Location services disabled");
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      _currentPosition = position;
    });

    _addUserMarker();

    await _fetchHospitals();
  }

  void _addUserMarker() {

    if (_currentPosition == null) return;

    _markers.add(
      Marker(
        markerId: const MarkerId("user"),
        position: LatLng(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
        ),
        infoWindow: const InfoWindow(title: "Your Location"),
        icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueBlue),
      ),
    );
  }

  Future<void> _fetchHospitals() async {

    String apiKey = dotenv.env['PLACES_API_KEY']!;

    final url =
        "https://maps.googleapis.com/maps/api/place/nearbysearch/json"
        "?location=${_currentPosition!.latitude},${_currentPosition!.longitude}"
        "&radius=5000&type=hospital&key=$apiKey";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {

      final data = json.decode(response.body);

      for (var hospital in data["results"]) {

        final lat = hospital["geometry"]["location"]["lat"];
        final lng = hospital["geometry"]["location"]["lng"];

        _markers.add(
          Marker(
            markerId: MarkerId(hospital["place_id"]),
            position: LatLng(lat, lng),
            infoWindow: InfoWindow(
              title: hospital["name"],
              snippet: hospital["vicinity"],
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueRed),
          ),
        );
      }

      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {

    if (_currentPosition == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Nearby Hospitals"),
        backgroundColor: appPrimary,
      ),

      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
          ),
          zoom: 14,
        ),

        markers: _markers,

        myLocationEnabled: true,

        myLocationButtonEnabled: true,

        onMapCreated: (controller) {
          _mapController = controller;
        },
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DriversPage extends StatefulWidget {
  const DriversPage({super.key});

  static const Color appPrimary = Color(0xFF007069);

  @override
  State<DriversPage> createState() => _DriversPageState();
}

class _DriversPageState extends State<DriversPage> {

  final supabase = Supabase.instance.client;

  List drivers = [];

  @override
  void initState() {
    super.initState();
    fetchDrivers();
  }

  Future<void> fetchDrivers() async {

    final response = await supabase
        .from('drivers')
        .select();

    setState(() {
      drivers = response;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Available Ambulance Drivers"),
        backgroundColor: DriversPage.appPrimary,
      ),

      body: drivers.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(

              itemCount: drivers.length,

              itemBuilder: (context, index) {

                final driver = drivers[index];

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),

                  child: ListTile(

                    leading: const Icon(Icons.local_hospital),

                    title: Text(
                      driver['name'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),

                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Text("Phone: ${driver['phone']}"),

                        Text("Ambulance: ${driver['ambulance_number']}"),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
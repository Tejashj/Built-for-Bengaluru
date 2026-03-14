import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Sos extends StatelessWidget {
  const Sos({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SOS Emergency',
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFF007069),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF007069)),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    // Pulse animation for the emergency button
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F7),
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text('EMERGENCY SOS', 
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.2)),
        backgroundColor: const Color(0xFF007069),
      ),
      body: Stack(
        children: [
          // Background Gradient highlight
          Container(
            height: MediaQuery.of(context).size.height * 0.3,
            decoration: const BoxDecoration(
              color: Color(0xFF007069),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Urgent Pulse Button
                ScaleTransition(
                  scale: Tween(begin: 1.0, end: 1.05).animate(_pulseController),
                  child: _buildEmergencyButton(
                    context,
                    title: 'CALL AMBULANCE',
                    icon: Icons.emergency_share,
                    color: const Color.fromARGB(255, 153, 10, 10), // Urgent Red
                    onTap: () => _callAmbulance(context),
                  ),
                ),
                const SizedBox(height: 30),
                // Secondary Action Card
                _buildActionCard(
                  context,
                  title: 'BLOOD BANK SOS',
                  subtitle: 'Request specific blood group via WhatsApp',
                  icon: Icons.bloodtype,
                  color: const Color(0xFF007069),
                  onTap: () => _showBloodGroupDialog(context),
                ),
                const SizedBox(height: 100), // Spacing for bottom
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyButton(BuildContext context, {required String title, required IconData icon, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 200,
        width: 200,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.4), blurRadius: 20, spreadRadius: 5, offset: const Offset(0, 10)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 60, color: Colors.white),
            const SizedBox(height: 10),
            Text(title, textAlign: TextAlign.center, 
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, {required String title, required String subtitle, required IconData icon, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: const Color(0xFF000000).withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  void _callAmbulance(BuildContext context) async {
    const String ambulanceNumber = '+917892942557';
    final Uri url = Uri.parse('tel:$ambulanceNumber');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      _showSnackBar(context, 'Could not launch dialer');
    }
  }

  void _showBloodGroupDialog(BuildContext context) {
    String selectedGroup = 'A+';
    final Map<String, String> bloodGroupToNumber = {
      'A+': '+919481032460', 'A-': '+917892942557',
      'B+': '+919606248727', 'B-': '+918217748909',
      'AB+': '+919481032460', 'AB-': '+917892942557',
      'O+': '+919606248727', 'O-': '+918217748909',
    };

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder( // Allows dropdown to update inside dialog
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text('Request Blood'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Select required blood group to notify the bank via WhatsApp.'),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: selectedGroup,
                        onChanged: (String? newValue) {
                          setDialogState(() => selectedGroup = newValue!);
                        },
                        items: bloodGroupToNumber.keys.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(value: value, child: Text(value));
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF007069), foregroundColor: Colors.white),
                  onPressed: () async {
                    String phoneNumber = bloodGroupToNumber[selectedGroup]!;
                    String message = 'Urgent SOS: Need blood group $selectedGroup immediately.';
                    final Uri whatsappUrl = Uri.parse('https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}');

                    if (await canLaunchUrl(whatsappUrl)) {
                      await launchUrl(whatsappUrl);
                    } else {
                      _showSnackBar(context, 'WhatsApp not installed');
                    }
                    Navigator.pop(context);
                  },
                  child: const Text('Notify Bank'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showSnackBar(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
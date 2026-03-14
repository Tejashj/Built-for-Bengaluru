import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class SmartPharmacyPage extends StatefulWidget {
  const SmartPharmacyPage({super.key});

  @override
  State<SmartPharmacyPage> createState() => _SmartPharmacyPageState();
}

class _SmartPharmacyPageState extends State<SmartPharmacyPage> {
  final supabase = Supabase.instance.client;
  File? _image;
  bool _isProcessing = false;
  
  List<Map<String, String>> _cartItems = [];
  final TextEditingController _manualController = TextEditingController();

  final List<Map<String, String>> _essentials = [
    {"name": "Paracetamol 500mg", "price": "₹40", "icon": "💊"},
    {"name": "First Aid Kit", "price": "₹250", "icon": "🩹"},
    {"name": "Digital Thermometer", "price": "₹180", "icon": "🌡️"},
    {"name": "Vitamin C Strips", "price": "₹60", "icon": "🍊"},
  ];

  static const Color appPrimary = Color(0xFF007069);

  // --- SUPABASE ORDER LOGIC ---
  Future<void> _placeOrder() async {
    final user = supabase.auth.currentUser;
    if (user == null || _cartItems.isEmpty) return;

    setState(() => _isProcessing = true);

    try {
      DateTime deliveryDate = DateTime.now().add(const Duration(days: 2));

      await supabase.from('pharmacy_orders').insert({
        'patient_id': user.id,
        'items': _cartItems,
        'total_items': _cartItems.length,
        'estimated_delivery': deliveryDate.toIso8601String(),
        'status': 'Processing',
      });

      if (mounted) {
        Navigator.pop(context); 
        _showSuccessAnim(deliveryDate);
        setState(() => _cartItems = []);
      }
    } catch (e) {
      debugPrint("Order Error: $e");
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  // --- AI SCANNING LOGIC ---
  Future<void> _pickAndProcess(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile == null) return;

    setState(() {
      _image = File(pickedFile.path);
      _isProcessing = true;
    });

    try {
      final inputImage = InputImage.fromFile(_image!);
      final textRecognizer = TextRecognizer();
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
      
      final String apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
      final String url = 'https://generativelanguage.googleapis.com/v1/models/gemini-2.5-flash:generateContent?key=$apiKey';

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [{"parts": [{"text": "Extract medicines from this text as a JSON array of objects with 'name' and 'dosage'. Only return JSON. Text: ${recognizedText.text}"}]}]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String cleanJson = data['candidates'][0]['content']['parts'][0]['text']
            .replaceAll('```json', '')
            .replaceAll('```', '')
            .trim();
        List<dynamic> parsed = jsonDecode(cleanJson);
        
        setState(() {
          for (var item in parsed) {
            _cartItems.add({
              "name": item['name'].toString(), 
              "dosage": item['dosage']?.toString() ?? "As prescribed"
            });
          }
        });
      }
      textRecognizer.close();
    } catch (e) {
      debugPrint("Scan Error: $e");
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _addManualItem() {
    if (_manualController.text.isNotEmpty) {
      setState(() {
        _cartItems.add({"name": _manualController.text, "dosage": "Manual Entry"});
        _manualController.clear();
      });
    }
  }

  void _showCheckout() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          padding: const EdgeInsets.all(25),
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Order Summary", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: _cartItems.length,
                  itemBuilder: (context, i) => ListTile(
                    leading: const Icon(Icons.medication_liquid, color: appPrimary),
                    title: Text(_cartItems[i]['name']!),
                    subtitle: Text(_cartItems[i]['dosage']!),
                  ),
                ),
              ),
              const Divider(),
              SizedBox(
                width: double.infinity, height: 55,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : () async {
                    setSheetState(() => _isProcessing = true);
                    await _placeOrder();
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: appPrimary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                  child: _isProcessing 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Confirm & Place Order", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _showSuccessAnim(DateTime deliveryDate) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 80),
            const SizedBox(height: 20),
            const Text("Order Placed!", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text("Est. Delivery: ${DateFormat('MMM d').format(deliveryDate)}"),
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Done"))
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      appBar: AppBar(
        title: const Text("Pharmacy Mall"), 
        backgroundColor: appPrimary, 
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.history), 
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const OrderHistoryPage())),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Scan Prescription", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: appPrimary)),
            const SizedBox(height: 10),
            _buildScanCard(),
            const SizedBox(height: 25),
            const Text("Medical Essentials", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: appPrimary)),
            const SizedBox(height: 10),
            SizedBox(
              height: 110,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _essentials.length,
                itemBuilder: (context, i) => _buildStaticItem(_essentials[i]),
              ),
            ),
            const SizedBox(height: 25),
            if (_cartItems.isNotEmpty) ...[
              Text("Cart (${_cartItems.length})", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              ..._cartItems.map((item) => Card(
                child: ListTile(
                  title: Text(item['name']!),
                  subtitle: Text(item['dosage']!),
                  trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => setState(() => _cartItems.remove(item))),
                ),
              )),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _showCheckout,
                style: ElevatedButton.styleFrom(backgroundColor: appPrimary, minimumSize: const Size(double.infinity, 55)),
                child: const Text("Checkout", style: TextStyle(color: Colors.white)),
              )
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildScanCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _scanOption(Icons.camera_alt, "Camera", () => _pickAndProcess(ImageSource.camera)),
          _scanOption(Icons.photo_library, "Gallery", () => _pickAndProcess(ImageSource.gallery)),
        ],
      ),
    );
  }

  Widget _scanOption(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(children: [Icon(icon, color: appPrimary, size: 30), Text(label)]),
    );
  }

  Widget _buildStaticItem(Map<String, String> item) {
    return GestureDetector(
      onTap: () => setState(() => _cartItems.add({"name": item['name']!, "dosage": "OTC Item"})),
      child: Container(
        width: 140, margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.shade100)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(item['icon']!, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 5),
            Text(item['name']!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            Text(item['price']!, style: const TextStyle(fontSize: 11, color: appPrimary)),
          ],
        ),
      ),
    );
  }
}

class OrderHistoryPage extends StatelessWidget {
  const OrderHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;
    return Scaffold(
      appBar: AppBar(title: const Text("My Orders"), backgroundColor: const Color(0xFF007069), foregroundColor: Colors.white),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: supabase.from('pharmacy_orders').select().eq('patient_id', supabase.auth.currentUser!.id).order('order_date', ascending: false),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final orders = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: orders.length,
            itemBuilder: (context, i) => Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: ListTile(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => OrderDetailsPage(order: orders[i]))),
                leading: const Icon(Icons.local_shipping, color: Color(0xFF007069)),
                title: Text("Order ID: ${orders[i]['id'].toString().substring(0, 8)}"),
                subtitle: Text("Status: ${orders[i]['status']}"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14),
              ),
            ),
          );
        },
      ),
    );
  }
}

class OrderDetailsPage extends StatelessWidget {
  final Map<String, dynamic> order;
  const OrderDetailsPage({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final List items = order['items'] as List;
    final DateTime deliveryDate = DateTime.parse(order['estimated_delivery']);

    return Scaffold(
      appBar: AppBar(title: const Text("Order Details"), backgroundColor: const Color(0xFF007069), foregroundColor: Colors.white),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTracker(order['status']),
            const SizedBox(height: 25),
            const Text("Prescribed Items", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, i) => Card(
                  child: ListTile(
                    title: Text(items[i]['name']),
                    subtitle: Text(items[i]['dosage']),
                  ),
                ),
              ),
            ),
            const Divider(),
            Text("Estimated Delivery: ${DateFormat('EEEE, MMM d').format(deliveryDate)}", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF007069))),
          ],
        ),
      ),
    );
  }

  Widget _buildTracker(String status) {
    int step = status == 'Delivered' ? 2 : (status == 'Dispatched' ? 1 : 0);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _dot("Ordered", step >= 0),
        _line(step >= 1),
        _dot("Shipped", step >= 1),
        _line(step >= 2),
        _dot("Delivered", step >= 2),
      ],
    );
  }

  Widget _dot(String label, bool active) => Column(children: [Icon(Icons.check_circle, color: active ? const Color(0xFF007069) : Colors.grey), Text(label, style: const TextStyle(fontSize: 10))]);
  Widget _line(bool active) => Container(width: 40, height: 2, color: active ? const Color(0xFF007069) : Colors.grey[300]);
}
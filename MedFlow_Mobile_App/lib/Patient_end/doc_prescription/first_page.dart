import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:ui';

class PrescriptionScanner extends StatefulWidget {
  const PrescriptionScanner({super.key});

  @override
  State<PrescriptionScanner> createState() => _PrescriptionScannerState();
}

class _PrescriptionScannerState extends State<PrescriptionScanner> with TickerProviderStateMixin {
  // Camera & Logic
  CameraController? _controller;
  bool _isCameraReady = false;
  bool _isAnalyzing = false;
  String _extractedText = '';
  String _aiInsights = '';
  
  // UI Animations
  late AnimationController _scanningController;
  final FlutterTts _tts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _scanningController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    _controller = CameraController(cameras[0], ResolutionPreset.max, enableAudio: false);
    await _controller!.initialize();
    if (mounted) setState(() => _isCameraReady = true);
  }

  Future<void> _processImage() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    setState(() => _isAnalyzing = true);
    
    try {
      final XFile image = await _controller!.takePicture();
      final inputImage = InputImage.fromFilePath(image.path);
      final textRecognizer = TextRecognizer();
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
      
      _extractedText = recognizedText.text;
      await _callGeminiAI(_extractedText);
    } catch (e) {
      _showError("Scan failed: $e");
    } finally {
      setState(() => _isAnalyzing = false);
    }
  }

  Future<void> _callGeminiAI(String text) async {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    final url = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$apiKey';

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "contents": [{"parts": [{"text": "You are a medical assistant. Simplify this prescription text into clear sections: Medications, Dosage, and Potential Warnings. Text: $text"}]}]
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _aiInsights = data['candidates'][0]['content']['parts'][0]['text'];
        _showResultsSheet();
      });
    }
  }

  void _showResultsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildResultsOverlay(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Immersive Camera Preview
          if (_isCameraReady)
            Transform.scale(
              scale: 1.0,
              child: Center(child: CameraPreview(_controller!)),
            )
          else
            const Center(child: CircularProgressIndicator(color: Colors.white)),

          // 2. Scanning Animation Overly
          if (_isCameraReady && !_isAnalyzing)
            _buildScanningIndicator(),

          // 3. Top Glass Bar
          _buildTopBar(),

          // 4. Bottom Action Bar
          _buildBottomControls(),
          
          if (_isAnalyzing)
            _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildScanningIndicator() {
    return AnimatedBuilder(
      animation: _scanningController,
      builder: (context, child) {
        return Positioned(
          top: MediaQuery.of(context).size.height * 0.2 + (_scanningController.value * 400),
          left: 40,
          right: 40,
          child: Container(
            height: 2,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(color: Colors.tealAccent.withOpacity(0.5), blurRadius: 10, spreadRadius: 2)
              ],
              gradient: const LinearGradient(colors: [Colors.transparent, Colors.tealAccent, Colors.transparent]),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopBar() {
    return Positioned(
      top: 50,
      left: 20,
      right: 20,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white), onPressed: () => Navigator.pop(context)),
                const Text("AI Prescription Scanner", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Positioned(
      bottom: 40,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _circularIconButton(Icons.photo_library, () {}),
          GestureDetector(
            onTap: _processImage,
            child: Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
              ),
              child: Center(
                child: Container(
                  height: 60,
                  width: 60,
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                ),
              ),
            ),
          ),
          _circularIconButton(Icons.flash_on, () {}),
        ],
      ),
    );
  }

  Widget _circularIconButton(IconData icon, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
      child: IconButton(icon: Icon(icon, color: Colors.white), onPressed: onTap),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: Colors.tealAccent),
            const SizedBox(height: 20),
            Text("Reading prescription...", style: TextStyle(color: Colors.white.withOpacity(0.8), letterSpacing: 1.2)),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsOverlay() {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF4F7F6),
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.all(24),
        child: ListView(
          controller: controller,
          children: [
            Center(child: Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 25),
            const Text("Analysis Results", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF007069))),
            const SizedBox(height: 20),
            _buildInsightCard("Extracted Text", _extractedText, Icons.description_outlined),
            const SizedBox(height: 15),
            _buildInsightCard("AI Interpretation", _aiInsights, Icons.auto_awesome),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF007069),
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              onPressed: () => _tts.speak(_aiInsights),
              child: const Text("Listen to Instructions", style: TextStyle(color: Colors.white, fontSize: 18)),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInsightCard(String title, String content, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF007069), size: 20),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            ],
          ),
          const Divider(),
          Text(content, style: const TextStyle(fontSize: 16, height: 1.5)),
        ],
      ),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void dispose() {
    _controller?.dispose();
    _scanningController.dispose();
    super.dispose();
  }
}
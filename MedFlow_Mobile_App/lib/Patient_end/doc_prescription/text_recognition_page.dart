import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For Clipboard
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class TextRecognitionPage extends StatefulWidget {
  final String imagePath;
  const TextRecognitionPage({
    super.key,
    required this.imagePath,
    required String imageUrl, // Placeholder for external compatibility
    required bool isFromGallery, // Placeholder for external compatibility
  });

  @override
  _TextRecognitionPageState createState() => _TextRecognitionPageState();
}

class _TextRecognitionPageState extends State<TextRecognitionPage> {
  String _extractedText = '';
  String _aiResponse = '';
  bool _isLoading = true;
  bool _isAnalyzing = false;
  bool _isReading = false;
  final FlutterTts _flutterTts = FlutterTts();

  static const Color appPrimary = Color(0xFF007069);
  static const Color appBackground = Color(0xFFC5D4E5);

  @override
  void initState() {
    super.initState();
    _initializeTts();
    _recognizeText();
  }

  void _initializeTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.5);
    _flutterTts.setCompletionHandler(() {
      setState(() => _isReading = false);
    });
  }

  Future<void> _recognizeText() async {
    try {
      final inputImage = InputImage.fromFilePath(widget.imagePath);
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

      String extractedText = '';
      for (final block in recognizedText.blocks) {
        for (final line in block.lines) {
          extractedText += '${line.text}\n';
        }
        extractedText += '\n';
      }

      setState(() {
        _extractedText = extractedText.trim();
        _isLoading = false;
      });
      textRecognizer.close();
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Error recognizing text: $e');
    }
  }

  void _toggleReading() async {
    if (_isReading) {
      await _flutterTts.stop();
      setState(() => _isReading = false);
    } else {
      if (_extractedText.isNotEmpty) {
        setState(() => _isReading = true);
        await _flutterTts.speak(_extractedText);
      } else {
        _showSnackBar('No text to read.');
      }
    }
  }

  Future<void> _analyzeTextWithGemini() async {
    if (_extractedText.isEmpty) {
      _showSnackBar('No text recognized to analyze.');
      return;
    }

    setState(() => _isAnalyzing = true);

    try {
      final String apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
      if (apiKey.isEmpty) throw Exception('Gemini API Key missing in .env');

      // FIXED: Using v1 stable and passing the key as a query parameter
      final String endpoint =
          'https://generativelanguage.googleapis.com/v1/models/gemini-2.5-flash:generateContent?key=$apiKey';

      final response = await http.post(
        Uri.parse(endpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {
                  "text": "Analyze the following medical text. List potential health risks or medical terms found: $_extractedText"
                }
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _aiResponse = data['candidates'][0]['content']['parts'][0]['text'];
          _isAnalyzing = false;
        });
      } else {
        // Detailed error for 403 or other status codes
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error']['message'] ?? 'Failed to analyze');
      }
    } catch (e) {
      setState(() {
        _aiResponse = 'Error: $e';
        _isAnalyzing = false;
      });
      _showSnackBar('AI Analysis failed. Check console.');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBackground,
      appBar: AppBar(
        title: const Text('Medical Text Analysis', style: TextStyle(color: Colors.white)),
        backgroundColor: appPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.copy, color: Colors.white),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: _extractedText));
              _showSnackBar('Text copied to clipboard!');
            },
          ),
          IconButton(
            icon: Icon(_isReading ? Icons.stop : Icons.play_arrow, color: Colors.white),
            onPressed: _toggleReading,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: appPrimary))
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Container(
                        padding: const EdgeInsets.all(24.0),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Extracted Text:',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: appPrimary),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _extractedText.isNotEmpty ? _extractedText : 'No text recognized.',
                                style: const TextStyle(fontSize: 15, color: Colors.black87),
                              ),
                              if (_aiResponse.isNotEmpty) ...[
                                const Divider(height: 40, thickness: 1),
                                const Text(
                                  'AI Insights:',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: appPrimary),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  _aiResponse,
                                  style: const TextStyle(fontSize: 15, color: Colors.black87),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isAnalyzing ? null : _analyzeTextWithGemini,
                style: ElevatedButton.styleFrom(
                  backgroundColor: appPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                ),
                child: _isAnalyzing
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                          SizedBox(width: 15),
                          Text('Generating Analysis...', style: TextStyle(color: Colors.white)),
                        ],
                      )
                    : const Text(
                        'Analyze with Gemini',
                        style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }
}
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:animate_do/animate_do.dart';

// --- DATA MODEL ---
class ChatMessage {
  final String text;
  final bool isUser;
  ChatMessage({required this.text, required this.isUser});
}

class ModernMedicalChatbot extends StatefulWidget {
  const ModernMedicalChatbot({super.key});

  @override
  State<ModernMedicalChatbot> createState() => _ModernMedicalChatbotState();
}

class _ModernMedicalChatbotState extends State<ModernMedicalChatbot> {
  // API Config
  final String _apiKey = dotenv.env['GEMINI_API_KEY'] ?? "";
  final String _apiUrl =
      "https://generativelanguage.googleapis.com/v1/models/gemini-2.5-flash:generateContent";

  // Controllers & State
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  // Voice Engines
  late stt.SpeechToText _speech;
  late FlutterTts _tts;
  bool _isListening = false;

  // Theme Colors
  static const Color appPrimary = Color(0xFF007069);
  static const Color appAccent = Color(0xFFC5D4E5);

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _tts = FlutterTts();
    _initVoice();
    
    _messages.add(ChatMessage(
      text: "Hello! I am your AI medical assistant. You can type or speak your symptoms.",
      isUser: false,
    ));
  }

  void _initVoice() async {
    await _tts.setLanguage("en-US");
    await _tts.setPitch(1.0);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // --- LOGIC: SEND MESSAGE ---
  Future<void> _sendMessage() async {
    final String userMessage = _controller.text.trim();
    if (userMessage.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(text: userMessage, isUser: true));
      _isLoading = true;
    });
    _controller.clear();
    _scrollToBottom();

    try {
      final response = await http.post(
        Uri.parse('$_apiUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {
              "role": "user",
              "parts": [
                {
                  "text": "INSTRUCTIONS: You are a compassionate medical assistant. Provide general medical info and remedies. Limit to 100-150 words.'\n\nQUESTION: $userMessage"
                }
              ]
            }
          ],
          "generationConfig": {
            "temperature": 0.7,
            "maxOutputTokens": 800,
          },
        }),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final botText = decoded['candidates'][0]['content']['parts'][0]['text'];
        setState(() {
          _messages.add(ChatMessage(text: botText, isUser: false));
        });
        // Voice response
        await _tts.speak(botText);
      } else {
        _showError("Error ${response.statusCode}");
      }
    } catch (e) {
      _showError("Connection Error: $e");
    } finally {
      setState(() => _isLoading = false);
      _scrollToBottom();
    }
  }

  // --- LOGIC: VOICE ---
  Future<void> _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(onResult: (val) {
          setState(() {
            _controller.text = val.recognizedWords;
          });
        });
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
      if (_controller.text.isNotEmpty) _sendMessage();
    }
  }

  void _showError(String message) {
    setState(() => _messages.add(ChatMessage(text: "Alert: $message", isUser: false)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        title: Column(
          children: [
            Text("MediBot AI", style: GoogleFonts.poppins(color: appPrimary, fontWeight: FontWeight.bold, fontSize: 18)),
            Text("Online • 2026 Edition", style: GoogleFonts.poppins(color: Colors.green, fontSize: 10)),
          ],
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.only(bottom: 100, left: 16, right: 16, top: 10),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) => FadeInUp(
                    duration: const Duration(milliseconds: 400),
                    child: _buildModernBubble(_messages[index]),
                  ),
                ),
              ),
            ],
          ),
          if (_isLoading) 
            const Positioned(top: 0, left: 0, right: 0, child: LinearProgressIndicator(color: appPrimary, backgroundColor: Colors.transparent)),
          _buildFloatingInput(),
        ],
      ),
    );
  }

  Widget _buildModernBubble(ChatMessage msg) {
    return Align(
      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: msg.isUser ? appPrimary : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(msg.isUser ? 20 : 0),
            bottomRight: Radius.circular(msg.isUser ? 0 : 20),
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))
          ],
        ),
        child: Text(
          msg.text,
          style: GoogleFonts.inter(
            color: msg.isUser ? Colors.white : Colors.black87,
            fontSize: 15,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingInput() {
    return Positioned(
      bottom: 20,
      left: 15,
      right: 15,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(35),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20)],
        ),
        child: Row(
          children: [
            IconButton(
              icon: Icon(_isListening ? Icons.mic : Icons.mic_none, color: _isListening ? Colors.red : appPrimary),
              onPressed: _listen,
            ),
            Expanded(
              child: TextField(
                controller: _controller,
                onSubmitted: (_) => _sendMessage(),
                style: GoogleFonts.inter(fontSize: 15),
                decoration: const InputDecoration(
                  hintText: "Describe symptoms...",
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 10),
                ),
              ),
            ),
            GestureDetector(
              onTap: _isLoading ? null : _sendMessage,
              child: CircleAvatar(
                backgroundColor: appPrimary,
                child: _isLoading 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
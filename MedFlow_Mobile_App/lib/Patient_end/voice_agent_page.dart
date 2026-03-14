import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:avatar_glow/avatar_glow.dart';

class AppColors {
  static const Color appPrimary = Color(0xFF007069);
  static const Color appSecondary = Color(0xFFC5D4E5);
  static const Color appBackground = Color(0xFFF4F7F6); // Slightly off-white for contrast
}

class AIAgentPage extends StatefulWidget {
  const AIAgentPage({super.key});

  @override
  State<AIAgentPage> createState() => _AIAgentPageState();
}

class _AIAgentPageState extends State<AIAgentPage> {
  final SpeechToText speech = SpeechToText();
  final FlutterTts tts = FlutterTts();

  String userText = "Tap the mic to start...";
  String aiReply = "Hello! I'm your appointment assistant. How can I help you today?";
  bool isListening = false;
  bool isAiThinking = false;

  final String sessionId = "flutter_session_123";
  final String api = "https://turpentinic-teagan-seasonably.ngrok-free.dev/chat";

  @override
  void initState() {
    super.initState();
    initTTS();

    // Auto-restart listening after AI finishes speaking
    tts.setCompletionHandler(() {
      if (mounted) {
        startListening();
      }
    });

    // Initial greeting from backend
    Future.delayed(const Duration(milliseconds: 1000), () {
      sendMessage("start");
    });
  }

  Future<void> initTTS() async {
    await tts.setLanguage("en-IN");
    await tts.setPitch(1.0);
    await tts.setSpeechRate(0.5);
    try {
      var voices = await tts.getVoices;
      for (var voice in voices) {
        if (voice["locale"] == "en-IN") {
          await tts.setVoice(voice);
          break;
        }
      }
    } catch (e) {
      debugPrint("TTS Voice Error: $e");
    }
  }

  Future<void> sendMessage(String message) async {
    setState(() => isAiThinking = true);

    try {
      var res = await http.post(
        Uri.parse(api),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"session_id": sessionId, "message": message}),
      );

      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);
        setState(() {
          aiReply = data["reply"] ?? "I didn't catch that.";
          isAiThinking = false;
        });
        await speak(aiReply);
      } else {
        throw Exception("Server Error");
      }
    } catch (e) {
      setState(() {
        aiReply = "Sorry, I'm having trouble connecting to the server.";
        isAiThinking = false;
      });
      await speak(aiReply);
    }
  }

  Future<void> speak(String text) async {
    setState(() => isListening = false);
    await speech.stop();
    await tts.speak(text);
  }

  Future<void> startListening() async {
    if (isListening) return;

    bool available = await speech.initialize(
      onStatus: (status) {
        if (status == 'notListening' || status == 'done') {
          setState(() => isListening = false);
        }
      },
      onError: (e) => setState(() => isListening = false),
    );

    if (available) {
      setState(() => isListening = true);
      speech.listen(
        listenFor: const Duration(seconds: 20),
        pauseFor: const Duration(seconds: 4),
        localeId: "en_IN",
        onResult: (result) async {
          setState(() {
            userText = result.recognizedWords;
          });
          if (result.finalResult) {
            setState(() => isListening = false);
            await sendMessage(userText);
          }
        },
      );
    }
  }

  void toggleListening() {
    if (isListening) {
      speech.stop();
      setState(() => isListening = false);
    } else {
      startListening();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBackground,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.appPrimary,
        title: const Text("Appointment Agent", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Header / AI Avatar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(bottom: 30, left: 20, right: 20),
            decoration: const BoxDecoration(
              color: AppColors.appPrimary,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.assistant, color: Colors.white, size: 40),
                ),
                const SizedBox(height: 10),
                Text(
                  isAiThinking ? "AI is thinking..." : "Agent Active",
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),

          // Chat Area
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildBubble(aiReply, false),
                const SizedBox(height: 15),
                if (userText.isNotEmpty && userText != "Tap the mic to start...")
                  _buildBubble(userText, true),
              ],
            ),
          ),

          // Interactive Mic Button
          Padding(
            padding: const EdgeInsets.only(bottom: 40),
            child: Column(
              children: [
                AvatarGlow(
                  animate: isListening,
                  glowColor: AppColors.appPrimary,
                  duration: const Duration(milliseconds: 2000),
                  repeat: true,
                  child: GestureDetector(
                    onTap: toggleListening,
                    child: Container(
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                        color: isListening ? Colors.redAccent : AppColors.appPrimary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            spreadRadius: 2,
                          )
                        ],
                      ),
                      child: Icon(
                        isListening ? Icons.mic : Icons.mic_none,
                        color: Colors.white,
                        size: 35,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  isListening ? "Listening..." : "Tap to Speak",
                  style: TextStyle(
                    color: isListening ? Colors.redAccent : AppColors.appPrimary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBubble(String text, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: isUser ? AppColors.appPrimary : AppColors.appSecondary.withOpacity(0.4),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isUser ? 20 : 0),
            bottomRight: Radius.circular(isUser ? 0 : 20),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isUser ? Colors.white : Colors.black87,
            fontSize: 17,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}
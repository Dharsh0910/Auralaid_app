import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'voice_helper.dart';

late VoiceHelper _voiceHelper;

class NextPage extends StatefulWidget {
  @override
  State<NextPage> createState() => _NextPageState();
}

class _NextPageState extends State<NextPage> {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isSpeaking = false;

  @override
  void initState() {
    super.initState();
    _voiceHelper = VoiceHelper();

    _speakWelcomeAndListen();
  }

  Future<void> _speakWelcomeAndListen() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);

    // Set callback for when TTS finishes
    _flutterTts.setCompletionHandler(() {
      print("✅ TTS completed, now starting listening...");
      _startListening();
    });

    // Speak message
    await _flutterTts.speak(
      "Listening is on. Options are: Object Detection, Emotion Detection, and Product Detection , or want to open app.",
    );
  }

  void _startListening() {
    _voiceHelper.initSpeech((command) {
      print("🎤 Command received: $command");

      if (command.contains("object")) {
        _flutterTts.speak("Opening Object Detection");
        Navigator.pushNamed(context, '/object');
      } else if (command.contains("emotion")) {
        _flutterTts.speak("Opening Emotion Detection");
        Navigator.pushNamed(context, '/emotion');
      } else if (command.contains("product")) {
        _flutterTts.speak("Opening Product Detection");
        Navigator.pushNamed(context, '/product');
      } else {
        _flutterTts.speak("Sorry, I didn't understand that command.");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("AuralAid"),
        backgroundColor: Colors.teal,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.black, Colors.blue, Colors.tealAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Column(
                children: [
                  Image.asset(
                    'assets/5145a3eb-b2e5-4303-bcea-d5dea32ae435.jpg',
                    width: 150,
                  ),
                  SizedBox(height: 15),
                  Text(
                    'AURALAID',
                    style: TextStyle(
                      color: Colors.lightGreenAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 60),
            buildButton(context, "Object Detection", '/object'),
            buildButton(context, "Emotion Detection", '/emotion'),
            buildButton(context, "Product Detection", '/product'),
            SizedBox(height: 40),
            Text(
              "Listening is on....",
              style: TextStyle(color: Colors.white, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildButton(BuildContext context, String label, String route) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[400],
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: () {
          Navigator.pushNamed(context, route);
        },
        child: Center(
          child: Text(label, style: TextStyle(color: Colors.black, fontSize: 16)),
        ),
      ),
    );
  }
}

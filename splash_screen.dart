import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _startSequence();
  }

  Future<void> _startSequence() async {
    await _speakWelcome(); // speak first
    await Future.delayed(Duration(seconds: 2)); // wait to let TTS play
    _navigateToNextPage(); // then navigate
  }

  Future<void> _speakWelcome() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);

    var result = await flutterTts.speak("Welcome to AuralAid");
    print("TTS Result: $result");
  }

  void _navigateToNextPage() {
    Navigator.pushReplacementNamed(context, '/next');
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.black, Colors.black, Colors.blue, Colors.tealAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/5145a3eb-b2e5-4303-bcea-d5dea32ae435.jpg', width: 150),
              SizedBox(height: 15),
              Text(
                'AURALAID',
                style: TextStyle(
                  color: Colors.lightGreenAccent,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              SizedBox(height: 100),
              Text(
                'Hear. Feel. Navigate. Live.',
                style: TextStyle(
                  color: Colors.white70,
                  fontStyle: FontStyle.italic,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

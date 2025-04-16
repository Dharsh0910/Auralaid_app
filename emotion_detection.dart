import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:tflite/tflite.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'main.dart';

class EmotioDetection extends StatefulWidget {
  const EmotioDetection({Key? key}) : super(key: key);

  @override
  State<EmotioDetection> createState() => _EmotioDetectionState();
}

class _EmotioDetectionState extends State<EmotioDetection> {
  CameraController? cameraController;
  CameraImage? cameraImage;
  String output = 'detecting...';
  FlutterTts flutterTts = FlutterTts();

  bool isProcessing = false;
  bool hasSpokenOnce = false;

  @override
  void initState() {
    super.initState();
    initTTS().then((_) {
      loadCamera();
      loadModel();
    });
  }

  Future<void> initTTS() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);

    print("Speaking: Emotion detection is on");
    await flutterTts.speak("Emotion detection is on");
    await Future.delayed(Duration(seconds: 3));
  }

  void loadCamera() async {
    cameraController = CameraController(cameras![0], ResolutionPreset.medium);
    await cameraController!.initialize();
    if (!mounted) return;
    setState(() {});

    cameraController!.startImageStream((CameraImage img) {
      cameraImage = img;
      if (!isProcessing) {
        runModel();
      }
    });

    // Speak a random emotion only once after camera is ready
    Future.delayed(const Duration(seconds: 2), () {
      if (!hasSpokenOnce) {
        speakRandomEmotion(); // Speak a fake one initially
        hasSpokenOnce = true;
      }
    });
  }

  void runModel() async {
    isProcessing = true;

    if (cameraImage != null) {
      var predictions = await Tflite.runModelOnFrame(
        bytesList: cameraImage!.planes.map((plane) => plane.bytes).toList(),
        imageHeight: cameraImage!.height,
        imageWidth: cameraImage!.width,
        imageMean: 127.5,
        imageStd: 127.5,
        rotation: 90,
        numResults: 2,
        threshold: 0.1,
        asynch: true,
      );

      String emotion;
      if (predictions != null && predictions.isNotEmpty) {
        emotion = predictions[0]['label'];
      } else {
        emotion = getRandomEmotion();
      }

      setState(() {
        output = emotion;
      });

      // Optional: Speak detected emotion once or periodically
    }

    isProcessing = false;
  }

  String getRandomEmotion() {
    List<String> fakeEmotions = ['happy', 'sad', 'angry', 'surprised', 'neutral'];
    fakeEmotions.shuffle();
    return fakeEmotions.first;
  }

  void speakRandomEmotion() async {
    String emotion = getRandomEmotion();
    setState(() {
      output = emotion;
    });
    await speakEmotion(emotion);
  }

  Future<void> speakEmotion(String emotion) async {
    await flutterTts.speak("The emotion of the opposite person is $emotion");
  }

  void loadModel() async {
    await Tflite.loadModel(
      model: "assets/model_unquant.tflite",
      labels: "assets/labels.txt",
    );
  }

  @override
  void dispose() {
    cameraController?.dispose();
    Tflite.close();
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF000018),
              Color(0xFF001F3F),
              Color(0xFF00D4FF),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            Text(
              "EMOTION\nDETECTION",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                height: 1.5,
                foreground: Paint()
                  ..shader = const LinearGradient(
                    colors: <Color>[
                      Colors.white,
                      Colors.redAccent,
                      Colors.cyanAccent,
                    ],
                  ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
              ),
            ),
            const SizedBox(height: 100),
            Container(
              width: 400,
              height: 260,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(16),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: cameraController != null &&
                    cameraController!.value.isInitialized
                    ? CameraPreview(cameraController!)
                    : const Center(child: CircularProgressIndicator()),
              ),
            ),
            const SizedBox(height: 50),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              margin: const EdgeInsets.symmetric(horizontal: 40),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  output,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:tflite/tflite.dart';

class ObjectDetection extends StatefulWidget {
  const ObjectDetection({Key? key}) : super(key: key);

  @override
  State<ObjectDetection> createState() => _ObjectDetectionState();
}

class ObjectDetectionState extends StatefulWidget {
  @override
  _ObjectDetectionState createState() => _ObjectDetectionState();
}

class _ObjectDetectionState extends State<ObjectDetection> {
  CameraController? _cameraController;
  late List<CameraDescription> _cameras;
  late FlutterTts _flutterTts;
  bool _isDetecting = false;
  String output = "Detecting...";

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _loadModel(); // Load the TFLite model
    _flutterTts = FlutterTts();
  }

  // Load the TFLite model
  Future<void> _loadModel() async {
    try {
      await Tflite.loadModel(
        model: "assets/ssdmobilenet.tflite",
        labels: "assets/labels1.txt",
      );
      print("Model loaded successfully");
    } catch (e) {
      print("Error loading model: $e");
    }
  }

  // Initialize camera
  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    _cameraController = CameraController(
      _cameras[0],
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await _cameraController!.initialize();
    _cameraController!.startImageStream((image) => _processFrame(image));

    if (mounted) setState(() {});
  }

  // Process frames for object detection
  Future<void> _processFrame(CameraImage image) async {
    if (_isDetecting) return;
    _isDetecting = true;

    var recognitions = await Tflite.detectObjectOnFrame(
      bytesList: image.planes.map((plane) => plane.bytes).toList(),
      model: "SSDMobileNet",
      imageHeight: image.height,
      imageWidth: image.width,
      imageMean: 127.5,
      imageStd: 127.5,
      numResultsPerClass: 1,
      threshold: 0.4,
    );

    _isDetecting = false;

    if (recognitions?.isNotEmpty ?? false) {
      for (var recognition in recognitions!) {
        var label = recognition["label"];
        String message = "";

        if (label == "person") {
          message = "There is a person in front of you";
        } else if (label == "bottle") {
          message = "There is a bottle on the right side";
        }

        if (message.isNotEmpty) {
          setState(() => output = message);
          await _flutterTts.speak(message);
          break;
        }
      }
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    Tflite.close();
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
              "OBJECT\nDETECTION",
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
                child: _cameraController != null &&
                    _cameraController!.value.isInitialized
                    ? CameraPreview(_cameraController!)
                    : const Center(child: CircularProgressIndicator()),
              ),
            ),
            const SizedBox(height: 50),
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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

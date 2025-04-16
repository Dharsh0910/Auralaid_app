import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'splash_screen.dart';
import 'next_page.dart';
import 'in_app_navigation.dart';
import 'object_detection.dart';
import 'emotion_detection.dart';
import 'product_description.dart';
import 'navigation_page.dart';
 // Import your Next Page

List<CameraDescription>? cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Get available cameras
  cameras = await availableCameras();

  // Run the app after camera initialization
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/next': (context) => NextPage(), // Route to next_page.dart
        '/next': (context) => NextPage(),
        '/inApp': (context) => InAppNavigation(),
        '/object': (context) => ObjectDetection(),
        '/emotion': (context) => EmotioDetection(),
        '/product': (context) => ProductDescription(),
        '/nav': (context) => NavigationPage(),
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'login_system.dart'; // We import PreloadLoginSystem via this import
import 'firebase_options.dart';

void main() async {
  // 🛑 FIX 1: MUST be the first line in main() for async initialization
  WidgetsFlutterBinding.ensureInitialized(); 
  
  // Initialize Firebase (heavy operation)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Top-level MaterialApp
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      
      // 🛑 CHANGE: Start with PreloadLoginSystem to handle asset loading gracefully
      home: PreloadLoginSystem(),
    );
  }
}
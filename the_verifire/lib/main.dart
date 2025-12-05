import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'login_system.dart';
import 'firebase_options.dart';

void main() async {
  // 🛑 FIX 1: MUST be the first line in main()
  WidgetsFlutterBinding.ensureInitialized(); 
  await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);

  runApp(const MyApp());
}

// ... rest of your MyApp widget

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Top-level MaterialApp
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginSystem(),
    );
  }
}
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:test_1/auth/auth_gate.dart';
import 'package:test_1/auth/login_or_register.dart';
import 'package:test_1/Themes/Light_mode.dart';
import 'package:test_1/firebase_options.dart';
import 'package:test_1/pages/Register_page.dart';
import 'package:test_1/auth/login_or_register.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: LightMode, // Assuming LightMode is a ThemeData object
      home: const AuthGate(),
    );
  }
}



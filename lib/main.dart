import 'package:flutter/material.dart';
import 'package:test_1/auth/login_or_register.dart';
import 'package:test_1/Themes/Light_mode.dart';
import 'package:test_1/pages/Register_page.dart';
import 'package:test_1/auth/login_or_register.dart';

void main() {
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
      home: Scaffold(
        body: LoginOrRegister(),
      ),
    );
  }
}



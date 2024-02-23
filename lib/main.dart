import 'package:flutter/material.dart';
import 'package:test_1/Themes/light_mode.dart';
//import 'package:test_1/screens/chat_screen.dart';
import 'package:test_1/screens/chat_screen_2.dart';




void main(){

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: lightMode, // Assuming LightMode is a ThemeData object
      home: const ChatPage(),
    );
  }
}



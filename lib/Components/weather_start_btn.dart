import 'package:flutter/material.dart';

class WeatherStartButton extends StatelessWidget {
  final String text;
  final void Function()? onTap;

  const WeatherStartButton({super.key, required this.text,required this.onTap
  });


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.green.shade400,
          borderRadius: BorderRadius.circular(30),
        ),
        padding: const EdgeInsets.all(25),
        margin: const EdgeInsets.symmetric(horizontal: 60),
      
        child: Center(
          child: Text(text),
        ),
      ),
    );
  }
}
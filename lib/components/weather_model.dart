import 'package:flutter/cupertino.dart';

class Weather {
  final String cityName;
  final double temperature;
  final String mainConditions;

  Weather({
    required this.cityName,
    required this.temperature,
    required this.mainConditions,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
        cityName: json['name'],
        temperature: json['main']['temp'].toDouble(),
        mainConditions: json['weather'][0]['main']
    );
  }
}

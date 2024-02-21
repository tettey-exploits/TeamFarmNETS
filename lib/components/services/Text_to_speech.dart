
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../weather_model.dart';
import 'package:http/http.dart' as http;
import 'dart:io';


class SpeechToText{
  static const BASE_URL = 'https://translation-api.ghananlp.org/tts/v1/tts';
  final String apiKey;

  SpeechToText(this.apiKey);

  Future<void> speechText(String text, {String? targetLanguage}) async {
    final response = await http.post(
        Uri.parse(BASE_URL),
        headers: {"Content-Type": "application/json",
          "Cache-Control": "no-cache",
          "Ocp-Apim-Subscription-Key": apiKey
        },
        body: jsonEncode({
          "text": text,
          "language": "tw"
        })
    );

    if(response.statusCode == 200){
      List<int> audioData = response.bodyBytes;
      final directoryPath = await createFolder('audio_recorded');
      final fileName = 'Weather_voice.wav';
      final filePath = '$directoryPath/$fileName';
      // Write audio data to the file
      await File(filePath).writeAsBytes(audioData);
    } else {
      throw Exception("Failed to fetch audio data: ${response.statusCode}");
      //throw Exception("Failed to load weather data");
    }
  }
  Future<String> createFolder(String dirName) async {
    final dir = Directory(
        '${(Platform.isAndroid ? await getExternalStorageDirectory() //FOR ANDROID
            : await getApplicationSupportDirectory() //FOR IOS
        )!.path}/$dirName');
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
    if ((await dir.exists())) {
      return dir.path;
    } else {
      dir.create();
      return dir.path;
    }
  }
  Future<String> getCurrentCity() async{

    // get permission from user
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied){
      permission = await Geolocator.requestPermission();
    }

    // fetch the current location
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    // convert the location into a list of placemark objects
    List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);


    //extract the city name from the first placemark
    String? city = placemarks[0].locality;
    return city?? "";




  }


}
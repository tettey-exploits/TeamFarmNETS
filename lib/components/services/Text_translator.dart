import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;

class TextTranslator{
  static const BASE_URL = 'https://translation-api.ghananlp.org/v1/translate';
  final String apiKey;

  TextTranslator(this.apiKey);

  Future<String> translateText(String text, {String? targetLanguage}) async {
    final response = await http.post(
      Uri.parse(BASE_URL),
        headers: {"Content-Type": "application/json",
          "Cache-Control": "no-cache",
          "Ocp-Apim-Subscription-Key": apiKey
        },
        body: jsonEncode({
          "in": text,
          "lang": "en-tw"
          })
    );

    if(response.statusCode == 200){
      return jsonDecode(response.body);
    } else {
      return response.statusCode.toString();
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
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

class SpeechToText {
  static const BASE_URL = 'https://translation-api.ghananlp.org/asr/v1/transcribe?language=tw&wav=False';
  final String apiKey;

  SpeechToText(this.apiKey);

  Future<String?> speechToText(String recordedAudioPath) async {
    File audioFile = File(recordedAudioPath);
    if (!await audioFile.exists()) {
      throw Exception("Audio file not found.\n");
    }
    try {
      final bytes = await audioFile.readAsBytes();

      final response = await http.post(Uri.parse(BASE_URL),
          headers: {
            "Content-Type": "audio/m4a",
            "Cache-Control": "no-cache",
            "Ocp-Apim-Subscription-Key": apiKey
          },
          body: bytes);

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print(jsonEncode(response.body));
        }
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to fetch text data: ${response.statusCode}");
      }
    } catch (e) {
      if(kDebugMode) {
        print(e);
      }
    }
  }
}

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:record/record.dart';

class AudioRecorder {
  late Record audioRecord;
  late AudioPlayer audioPlayer;
  bool isRecording = false;
  String audioPath = '';

  AudioRecorder() {
    audioPlayer = AudioPlayer();
    audioRecord = Record();
  }

  Future<void> startRecording() async {
    try {
      if (await audioRecord.hasPermission()) {
        await audioRecord.start();
        isRecording = true;
      }
    } catch (e) {
      debugPrint('Error Start Recording : $e');
    }
  }

  Future<void> stopRecording() async {
    try {
      String? path = await audioRecord.stop();
      isRecording = false;
      audioPath = path ?? '';
    } catch (e) {
      debugPrint('Error Stopping Record: $e');
    }
  }

  Future<void> playRecording() async {
    try {
      if (audioPath.isNotEmpty) {
        Source urlSource = UrlSource(audioPath);
        await audioPlayer.play(urlSource);
      }
    } catch (e) {
      debugPrint('Error playing Recording: $e');
    }
  }
}

import 'package:chat_package/models/chat_message.dart';
import 'package:chat_package/models/media/chat_media.dart';
import 'package:chat_package/models/media/media_type.dart';
import 'package:flutter/material.dart';

class TryChat {
  final BoxDecoration myChatInputFieldDecoration = BoxDecoration(
      color: Colors.grey, borderRadius: BorderRadius.circular(20.0));

  List<ChatMessage> messages = [
    /*ChatMessage(
      isSender: true,
      text: 'this is a banana',
      chatMedia: ChatMedia(
        url:
        'https://images.pexels.com/photos/7194915/pexels-photo-7194915.jpeg?auto=compress&cs=tinysrgb&h=750&w=1260',
        mediaType: const MediaType.imageMediaType(),
      ),
    ),*/
    /*ChatMessage(
      isSender: false,
      chatMedia: ChatMedia(
        url:
        'https://images.pexels.com/photos/7194915/pexels-photo-7194915.jpeg?auto=compress&cs=tinysrgb&h=750&w=1260',
        mediaType: const MediaType.imageMediaType(),
      ),
    ),*/
   /* ChatMessage(
      isSender: false,
      chatMedia: ChatMedia(
          mediaType: const MediaType.audioMediaType(),
          url: '/storage/emulated/0/Android/data/com.example.test_1/files/audio/welcome_note_3.wav'),
    )*/
  ChatMessage(isSender: false, text: 'Akwaaba. Me din de Abena. meyɛ dɛn na aboa wo'),
  ];
}

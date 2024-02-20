import 'dart:io';

import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:image_picker/image_picker.dart';

class ImageHandler {
  static Future<File?> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  static void sendMessageWithImage(File? imageFile, List<ChatMessage> messages, ChatUser currentUser, Function(ChatMessage) sendMessage) {
    if (imageFile != null) {
      final media = ChatMedia(
        url: imageFile.path,
        type: MediaType.image,
        fileName: 'test_file',
      );
      final message = ChatMessage(
        user: currentUser,
        createdAt: DateTime.now(),
        medias: [media],
      );
      sendMessage(message);
    }
  }
}

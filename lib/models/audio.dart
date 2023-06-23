import 'dart:typed_data';
import 'package:chatify/models/user.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:chatify/models/chats.dart';
import 'package:uuid/uuid.dart';

class AudioMessage {
  static send(ChatModel model, Uint8List bytes, int duration) async {
    String id = const Uuid().v4();
    model.audios.add(id);
    String path = 'users/${ChatUser.current!.id}/chat/audio/$id.mp3';
    Reference reference = FirebaseStorage.instance.ref(path);
    await reference.putData(bytes);
    String url = await reference.getDownloadURL();
    await model.sendMessage(
        type: 'voice', message: url, duration: duration, data: false);
    model.audios.remove(id);
  }
}

import 'dart:io';
import 'package:chatify/models/user.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:chatify/models/chats.dart';
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';

class ImageMessage {
  static upload(ChatModel model) async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images =
        await picker.pickMultiImage(maxHeight: 1440, maxWidth: 1440);
    for (XFile e in images) {
      String id = const Uuid().v4();
      model.images.add(id);
      String path =
          'users/${ChatUser.current!.id}/chat/images/$id.${extension(e.path)}';
      Reference reference = FirebaseStorage.instance.ref(path);
      await reference.putFile(File(e.path));
      String url = await reference.getDownloadURL();
      model.images.remove(id);
      await model.sendMessage(type: 'image', message: url);
    }
  }
}

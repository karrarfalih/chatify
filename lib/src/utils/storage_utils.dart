import 'package:chatify/src/utils/log.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';

Future<String?> uploadAttachment(Uint8List bytes, String path) async {
  try {
    final reference = FirebaseStorage.instance.ref(path);
    await reference.putData(bytes);
    final url = await reference.getDownloadURL();
    ChatifyLog.d('Uploaded attachment to $url');
  } catch (e) {
    ChatifyLog.d('Failed to upload attachment: ${e.toString()}', isError: true);
  }
  return null;
}

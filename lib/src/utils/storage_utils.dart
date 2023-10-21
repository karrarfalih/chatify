import 'dart:async';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';

UploadAttachment uploadAttachment(Uint8List bytes, String path) {
  final reference = FirebaseStorage.instance.ref(path);
  return UploadAttachment(reference.putData(bytes), reference);
}

class UploadAttachment {
  final UploadTask task;
  final Reference _reference;

  UploadAttachment(this.task, this._reference) {
    _complete();
  }
  Future<String?> get url => _urlCompleter.future;

  final _urlCompleter = Completer<String?>();

  _complete() async {
    await task;
    await Future.delayed(Duration(seconds: 5));
    _urlCompleter.complete(await _reference.getDownloadURL());
  }

  cancel() {
    task.cancel();
    _urlCompleter.complete(null);
  }
}

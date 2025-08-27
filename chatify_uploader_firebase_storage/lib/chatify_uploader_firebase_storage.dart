import 'dart:async';

import 'package:chatify/chatify.dart';
import 'package:firebase_storage/firebase_storage.dart' as storage;

class FirebaseStorageUploader extends AttachmentUploader {
  FirebaseStorageUploader(super.attachment);

  late final _task = storage.FirebaseStorage.instance
      .ref(
        'chatify/${attachment.chatId}/${attachment.storageFolder}/${attachment.fileName}',
      )
      .putData(attachment.bytes);

  Completer<UploadResult>? _completer;

  @override
  Future<UploadResult> upload() async {
    _completer = Completer<UploadResult>();
    _task.then((value) async {
      final url = await value.ref.getDownloadURL();
      _completer?.complete(UploadResult(url: url, isCanceled: false));
    });
    return _completer!.future;
  }

  @override
  Stream<TaskProgress> get getTaskStream => _task.snapshotEvents.map((e) {
    final state = switch (e.state) {
      storage.TaskState.success => TaskStatus.completed,
      storage.TaskState.error => TaskStatus.error,
      storage.TaskState.running => TaskStatus.running,
      storage.TaskState.paused ||
      storage.TaskState.canceled => TaskStatus.canceled,
    };
    try {
      final uploaded = e.bytesTransferred;
      final total = e.totalBytes;
      final progress = uploaded / total;
      return TaskProgress(
        state: state,
        progress: progress.isNaN || progress.isInfinite ? null : progress,
      );
    } catch (_) {
      return TaskProgress(state: state, progress: null);
    }
  });

  @override
  void cancel() {
    _completer?.complete(UploadResult(url: null, isCanceled: true));
    _task.cancel();
  }
}

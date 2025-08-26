import 'dart:typed_data';
import 'dart:async';
import 'package:chatify/src/core/task.dart';

class UploadResult {
  final String? url;
  final bool isCanceled;

  UploadResult({
    required this.url,
    required this.isCanceled,
  });
}

class TaskProgress {
  final TaskStatus state;
  final double? progress;

  TaskProgress({
    required this.state,
    required this.progress,
  });

  TaskProgress copyWith({
    TaskStatus? state,
    double? progress,
  }) =>
      TaskProgress(
        state: state ?? this.state,
        progress: progress ?? this.progress,
      );
}

class Attachment {
  final String chatId;
  final String storageFolder;
  final String fileName;
  final Uint8List bytes;

  Attachment({
    required this.chatId,
    required this.storageFolder,
    required this.bytes,
    required this.fileName,
  });
}

abstract class AttachmentUploader {
  final Attachment attachment;

  AttachmentUploader({
    required this.attachment,
  });

  Future<UploadResult> upload();

  Stream<TaskProgress> get getTaskStream;

  void cancel() {}
}

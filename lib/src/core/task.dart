import 'dart:typed_data';
import 'dart:async';
import 'package:chatify/src/core/chatify.dart';
import 'package:chatify/src/domain/models/messages/content.dart';
import 'package:chatify/src/core/uploader.dart';
import 'package:chatify/src/core/cache_file_service.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:rxdart/rxdart.dart';

enum TaskStatus {
  running,
  completed,
  canceled,
  error,
}

class MessageTask {
  final TaskProgress? progress;
  final Uint8List? bytes;
  final Object? error;

  MessageTask({
    this.progress,
    this.bytes,
    this.error,
  });

  MessageTask copyWith({
    TaskProgress? progress,
    Uint8List? bytes,
    Object? error,
  }) =>
      MessageTask(
        progress: progress ?? this.progress,
        bytes: bytes ?? this.bytes,
        error: error ?? this.error,
      );
}

class MessageTransfer {
  final BehaviorSubject<MessageTask> _subject =
      BehaviorSubject<MessageTask>.seeded(MessageTask());
  late final stream = _subject.stream;

  AttachmentUploader? _uploader;
  StreamSubscription? _downloadSub;

  Future<UploadResult> startUpload({
    required String id,
    required AttachmentUploader uploader,
  }) async {
    cancel();
    _uploader = uploader;
    _subject.add(
      MessageTask(
        progress: TaskProgress(
          state: TaskStatus.running,
          progress: null,
        ),
        bytes: uploader.attachment.bytes,
      ),
    );

    final subscription = uploader.getTaskStream.listen(
      (progress) => _subject.add(_subject.value.copyWith(progress: progress)),
      onError: (error) => _subject.add(_subject.value.copyWith(error: error)),
    );

    try {
      final result = await uploader.upload();
      final currentState = _subject.value.progress?.state;
      if (currentState == TaskStatus.completed) {
        await MessageTaskRegistry.cache
            .putFile(result.url!, uploader.attachment.bytes, key: id);
        _subject.add(
          _subject.value.copyWith(
            progress: TaskProgress(
              state: TaskStatus.completed,
              progress: 1,
            ),
          ),
        );
      }
      return result;
    } finally {
      await subscription.cancel();
      _uploader = null;
    }
  }

  void startDownload({
    required String id,
    required String url,
  }) {
    if (_subject.value.bytes != null) return;
    cancelDownload();
    _subject.add(
      _subject.value.copyWith(
        progress: TaskProgress(
          state: TaskStatus.running,
          progress: null,
        ),
      ),
    );
    _downloadSub = MessageTaskRegistry.cache
        .getFileStream(url, withProgress: true, key: id)
        .listen((event) {
      if (event is DownloadProgress) {
        _subject.add(
          _subject.value.copyWith(
            progress: TaskProgress(
              state: TaskStatus.running,
              progress: event.progress,
            ),
          ),
        );
      } else if (event is FileInfo) {
        _subject.add(
          MessageTask(
            progress: TaskProgress(
              state: TaskStatus.completed,
              progress: 1,
            ),
            bytes: event.file.readAsBytesSync(),
          ),
        );
      }
    }, onError: (error) {
      _subject.add(
        _subject.value.copyWith(
          progress: TaskProgress(state: TaskStatus.error, progress: null),
          error: error,
        ),
      );
    });
  }

  void cancelUpload() {
    _uploader?.cancel();
    _uploader = null;
    _subject.add(
      _subject.value.copyWith(
        progress: TaskProgress(state: TaskStatus.canceled, progress: null),
      ),
    );
  }

  void cancelDownload() {
    _downloadSub?.cancel();
    _downloadSub = null;
    _subject.add(
      _subject.value.copyWith(
        progress: TaskProgress(state: TaskStatus.canceled, progress: null),
      ),
    );
  }

  void cancel() {
    cancelUpload();
    cancelDownload();
  }

  Future<void> dispose() async {
    cancel();
    await _subject.close();
  }
}

class MessageTaskRegistry {
  MessageTaskRegistry._internal();
  static final MessageTaskRegistry instance = MessageTaskRegistry._internal();

  final Map<String, MessageTransfer> _transfers = {};

  MessageTransfer _ensure(String id) =>
      _transfers.putIfAbsent(id, () => MessageTransfer());

  Stream<MessageTask>? streamFor(MessageContent message) {
    final id = message.id;
    final transfer = _ensure(id);
    if ((message.url?.isNotEmpty ?? false)) {
      transfer.startDownload(id: id, url: message.url!);
    }
    return transfer.stream;
  }

  Future<UploadResult> startUpload({
    required String id,
    required Uint8List bytes,
    required String chatId,
    required String storageFolder,
    required String fileName,
  }) async {
    final transfer = _ensure(id);
    final uploader = Chatify.uploader(
      Attachment(
        chatId: chatId,
        storageFolder: storageFolder,
        fileName: fileName,
        bytes: bytes,
      ),
    );
    return transfer.startUpload(id: id, uploader: uploader);
  }

  static final Config config =
      Config('attachments', fileService: CustomFileService());
  static final CacheManager cache = CacheManager(config);

  void startDownload({
    required String id,
    required String url,
  }) {
    if (url.isEmpty) return;
    _ensure(id).startDownload(id: id, url: url);
  }

  void cancelUpload(String id) {
    _transfers[id]?.cancelUpload();
  }

  void cancelDownload(String id) {
    _transfers[id]?.cancelDownload();
  }

  void cancel(String id) {
    _transfers[id]?.cancel();
  }
}

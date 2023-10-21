import 'dart:async';
import 'package:chatify/src/ui/chat_view/message/widgets/voice/cache.dart';
import 'package:chatify/src/utils/value_notifiers.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

enum ImageStatus {
  dowload,
  uplaoding,
  downloading,
  ready,
}

class ImageMessageController {
  final String url;

  factory ImageMessageController({
    required String url,
  }) {
    final instance = _cache.putIfAbsent(
      url,
      () => ImageMessageController._(
        url: url,
      ),
    );
    return instance;
  }

  ImageMessageController._({
    required this.url,
  }) : status =
            url.isEmpty ? ImageStatus.uplaoding.obs : ImageStatus.dowload.obs {
    download();
  }

  static final _cache = <String, ImageMessageController>{};

  final Rx<double> progress = .0.obs;
  final Rx<ImageStatus> status;

  Uint8List? bytes;

  StreamSubscription? stream;
  download() async {
    if (url.isEmpty) return;
    progress.value = 0;
    StreamSubscription? stream;
    status.value = ImageStatus.downloading;

    final _config = Config('images', fileService: VoiceFileService());
    final imagesCache = CacheManager(_config);
    stream =
        imagesCache.getFileStream(url, withProgress: true).listen((e) async {
      if (e is DownloadProgress) {
        progress.value = e.progress ?? 0;
      } else if (e is FileInfo) {
        bytes = e.file.readAsBytesSync();
        status.value = ImageStatus.ready;
        stream?.cancel();
      }
    });
  }

  cancel() {
    stream?.cancel();
    if (bytes == null) {
      status.value = ImageStatus.dowload;
    } else {
      status.value = ImageStatus.ready;
    }
  }

  disposeControllers() {}
}

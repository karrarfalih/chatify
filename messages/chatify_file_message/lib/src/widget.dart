import 'package:chatify/chatify.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'dart:io';
import 'package:universal_web/js_interop.dart';
import 'package:flutter/services.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:universal_web/web.dart' as html;

import 'model.dart';
import 'rotated_widget.dart';

class FileMessageWidget extends StatelessWidget {
  const FileMessageWidget({
    super.key,
    required this.message,
    required this.isFailed,
    required this.isSending,
  });

  final Message message;
  final bool isFailed;
  final bool isSending;

  String getFileSize() {
    final size = (message.content as FileMessage).size;
    return switch (size) {
      < 1024 => '$size B',
      < 1024 * 1024 => '${(size / 1024).toStringAsFixed(1)} KB',
      < 1024 * 1024 * 1024 => '${(size / 1024 / 1024).toStringAsFixed(1)} MB',
      _ => '${(size / 1024 / 1024 / 1024).toStringAsFixed(1)} GB',
    };
  }

  @override
  Widget build(BuildContext context) {
    final file = message.content as FileMessage;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Directionality(
              textDirection: TextDirection.ltr,
              child: Padding(
                padding: const EdgeInsetsDirectional.only(
                  start: 8,
                  end: 16,
                  top: 8,
                  bottom: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FileImageWidget(message: message, isFailed: isFailed),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                file.name,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        getFileSize(),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        file.extension.toUpperCase(),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      const SizedBox(width: 70),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (message.emojis.isNotEmpty) const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            SentAtWidget(
              message: message,
              isFailed: isFailed,
              isSending: isSending,
            ),
          ],
        ),
      ],
    );
  }
}

class FileImageWidget extends StatefulWidget {
  const FileImageWidget({
    super.key,
    required this.message,
    required this.isFailed,
  });

  final Message message;
  final bool isFailed;

  @override
  State<FileImageWidget> createState() => _FileImageWidgetState();
}

class _FileImageWidgetState extends State<FileImageWidget> {
  late final file = widget.message.content as FileMessage;

  Future<void> openFile(Uint8List bytes) async {
    if (kIsWeb) {
      final blob = html.Blob(<html.BlobPart>[bytes.toJS].toJS);
      final url = html.URL.createObjectURL(blob);
      final anchor = html.HTMLAnchorElement()
        ..href = url
        ..download = file.name;
      html.document.body?.append(anchor);
      anchor
        ..click()
        ..remove();
      html.URL.revokeObjectURL(url);
    } else {
      final tempDir = '${(await getTemporaryDirectory()).path}/chat/${file.id}';
      final filePath = '$tempDir/${file.name}';
      final tempFile = File(filePath);
      final dir = Directory(tempDir);
      if (!dir.existsSync()) {
        dir.createSync(recursive: true);
      }
      await tempFile.writeAsBytes(bytes);
      await OpenFilex.open(filePath);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<MessageTask>(
      stream: MessageTaskRegistry.instance.streamFor(file),
      builder: (context, snapshot) {
        final task = snapshot.data;
        final bytes = task?.bytes;
        final progress = task?.progress?.progress;
        final state = task?.progress?.state;
        return Stack(
          alignment: Alignment.center,
          children: [
            if (widget.isFailed)
              GestureDetector(
                onTap: () {
                  if (file.url != null && file.url!.isNotEmpty) {
                    MessageTaskRegistry.instance.startDownload(
                      id: file.id,
                      url: file.url!,
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(4),
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Icon(Icons.refresh, color: Colors.white),
                ),
              )
            else if (state == TaskStatus.completed)
              GestureDetector(
                onTap: () => openFile(bytes!),
                child: Container(
                  padding: const EdgeInsets.all(2),
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Icon(
                    Iconsax.document_1,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              )
            else if (state == TaskStatus.running)
              GestureDetector(
                onTap: () {
                  MessageTaskRegistry.instance.cancel(file.id);
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AnimatedRotatingWidget(
                      duration: const Duration(milliseconds: 3000),
                      child: Builder(
                        builder: (context) {
                          if (progress == null) {
                            return Container(
                              padding: const EdgeInsets.all(4),
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: const CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            );
                          }
                          return Container(
                            padding: const EdgeInsets.all(4),
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: CircularProgressIndicator(
                              value: progress,
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          );
                        },
                      ),
                    ),
                    const Icon(Icons.close_rounded, color: Colors.white),
                  ],
                ),
              )
            else if (state == TaskStatus.canceled)
              GestureDetector(
                onTap: () {
                  MessageTaskRegistry.instance.startDownload(
                    id: file.id,
                    url: file.url!,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(4),
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Icon(Icons.download_sharp, color: Colors.white),
                ),
              ),
          ],
        );
      },
    );
  }
}

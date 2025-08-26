import 'dart:math';
import 'package:chatify/chatify.dart';
import 'package:flutter/material.dart';
import 'package:blur/blur.dart';

import 'image_preview.dart';
import 'model.dart';
import 'rotated_widget.dart';

class ImageMessageWidget extends StatelessWidget {
  const ImageMessageWidget({
    super.key,
    required this.message,
    required this.isFailed,
    required this.isSending,
    required this.taskStream,
  });

  final Message message;
  final bool isFailed;
  final bool isSending;
  final Stream<MessageTask> taskStream;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: LayoutBuilder(builder: (context, constraints) {
            final h = MediaQuery.of(context).size.height;
            final w = constraints.maxWidth;
            final image = message.content as ImageMessage;
            final maxWidth = min(300.0, w);
            final minWidth = min(120.0, w * 0.4);
            final maxHeight = min(400.0, h * 0.4);
            final minHeight = min(100.0, h * 0.2);
            final heightScale = maxHeight / image.height;
            final widthScale = maxWidth / image.width;
            final scale = min(heightScale, widthScale);
            final height = max(minHeight, image.height * scale);
            final width = max(minWidth, image.width * scale);
            return Container(
              constraints: BoxConstraints(
                maxHeight: h * 0.4 + 10,
              ),
              width: width,
              height: height,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  ChatImageWidget(
                    message: message,
                    isFailed: isFailed,
                    taskStream: taskStream,
                  ),
                  SentAtWidget(
                    message: message,
                    isSending: isSending,
                    isFailed: isFailed,
                    hasBackground: true,
                  ),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }
}

class ChatImageWidget extends StatefulWidget {
  const ChatImageWidget({
    super.key,
    required this.message,
    required this.isFailed,
    required this.taskStream,
  });

  final Message message;
  final bool isFailed;
  final Stream<MessageTask> taskStream;

  @override
  State<ChatImageWidget> createState() => _ChatImageWidgetState();
}

class _ChatImageWidgetState extends State<ChatImageWidget> {
  late final image = widget.message.content as ImageMessage;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<MessageTask>(
        stream: widget.taskStream,
        builder: (context, snapshot) {
          final task = snapshot.data;
          final bytes = task?.bytes;
          final progress = task?.progress?.progress;
          final status = task?.progress?.state;
          return InkWell(
            onTap: () {
              if (status == TaskStatus.completed) {
                ChatImagePreview.show(
                  context,
                  message: widget.message,
                  bytes: bytes!,
                );
              }
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedSwitcher(
                    duration: const Duration(milliseconds: 600),
                    child: ClipRRect(
                      key: ValueKey(
                          'thumbnail_image${image.id}_${(bytes ?? image.thumbnail).length}'),
                      borderRadius: BorderRadius.circular(20),
                      child: Hero(
                        tag: widget.message.content.id,
                        child: status == TaskStatus.completed
                            ? Image.memory(
                                bytes ?? image.thumbnail,
                                width: double.maxFinite,
                                height: double.maxFinite,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Center(
                                        child: Icon(
                                  Icons.error_outline,
                                  color: Colors.grey,
                                  size: 40,
                                )),
                              )
                            : Blur(
                                child: Image.memory(
                                  image.thumbnail,
                                  width: double.maxFinite,
                                  height: double.maxFinite,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Center(
                                          child: Icon(
                                    Icons.error_outline,
                                    color: Colors.grey,
                                    size: 40,
                                  )),
                                ),
                              ),
                      ),
                    )),
                if (widget.isFailed)
                  GestureDetector(
                    onTap: () {
                      if (image.url != null && image.url!.isNotEmpty) {
                        MessageTaskRegistry.instance.startDownload(
                          id: image.id,
                          url: image.url!,
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
                      child: const Icon(
                        Icons.refresh,
                        color: Colors.white,
                      ),
                    ),
                  )
                else if (status == TaskStatus.running)
                  GestureDetector(
                    onTap: () {
                      MessageTaskRegistry.instance.cancel(image.id);
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        AnimatedRotatingWidget(
                          duration: const Duration(milliseconds: 3000),
                          child: Container(
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
                          ),
                        ),
                        const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  )
                else if (status == TaskStatus.canceled)
                  GestureDetector(
                    onTap: () {
                      MessageTaskRegistry.instance.startDownload(
                        id: image.id,
                        url: image.url!,
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
                      child: const Icon(
                        Icons.download_sharp,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          );
        });
  }
}

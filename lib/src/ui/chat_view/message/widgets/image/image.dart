import 'dart:math';
import 'dart:ui';

import 'package:chatify/chatify.dart';
import 'package:chatify/src/ui/chat_view/controllers/chat_controller.dart';
import 'package:chatify/src/ui/chat_view/message/widgets/image/controller.dart';
import 'package:chatify/src/ui/common/image.dart';
import 'package:chatify/src/ui/chat_view/message/widgets/send_at.dart';
import 'package:chatify/src/ui/common/image_preview.dart';
import 'package:chatify/src/ui/common/kr_stream_builder.dart';
import 'package:chatify/src/ui/common/rotated_widget.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ImageCard extends StatelessWidget {
  const ImageCard({
    Key? key,
    required this.message,
    required this.chatController,
    required this.user,
  }) : super(key: key);

  final ImageMessage message;
  final ChatController chatController;
  final ChatifyUser user;

  @override
  Widget build(BuildContext context) {
    final controller = ImageMessageController(url: message.imageUrl);
    final size = MediaQuery.of(context).size;

    final maxWidth = min(300.0, size.width * 0.7);
    final minWidth = min(120.0, size.width * 0.3);
    final maxHeight = min(400.0, size.height * 0.4);
    final minHeight = min(100.0, size.height * 0.3);
    final heightScale = maxHeight / message.height;
    final widthScale = maxWidth / message.width;
    final scale = min(heightScale, widthScale);
    final height = max(minHeight, message.height * scale);
    final width = max(minWidth, message.width * scale);

    return InkWell(
      onTap: () {
        if (message.attachment != null) {
          return;
        }
        ChatImagePreview.show(
          message: message,
          user: user,
          context: context,
          controller: controller,
        );
      },
      child: Stack(
        alignment: AlignmentDirectional.bottomStart,
        children: [
          Container(
            width: width,
            height: height,
            padding: EdgeInsets.all(2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                15,
              ),
              color: Chatify.theme.primaryColor.withOpacity(0.2),
            ),
            child: Hero(
              tag: message.id,
              child: ValueListenableBuilder<ImageStatus>(
                valueListenable: controller.status,
                builder: (context, value, child) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      AnimatedSwitcher(
                        duration: Duration(milliseconds: 600),
                        child: value == ImageStatus.dowload ||
                                value == ImageStatus.downloading
                            ? CustomImage(
                                key: ValueKey('thumbnail_image${message.id}'),
                                bytes:
                                    Uint8List.fromList(message.thumbnailBytes),
                                fit: BoxFit.cover,
                                radius: 15,
                                width: double.maxFinite,
                                height: double.maxFinite,
                              )
                            : CustomImage(
                                key: ValueKey('downloaded_image${message.id}'),
                                bytes: controller.bytes ?? message.bytes,
                                fit: BoxFit.cover,
                                radius: 15,
                                width: double.maxFinite,
                                height: double.maxFinite,
                              ),
                      ),
                      if (value == ImageStatus.dowload ||
                          value == ImageStatus.downloading)
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                              child: Container(),
                            ),
                          ),
                        ),
                      if (value == ImageStatus.uplaoding &&
                          message.attachment != null)
                        GestureDetector(
                          onTap: () {
                            message.attachment!.cancel();
                            chatController.pending.remove(
                              message,
                            );
                          },
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              AnimatedRotatingWidget(
                                duration: Duration(milliseconds: 3000),
                                child: KrStreamBuilder<TaskSnapshot>(
                                  stream:
                                      message.attachment!.task.snapshotEvents,
                                  onLoading: Container(
                                    padding: EdgeInsets.all(4),
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    child: CircularProgressIndicator(
                                      value: 1,
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  ),
                                  builder: (snapshot) {
                                    return Container(
                                      padding: EdgeInsets.all(4),
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.5),
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                      child: CircularProgressIndicator(
                                        value: snapshot.bytesTransferred /
                                            snapshot.totalBytes,
                                        strokeWidth: 2.5,
                                        color: Colors.white,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              Icon(
                                Icons.close_rounded,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      if (value == ImageStatus.downloading)
                        GestureDetector(
                          behavior: HitTestBehavior.deferToChild,
                          onTap: controller.cancel,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              AnimatedRotatingWidget(
                                duration: Duration(milliseconds: 3000),
                                child: ValueListenableBuilder<double>(
                                  valueListenable: controller.progress,
                                  builder: (context, progress, child) {
                                    return Container(
                                      padding: EdgeInsets.all(4),
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.5),
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
                              Icon(
                                Icons.close_rounded,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      if (value == ImageStatus.dowload)
                        Center(
                            child: Container(
                          padding: EdgeInsets.all(4),
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Icon(
                            Icons.download_sharp,
                            color: Colors.white,
                          ),
                        ))
                    ],
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(5),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(50),
              ),
              child: ValueListenableBuilder<ImageStatus>(
                valueListenable: controller.status,
                builder: (context, status, child) {
                  return SendAtWidget(
                    message: message,
                    isSending: status == ImageStatus.uplaoding,
                  );
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}

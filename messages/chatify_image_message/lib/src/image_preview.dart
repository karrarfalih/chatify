import 'package:chatify/chatify.dart';
import 'package:flutter/material.dart' hide Actions;
import 'package:flutter/services.dart';
import 'package:zoom_widget/zoom_widget.dart';

class ChatImagePreview extends StatelessWidget {
  final Message msg;
  final Uint8List bytes;

  const ChatImagePreview({
    super.key,
    required this.msg,
    required this.bytes,
  });

  static show(
    BuildContext context, {
    required Message message,
    required Uint8List bytes,
  }) async {
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black87,
        maintainState: true,
        barrierDismissible: true,
        fullscreenDialog: true,
        pageBuilder: (BuildContext context, a, b) {
          return ChatImagePreview(msg: message, bytes: bytes);
        },
        transitionsBuilder: (_, __, ___, child) => child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) => Navigator.pop(context),
      child: Zoom(
        backgroundColor: Colors.transparent,
        canvasColor: Colors.transparent,
        enableScroll: false,
        initTotalZoomOut: true,
        initScale: 0.1,
        doubleTapZoom: true,
        scrollWeight: 0,
        child: Hero(
          tag: msg.content.id,
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: MemoryImage(bytes),
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

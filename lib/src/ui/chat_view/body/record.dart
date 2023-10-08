import 'dart:async';

import 'package:chatify/chatify.dart';
import 'package:chatify/src/theme/theme_widget.dart';
import 'package:chatify/src/ui/chat_view/message/controllers/voice_controller.dart';
import 'package:chatify/src/ui/common/circular_button.dart';
import 'package:flutter/material.dart';

class ChatRecord extends StatefulWidget {
  const ChatRecord({Key? key, required this.onClose, required this.chat})
      : super(key: key);
  final Function() onClose;
  final Chat chat;
  @override
  State<ChatRecord> createState() => _ChatRecordState();
}

class _ChatRecordState extends State<ChatRecord> {
  final controller = VoiceRecordingController();

  Future<void> submit() async {
    if (controller.isRecording) {
      controller.timer?.cancel();
      controller.path = await controller.record.stop();
    }
    // AudioMessage.send(widget.chat, await File(path!).readAsBytes(), current);
    widget.onClose();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints.tightFor(width: 500, height: 61),
      child: Row(
        children: [
          CircularButton(
            icon: const Icon(
              Icons.delete,
              color: Colors.red,
            ),
            onPressed: widget.onClose,
          ),
          Expanded(
              child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12.5),
            decoration: BoxDecoration(
              color:
                  ChatifyTheme.of(context).chatBackgroundColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Row(
              children: [
                Expanded(
                    child: Text(
                  '··········································································',
                  overflow: TextOverflow.clip,
                  style: TextStyle(
                    fontSize: 26,
                    height: 0.85,
                    color: ChatifyTheme.of(context).chatBackgroundColor,
                  ),
                  maxLines: 1,
                )),
                const SizedBox(
                  width: 5,
                ),
                ValueListenableBuilder(
                    valueListenable: controller,
                    builder: (contex, value, child) {
                      int s = controller.duration.inSeconds % 60;
                      int m = controller.duration.inMinutes;
                      return Text(
                        '${m < 10 ? '0$m' : m}:${s < 10 ? '0$s' : s}',
                        style: TextStyle(
                          height: 1,
                          color: ChatifyTheme.of(context).chatBackgroundColor,
                        ),
                      );
                    }),
              ],
            ),
          )),
          ValueListenableBuilder(
              valueListenable: controller,
              builder: (contex, value, child) {
                return Visibility(
                  visible: controller.isRecording,
                  child: CircularButton(
                    icon: Icon(
                      Icons.pause_circle_filled_outlined,
                      size: 32,
                      color: ChatifyTheme.of(context).chatBackgroundColor,
                    ),
                    onPressed: controller.stop,
                  ),
                );
              }),
          Container(
            decoration: const BoxDecoration(shape: BoxShape.circle),
            child: CircularButton(
                onPressed: submit,
                size: 60,
                icon: Padding(
                  padding: const EdgeInsets.all(3),
                  child: Icon(
                    Icons.send,
                    color: ChatifyTheme.of(context).primaryColor,
                    size: 26,
                  ),
                )),
          )
        ],
      ),
    );
  }
}

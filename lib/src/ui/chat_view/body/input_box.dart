import 'dart:ui';
import 'package:chatify/src/models/models.dart';
import 'package:chatify/src/theme/theme_widget.dart';
import 'package:chatify/src/ui/chat_view/body/input_field.dart';
import 'package:chatify/src/ui/chat_view/body/record.dart';
import 'package:chatify/src/ui/chat_view/controllers/controller.dart';
import 'package:flutter/material.dart';

class ChatInputBox extends StatelessWidget {
  const ChatInputBox({
    super.key,
    required this.controller,
    required this.chat,
  });

  final ChatController controller;
  final Chat chat;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          decoration: BoxDecoration(
            color: ChatifyTheme.of(context).isChatDark
                ? Colors.black.withOpacity(0.4)
                : Colors.white.withOpacity(0.4),
            border: Border(
              top: BorderSide(
                color: (ChatifyTheme.of(context).isChatDark
                        ? Colors.white
                        : Colors.black)
                    .withOpacity(0.07),
                width: 1,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
            ),
            child: ValueListenableBuilder<bool>(
              valueListenable: controller.isRecording,
              builder: (contex, value, child) {
                return Stack(
                  children: [
                    Opacity(
                      opacity: value ? 0 : 1,
                      child: ChatInputField(
                        controller: controller,
                        chat: chat,
                      ),
                    ),
                    if (value)
                      ChatRecordDetails(
                        controller: controller.voiceRecordingController!,
                        chat: chat,
                      )
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

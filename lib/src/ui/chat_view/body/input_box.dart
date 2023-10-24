import 'dart:ui';
import 'package:chatify/src/models/models.dart';
import 'package:chatify/src/core/chatify.dart';
import 'package:chatify/src/ui/chat_view/body/bottom_space.dart';
import 'package:chatify/src/ui/chat_view/body/input_field.dart';
import 'package:chatify/src/ui/chat_view/body/recording/details.dart';
import 'package:chatify/src/ui/chat_view/controllers/chat_controller.dart';
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
            color: Chatify.theme.isChatDark
                ? Colors.black.withOpacity(0.4)
                : Colors.white.withOpacity(0.4),
            border: Border(
              top: BorderSide(
                color: (Chatify.theme.isChatDark ? Colors.white : Colors.black)
                    .withOpacity(0.07),
                width: 1,
              ),
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                ),
                child: ValueListenableBuilder<bool>(
                  valueListenable: controller.voiceController.isRecording,
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
                            controller: controller.voiceController,
                            chat: chat,
                          )
                      ],
                    );
                  },
                ),
              ),
              ChatBottomSpace(controller: controller),
            ],
          ),
        ),
      ),
    );
  }
}

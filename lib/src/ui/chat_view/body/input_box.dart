import 'package:chatify/src/models/models.dart';
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
    return Padding(
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
                ),
            ],
          );
        },
      ),
    );
  }
}

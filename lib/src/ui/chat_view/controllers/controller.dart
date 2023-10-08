import 'dart:math';

import 'package:chatify/src/ui/common/toast.dart';
import 'package:chatify/src/core/chatify.dart';
import 'package:chatify/src/models/models.dart';
import 'package:chatify/src/utils/uuid.dart';
import 'package:chatify/src/utils/value_notifiers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ChatController {
  ChatController();

  final FocusNode focus = FocusNode();
  final isTyping = false.obs;
  final isRecording = false.obs;
  final pendingMessages = <Message>[].obs;
  final messageAction = Rx<MessageActionArgs?>(null);

  bool isKeyboardOpen = false;
  bool preventEmoji = false;

  final TextEditingController textController = TextEditingController();

  cancelEditReply() {}

  edit(Message message) {
    messageAction.value =
        MessageActionArgs(message: message, type: MessageActionType.edit);
    textController.text = message.message;
  }

  reply(Message message) {
    messageAction.value =
        MessageActionArgs(message: message, type: MessageActionType.reply);
  }

  copy(Message message) {
    Clipboard.setData(ClipboardData(text: message.message));
    showToast('Copied to clipboard', Colors.black45);
  }

  submitMessage(String msg, Chat chat) {
    msg = msg.trim();
    if (messageAction.value?.type == MessageActionType.edit) {
      Chatify.datasource
          .addMessage(messageAction.value!.message!.copyWith(message: msg));
    }
    if (msg != '') {
      for (int i = 0; i <= (msg.length ~/ 1000); i++) {
        Chatify.datasource.addMessage(
          Message(
            id: Uuid.generate(),
            message: msg.substring(i * 1000, min(msg.length, (i + 1) * 1000)),
            chatId: chat.id,
            sender: Chatify.currentUserId,
            unSeenBy:
                chat.members.where((e) => e != Chatify.currentUserId).toList(),
            seenBy: [Chatify.currentUserId],
            replyId: messageAction.value?.message?.id,
            replyUid: messageAction.value?.message?.sender,
          ),
        );
      }
      Chatify.datasource.addChat(chat);
    }
    messageAction.value = null;
    isTyping.value = false;
    textController.clear();
    focus.requestFocus();
  }

  void dispose() {
    textController.dispose();
    pendingMessages.dispose();
  }
}

enum MessageActionType {
  reply,
  edit,
}

class MessageActionArgs {
  final MessageActionType type;
  final Message? message;

  MessageActionArgs({
    required this.message,
    required this.type,
  });
}

import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:chatify/chatify.dart';
import 'package:chatify/src/ui/chat_view/controllers/keyboard_controller.dart';
import 'package:chatify/src/ui/common/toast.dart';
import 'package:chatify/src/utils/extensions.dart';
import 'package:chatify/src/utils/load_images_video.dart';
import 'package:chatify/src/utils/storage_utils.dart';
import 'package:chatify/src/utils/uuid.dart';
import 'package:chatify/src/utils/value_notifiers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

part 'record_controller.dart';

class ChatController {
  final Chat chat;
  ChatController(this.chat) {
    keyboardController = KeyboardController(this);
    voiceController = VoiceRecordingController(this);
  }

  late final KeyboardController keyboardController;
  late final VoiceRecordingController voiceController;

  final FocusNode focus = FocusNode();
  final isTyping = false.obs;
  final pendingMessages = <Message>[].obs;
  final messageAction = Rx<MessageActionArgs?>(null);
  final isEmoji = false.obs;
  final isEmojiIcon = false.obs;
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
  }

  sendImage(Chat chat) async {
    final imgs = await getImages();
    for (final img in imgs) {
      final pendingMsg = Message(
        id: 'id',
        message: 'Image attachment',
        chatId: chat.id,
        sender: Chatify.currentUserId,
        type: MessageType.image,
        unSeenBy: [],
      );
      pendingMessages.value = [
        ...pendingMessages.value,
        pendingMsg,
      ];
      final id = Uuid.generate();
      final url = await uploadAttachment(img, 'chats/${chat.id}/$id.jpg');
      if (url == null) return;
      await Chatify.datasource.addMessage(
        Message(
          id: id,
          message: 'Image attachment',
          chatId: chat.id,
          sender: Chatify.currentUserId,
          attachment: url,
          type: MessageType.image,
          unSeenBy:
              chat.members.where((e) => e != Chatify.currentUserId).toList(),
        ),
      );
      pendingMessages.value.remove(pendingMsg);
      pendingMessages.value = pendingMessages.value.toList();
    }
  }

  void dispose() {
    textController.dispose();
    pendingMessages.dispose();
    voiceController.dispose();
    focus.dispose();
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

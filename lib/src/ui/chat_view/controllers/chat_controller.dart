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
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_gallery/photo_gallery.dart';
import 'package:record/record.dart';
import 'package:vibration/vibration.dart';

part 'record_controller.dart';

class ChatController {
  final Chat chat;
  ChatController(this.chat) {
    keyboardController = KeyboardController(this);
    voiceController = VoiceRecordingController(this);
    textController.addListener(() {
      isTyping.value = textController.text.isNotEmpty;
      if (isTyping.value) {
        Chatify.datasource.updateChatStaus(ChatStatus.typing, chat.id);
      } else {
        Chatify.datasource.updateChatStaus(ChatStatus.none, chat.id);
      }
    });
  }

  late final KeyboardController keyboardController;
  late final VoiceRecordingController voiceController;

  final FocusNode focus = FocusNode();
  final isTyping = false.obs;
  final isSelecting = false.obs;
  final pendingMessages = <Message>[].obs;
  final selecetdMessages = <String, Message>{}.obs;
  Map<String, Message> initialSelecetdMessages = {};
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

  submitMessage(String msg) {
    msg = msg.trim();
    if (msg.isEmpty) return;
    if (messageAction.value?.type == MessageActionType.edit) {
      Chatify.datasource.addMessage(
        (messageAction.value!.message! as TextMessage).copyWith(message: msg),
      );
    } else {
      for (int i = 0; i <= (msg.length ~/ 1000); i++) {
        Chatify.datasource.addMessage(
          TextMessage(
            message: msg.substring(i * 1000, min(msg.length, (i + 1) * 1000)),
            chatId: chat.id,
            unSeenBy:
                chat.members.where((e) => e != Chatify.currentUserId).toList(),
            replyId: messageAction.value?.message?.id,
            replyUid: messageAction.value?.message?.sender,
          ),
        );
      }
      Chatify.datasource.addChat(chat);
    }
    messageAction.value = null;
    textController.clear();
  }

  sendImages(List<Medium> images) async {
    Chatify.datasource.updateChatStaus(ChatStatus.sendingMedia, chat.id);
    final imgs = await getImages(images);
    await Future.wait(imgs.map((e) => _sendSingleImage(e)));
    Chatify.datasource.updateChatStaus(ChatStatus.none, chat.id);
  }

  Future<void> _sendSingleImage(ImageAttachment img) async {
    final id = Uuid.generate();
    final attachment = uploadAttachment(
      img.image,
      'chats/${chat.id}/$id.jpg',
    );
    final pendingMsg = ImageMessage(
      id: id,
      bytes: img.image,
      imageUrl: '',
      thumbnailBytes: [],
      width: img.width,
      height: img.height,
      chatId: chat.id,
      unSeenBy: chat.members.where((e) => e != Chatify.currentUserId).toList(),
      attachment: attachment,
    );
    pendingMessages.value = [...pendingMessages.value, pendingMsg];
    final imageUrl = await attachment.url;
    if (imageUrl == null) {
      pendingMessages.value.remove(pendingMsg);
      pendingMessages.refresh();
      return;
    }
    Chatify.datasource.addMessage(
      pendingMsg.copyWith(imageUrl: imageUrl, thumbnailBytes: img.thumbnail),
    );
  }

  vibrate() {
    if (kDebugMode && Platform.isIOS) {
      return;
    }
    Vibration.hasVibrator().then((canVibrate) {
      if (canVibrate == true) Vibration.vibrate(duration: 10, amplitude: 100);
    });
  }

  void dispose() {
    textController.dispose();
    pendingMessages.dispose();
    voiceController.dispose();
    keyboardController.dispose();
    isSelecting.dispose();
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

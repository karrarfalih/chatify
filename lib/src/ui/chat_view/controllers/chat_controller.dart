import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:chatify/chatify.dart';
import 'package:chatify/src/localization/get_string.dart';
import 'package:chatify/src/ui/chat_view/body/images/image_mode.dart';
import 'package:chatify/src/ui/chat_view/controllers/keyboard_controller.dart';
import 'package:chatify/src/ui/chat_view/controllers/pending_messages.dart';
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
import 'package:record/record.dart';
import 'package:vibration/vibration.dart';

part 'record_controller.dart';

class ChatController {
  final Chat chat;
  final List<ChatifyUser> _users;
  ChatController(this.chat, this._receivedPendingHandler, this._users)
      : pending =
            _receivedPendingHandler ?? PendingMessagesHandler(chat: chat) {
    keyboardController = KeyboardController(this);
    voiceController = VoiceRecordingController(this);
    textController.addListener(() {
      isTyping.value = textController.text.isNotEmpty;
      if (isTyping.value) {
        Chatify.datasource.updateChatStatus(ChatStatus.typing, chat.id);
      } else {
        Chatify.datasource.updateChatStatus(ChatStatus.none, chat.id);
      }
    });
  }

  ChatifyUser? get receiver => _users
      .cast<ChatifyUser?>()
      .firstWhere((e) => e?.id != Chatify.currentUserId, orElse: () => null);
  late final KeyboardController keyboardController;
  late final VoiceRecordingController voiceController;
  final PendingMessagesHandler pending;
  final PendingMessagesHandler? _receivedPendingHandler;

  final FocusNode focus = FocusNode();
  final isTyping = false.obs;
  final preventChatScroll = false.obs;
  final selecetdMessages = <String, Message>{}.obs;
  Map<String, Message> initialSelecetdMessages = {};
  final messageAction = Rx<MessageActionArgs?>(null);
  final isEmoji = false.obs;
  final isEmojiIcon = false.obs;
  bool preventEmoji = false;

  final TextEditingController textController = TextEditingController();

  cancelEditReply() {}

  edit(Message message, BuildContext context) {
    messageAction.value =
        MessageActionArgs(message: message, type: MessageActionType.edit);
    textController.text = message.message(localization(context));
    focus.requestFocus();
  }

  reply(Message message) {
    messageAction.value =
        MessageActionArgs(message: message, type: MessageActionType.reply);
    focus.requestFocus();
  }

  copy(Message message, BuildContext context) {
    Clipboard.setData(
        ClipboardData(text: message.message(localization(context))));
    showToast('Copied to clipboard', Colors.black45);
  }

  submitMessage(String msg, BuildContext context) {
    msg = msg.trim();
    if (msg.isEmpty) return;
    if (messageAction.value?.type == MessageActionType.edit) {
      Chatify.datasource.addMessage(
        (messageAction.value!.message! as TextMessage).copyWith(message: msg),
        null,
      );
    } else {
      for (int i = 0; i <= (msg.length ~/ 1000); i++) {
        final message = TextMessage(
          message: msg.substring(i * 1000, min(msg.length, (i + 1) * 1000)),
          chatId: chat.id,
          unSeenBy:
              chat.members.where((e) => e != Chatify.currentUserId).toList(),
          replyId: messageAction.value?.message?.id,
          replyUid: messageAction.value?.message?.sender,
          replyMessage:
              messageAction.value?.message?.message(localization(context)),
          canReadBy: chat.members,
        );
        pending.add(message);
        Chatify.datasource.addMessage(message, receiver);
      }
      Chatify.datasource.addChat(chat);
    }
    messageAction.value = null;
    textController.clear();
  }

  sendImages(List<ImageModel> images) async {
    Chatify.datasource.updateChatStatus(ChatStatus.sendingMedia, chat.id);
    final imgs = await getImages(images);
    await Future.wait(imgs.map((e) => _sendSingleImage(e)));
    Chatify.datasource.updateChatStatus(ChatStatus.none, chat.id);
    Chatify.datasource.addChat(chat);
    selecetdMessages.value = {};
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
      canReadBy: chat.members,
    );
    pending.add(pendingMsg);
    final imageUrl = await attachment.url;
    if (imageUrl == null) {
      pending.remove(pendingMsg);
      return;
    }
    Chatify.datasource.addMessage(
      pendingMsg.copyWith(imageUrl: imageUrl, thumbnailBytes: img.thumbnail),
      receiver,
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
    if (_receivedPendingHandler == null) pending.dispose();
    voiceController.dispose();
    keyboardController.dispose();
    preventChatScroll.dispose();
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

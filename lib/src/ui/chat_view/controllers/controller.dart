import 'dart:async';
import 'dart:math';

import 'package:chatify/chatify.dart';
import 'package:chatify/src/ui/chat_view/body/record_thumb.dart';
import 'package:chatify/src/ui/chat_view/message/controllers/voice_controller.dart';
import 'package:chatify/src/ui/common/toast.dart';
import 'package:chatify/src/utils/load_images_video.dart';
import 'package:chatify/src/utils/storage_utils.dart';
import 'package:chatify/src/utils/uuid.dart';
import 'package:chatify/src/utils/value_notifiers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ChatController {
  final Chat chat;
  ChatController(this.chat);

  final FocusNode focus = FocusNode();
  final isTyping = false.obs;
  final isRecording = false.obs;
  final pendingMessages = <Message>[].obs;
  final messageAction = Rx<MessageActionArgs?>(null);

  bool isKeyboardOpen = false;
  bool preventEmoji = false;

  final TextEditingController textController = TextEditingController();

  final micRadius = 80.0.obs;
  final micPos = Offset(0, 0).obs;
  final micLockPos = Offset(0, 0).obs;

  Timer? micRadiusTimer;
  Timer? micLockTimer;
  VoiceRecordingController? voiceRecordingController;
  double _min = -30;
  final isLocked = false.obs;

  record() {
    isRecording.value = true;
    micPos.value = Offset(0, 0);
    micRadius.value = 80.0;
    isLocked.value = false;
    voiceRecordingController = VoiceRecordingController();
    _min = 0;
    micRadiusTimer = Timer.periodic(Duration(milliseconds: 200), (timer) {
      if (!isRecording.value) return;
      voiceRecordingController!.record.getAmplitude().then((value) {
        if (value.current.isInfinite ||
            value.current.isNaN ||
            !value.current.isFinite) return;
        if (value.current < _min) {
          _min = value.current;
        }
        micRadius.value = (Random().nextInt(10)) +
            60.0 +
            (30 * (_min / value.current).withRange(1, 5));
      });
    });
    micLockTimer = Timer.periodic(Duration(milliseconds: 1500), (timer) {
      if (!isRecording.value) return;
      final isZero = micLockPos.value.dy == 0;
      micLockPos.value = Offset(0, isZero ? 1 : 0);
    });
  }

  endMicDarg(Chat chat) {
    if (!isLocked.value) {
      stopRecord();
    }
  }

  setMicPos(Offset offset) {
    if (isLocked.value) return;
    micPos.value = offset;
    if (offset.dy < -150) {
      lock();
    }
  }

  lock() {
    isLocked.value = true;
    micPos.value = Offset.zero;
    micLockTimer?.cancel();
    micLockPos.value = Offset.zero;
  }

  stopRecord([bool submit = true]) async {
    if (!isRecording.value) return;
    micRadiusTimer?.cancel();
    micLockTimer?.cancel();
    isRecording.value = false;
    if (micPos.value.dx > -150 &&
        voiceRecordingController!.seconds > 1 &&
        submit) {
      final pendingMsg = Message(
        id: 'id',
        message: 'voice message',
        chatId: chat.id,
        sender: Chatify.currentUserId,
        type: MessageType.voice,
        duration: Duration(seconds: voiceRecordingController!.seconds),
        unSeenBy: [],
      );
      pendingMessages.value = [
        ...pendingMessages.value,
        pendingMsg,
      ];
      await voiceRecordingController!.stop();
      // final file = await File(voiceRecordingController!.path!).readAsBytes();
      // final id = Uuid.generate();
      // final url = await uploadAttachment(file, 'chats/${chat.id}/$id.m4a');
      // if (url == null) return;
      // await Chatify.datasource.addMessage(
      //   Message(
      //     id: id,
      //     message: 'voice message',
      //     chatId: chat.id,
      //     sender: Chatify.currentUserId,
      //     attachment: url,
      //     type: MessageType.voice,
      //     duration: Duration(seconds: voiceRecordingController!.seconds),
      //     unSeenBy:
      //         chat.members.where((e) => e != Chatify.currentUserId).toList(),
      //   ),
      // );
      pendingMessages.value.remove(pendingMsg);
      pendingMessages.value = pendingMessages.value.toList();
    }
    voiceRecordingController?.dispose();
  }

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
    micPos.dispose();
    micRadius.dispose();
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

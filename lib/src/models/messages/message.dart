import 'package:chatify/chatify.dart';
import 'package:chatify/src/utils/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

export 'image.dart';
export 'voice.dart';
export 'text.dart';

abstract class Message {
  final String id;
  final String chatId;
  final String? replyId;
  final String? replyUid;
  final DateTime? sendAt;
  final DateTime pendingTime;
  final String sender;
  final List<String> seenBy;
  final List<String> unSeenBy;
  final List<String> canReadBy;
  final List<String> deliveredTo;
  final List<MessageEmoji> emojis;
  final bool isEdited;
  final MessageType type;

  Message({
    String? id,
    required this.chatId,
    String? sender,
    this.isEdited = false,
    this.sendAt,
    List<String>? seenBy,
    required this.unSeenBy,
    required this.canReadBy,
    this.deliveredTo = const [],
    this.emojis = const [],
    this.replyId,
    this.replyUid,
    required this.type,
  })  : id = id ?? Uuid.generate(),
        sender = sender ?? Chatify.currentUserId,
        seenBy = seenBy ?? [Chatify.currentUserId],
        pendingTime = DateTime.now();

  bool get isMine => sender == Chatify.currentUserId;

  Message.fromJson(Map data)
      : isEdited = data['isEdited'] ?? false,
        sendAt = (data['sendAt'] ?? Timestamp.now()).toDate(),
        seenBy = List.from(data['seenBy'] ?? []),
        unSeenBy = List.from(data['unSeenBy'] ?? []),
        canReadBy = List.from(data['canReadBy'] ?? []),
        deliveredTo = List.from(data['deliveredTo'] ?? []),
        emojis = data['emojis'] is List
            ? List.from(data['emojis'])
                .map<MessageEmoji>((e) => MessageEmoji.fromJson(e))
                .toList()
            : [],
        id = data['id'],
        sender = data['sender'],
        chatId = data['chatId'],
        replyId = data['replyId'],
        replyUid = data['replyUid'],
        pendingTime = DateTime.now(),
        type = getMessageTypeFromString(data['type']);

  @mustCallSuper
  Map<String, dynamic> get toJson => {
        'id': id,
        'sender': sender,
        'sendAt': sendAt == null
            ? FieldValue.serverTimestamp()
            : Timestamp.fromDate(sendAt!),
        'seenBy': seenBy.toSet().toList(),
        'unSeenBy': unSeenBy.toSet().toList(),
        'canReadBy': canReadBy.toSet().toList(),
        'emojis': emojis.map((e) => e.toJson).toList(),
        'chatId': chatId,
        'isEdited': isEdited,
        'replyId': replyId,
        'replyUid': replyUid,
        'type': type.name,
        'deliveredTo': deliveredTo.toSet().toList(),
      };
}

extension MessageTypeExt on MessageType {
  bool get isText => this == MessageType.text;
  bool get isTextOrUnsupported => isText || isUnsupprted;
  bool get isImage => this == MessageType.image;
  bool get isVoice => this == MessageType.voice;
  bool get isVideo => this == MessageType.video;
  bool get isUnsupprted => this == MessageType.unSupported;
}

extension MessageText on Message {
  String get message {
    switch (runtimeType) {
      case TextMessage:
        return (this as TextMessage).message;
      case ImageMessage:
        return 'Image Message';
      case VoiceMessage:
        return 'Voice Message';
      default:
        return 'Unsupported Message';
    }
  }
}

getMessageTypeFromString(String type) => MessageType.values.firstWhere(
      (e) => e.name == type,
      orElse: () => MessageType.unSupported,
    );

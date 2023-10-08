import 'package:chatify/src/models/emoji.dart';
import 'package:chatify/src/enums.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

@immutable
class Message {
  final String id;
  final String chatId;
  final String message;
  final String? replyId;
  final String? replyUid;
  final DateTime? sendAt;
  final String sender;
  final Duration duration;
  final List<String> seenBy;
  final List<String> unSeenBy;
  final List<String> deletedBy;
  final List<String> deliveredTo;
  final List<MessageEmoji> emojis;
  final bool isEdited;
  final MessageType type;
  final String? attachment;
  final dynamic data;

  const Message({
    required this.id,
    required this.message,
    required this.chatId,
    required this.sender,
    this.isEdited = false,
    this.sendAt,
    this.seenBy = const [],
    required this.unSeenBy,
    this.deletedBy = const [],
    this.deliveredTo = const [],
    this.emojis = const [],
    this.duration = const Duration(),
    this.replyId,
    this.replyUid,
    this.type = MessageType.text,
    this.attachment,
    this.data,
  });

  static Message fromJson(Map data, String id) {
    return Message(
      message: data['message'].toString().trim(),
      isEdited: data['isEdited'] ?? false,
      sendAt: (data['sendAt'] ?? Timestamp.now()).toDate(),
      seenBy: List.from(data['seenBy'] ?? []),
      unSeenBy: List.from(data['unSeenBy'] ?? []),
      deletedBy: List.from(data['deletedBy'] ?? []),
      deliveredTo: List.from(data['deliveredTo'] ?? []),
      emojis: data['emojis'] is List
          ? data['emojis']
              .map<MessageEmoji>((e) => MessageEmoji.fromJson(e))
              .toList()
          : [],
      id: id,
      sender: data['sender'],
      chatId: data['chatId'],
      duration: Duration(seconds: data['duration'] ?? 0),
      replyId: data['replyId'],
      replyUid: data['replyUid'],
      data: data['data'],
      attachment: data['attachment'],
      type: MessageType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => MessageType.unSupported,
      ),
    );
  }

  Map<String, dynamic> get toJson => {
        'id': id,
        'message': message.trim(),
        'sender': sender,
        'sendAt': sendAt == null
            ? FieldValue.serverTimestamp()
            : Timestamp.fromDate(sendAt!),
        'seenBy': seenBy.toSet().toList(),
        'unSeenBy': unSeenBy.toSet().toList(),
        'deletedBy': deletedBy.toSet().toList(),
        'emojis': emojis.map((e) => e.toJson).toList(),
        'chatId': chatId,
        'duration': duration.inSeconds,
        'isEdited': isEdited,
        'replyId': replyId,
        'replyUid': replyUid,
        'type': type.name,
        'attachment': attachment,
        'data': data,
        'deliveredTo': deliveredTo.toSet().toList(),
      };

  Message copyWith({
    String? id,
    String? message,
    String? chatId,
    String? sender,
    bool? isEdited,
    DateTime? sendAt,
    List<String>? seenBy,
    List<String>? unSeenBy,
    List<String>? deletedBy,
    List<String>? deliveredTo,
    List<MessageEmoji>? emojis,
    Duration? duration,
    String? replyId,
    String? replyUid,
    MessageType? type,
    String? attachment,
    dynamic data,
  }) =>
      Message(
        id: id ?? this.id,
        message: message ?? this.message,
        chatId: chatId ?? this.chatId,
        sender: sender ?? this.sender,
        isEdited: isEdited ?? this.isEdited,
        sendAt: sendAt ?? this.sendAt,
        seenBy: seenBy ?? this.seenBy,
        unSeenBy: unSeenBy ?? this.unSeenBy,
        deletedBy: deletedBy ?? this.deletedBy,
        deliveredTo: deliveredTo ?? this.deliveredTo,
        emojis: emojis ?? this.emojis,
        duration: duration ?? this.duration,
        replyId: replyId ?? this.replyId,
        replyUid: replyUid ?? this.replyUid,
        type: type ?? this.type,
        attachment: attachment ?? this.attachment,
        data: data ?? this.data,
      );
}

extension MessageTypeExt on MessageType {
  bool get isText => this == MessageType.text;
  bool get isTextOrUnsupported => isText || isUnsupprted;
  bool get isImage => this == MessageType.image;
  bool get isVoice => this == MessageType.voice;
  bool get isVideo => this == MessageType.video;
  bool get isUnsupprted => this == MessageType.unSupported;
}

import 'package:chatify/models/controller.dart';
import 'package:chatify/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:recase/recase.dart';
import 'package:uuid/uuid.dart';

class MessageModel {
  final String id;
  final String roomId;
  String rawMessage;
  String? reply;
  String? replyId;
  String? replyUid;
  final DateTime? sendAt;
  final String sender;
  final Duration duration;
  final List<String> seenBy;
  final List<String> unSeenBy;
  final Map<String, String> emojis;
  bool isEdited;
  dynamic data;
  bool get isMine => sender == ChatUser.current!.id;
  bool get isSeen => seenBy.where((e) => e != ChatUser.current?.id).isNotEmpty;
  String? get myEmoji => emojis.entries
      .toList()
      .firstWhereOrNull((e) => e.key == ChatUser.current!.id)
      ?.value;

  final String type;
  final String? messageAttachment;

  MessageModel(
      {String? id,
      required this.rawMessage,
      required this.roomId,
      required this.sender,
      this.isEdited = false,
      this.sendAt,
      List<String>? seenBy,
      List<String>? unSeenBy,
      List<String>? deliveredTo,
      Map<String, String>? emojis,
      int? duration,
      this.reply,
      this.replyId,
      this.replyUid,
      required this.type,
      this.messageAttachment,
      this.data})
      : seenBy = seenBy ?? [],
        unSeenBy = unSeenBy ?? [],
        emojis = emojis ?? {},
        duration =
            duration == null ? Duration.zero : Duration(seconds: duration),
        id = id ?? const Uuid().v4();

  RxBool isFocused = false.obs;

  static MessageModel fromJson(Map data, String id) {
    return MessageModel(
        rawMessage: data['message'].toString().trim(),
        isEdited: data['isEdited'] ?? false,
        sendAt: (data['sendAt'] ?? Timestamp.now()).toDate(),
        seenBy: List.from(data['seenBy'] ?? []),
        unSeenBy: List.from(data['unSeenBy'] ?? []),
        deliveredTo: List.from(data['deliveredTo'] ?? []),
        emojis: Map.from(data['emojis'] ?? {}),
        id: id,
        sender: data['sender'],
        roomId: data['roomId'],
        duration: data['duration'],
        reply: data['reply'],
        replyId: data['replyId'],
        replyUid: data['replyUid'],
        data: data['data'],
        messageAttachment: data['messageAttachment'] ??
            extractMessageAttacement(data['message']),
        type: data['type'] ?? typeFromString(data['message']) ?? 'unSupported');
  }

  Map<String, dynamic> get toJson => {
        'message': message.trim(),
        'sender': sender,
        'sendAt': sendAt ?? FieldValue.serverTimestamp(),
        'seenBy': seenBy.toSet().toList(),
        'unSeenBy': unSeenBy.toSet().toList(),
        'emojis': emojis,
        'roomId': roomId,
        'duration': duration.inSeconds,
        'isEdited': isEdited,
        'reply': reply,
        'replyId': replyId,
        'replyUid': replyUid,
        'type': type,
        'messageAttachment': messageAttachment,
        'data': data
      };

  static String? typeFromString(String text) {
    if (text.contains(r'$image=')) {
      return 'image';
    } else if (text.contains(r'$audio=')) {
      return 'voice';
    } else if (!text.contains(r'$') ||
        !text.contains(r'=') ||
        text.split('=').first.length > 7) {
      return 'text';
    } else {
      return text.split('=').first.replaceFirst(r'$', '');
    }
  }

  static String? extractMessageAttacement(String text) {
    if (typeFromString(text) == 'text') return null;
    return text.split('=').sublist(1).join('');
  }

  bool get unSupported => type == 'unSupported';
  bool get isText => type == 'text';
  bool get hasImage => type == 'image';
  bool get hasAudio => type == 'voice';
  bool get hasCustom =>
      type != 'image' &&
      type != 'voice' &&
      type != 'text' &&
      type != 'unSupported';

  String get message {
    return hasImage
        ? 'image'.tr.sentenceCase
        : hasAudio
            ? 'voice message'.tr.sentenceCase
            : unSupported
                ? 'Un supported message.'.tr
                : hasCustom
                    ? options.customeMessages
                            .firstWhereOrNull((e) => e.key == type)
                            ?.chatText ??
                        'Un supported message.'.tr
                    : rawMessage;
  }

  String get notifiactionMessage {
    return hasImage
        ? 'sent you image'.tr.sentenceCase
        : hasAudio
            ? 'sent you voice message'.tr.sentenceCase
            : unSupported
                ? 'Sent you an attachment.'.tr
                : hasCustom
                    ? options.customeMessages
                            .firstWhereOrNull((e) => e.key == type)
                            ?.chatText ??
                        'Sent you an attachment.'.tr
                    : rawMessage;
  }

  markAsSeen() {
    if (!seenBy.contains(ChatUser.current?.id) && !isMine) {
      seenBy.add(ChatUser.current!.id);
      unSeenBy.remove(ChatUser.current!.id);
      save();
    }
  }

  update(String message) {
    rawMessage = message;
    isEdited = true;
    save();
  }

  Future<void> save() async {
    await FirebaseFirestore.instance
        .collection('messages')
        .doc(id)
        .set(toJson, SetOptions(merge: true));
  }

  delete() async {
    await FirebaseFirestore.instance.collection('messages').doc(id).delete();
  }
}

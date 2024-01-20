import 'package:chatify/src/enums.dart';
import 'package:chatify/src/models/models.dart';

class TextMessage extends Message {
  final String message;

  TextMessage({
    super.id,
    required this.message,
    required super.chatId,
    super.sender,
    super.isEdited,
    super.sendAt,
    super.seenBy,
    required super.unSeenBy,
    required super.canReadBy,
    super.deliveredTo,
    super.emojis,
    super.replyId,
    super.replyUid,
    super.replyMessage,
  }) : super(type: MessageType.text);

  @override
  Map<String, dynamic> get toJson {
    return {
      'message': message,
      ...super.toJson,
    };
  }

  TextMessage.fromJson(Map data)
      : message = data['message'],
        super.fromJson(data);

  TextMessage copyWith({String? message}) => TextMessage(
        message: message ?? this.message,
        chatId: chatId,
        unSeenBy: unSeenBy,
        id: id,
        sender: sender,
        isEdited: true,
        sendAt: sendAt,
        seenBy: seenBy,
        canReadBy: canReadBy,
        deliveredTo: deliveredTo,
        emojis: emojis,
        replyId: replyId,
        replyUid: replyUid,
      );
}

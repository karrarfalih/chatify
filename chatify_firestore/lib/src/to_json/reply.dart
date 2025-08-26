import 'package:chatify/chatify.dart';

import 'chat.dart';

Map<String, dynamic>? replyMessageToJson(ReplyMessage? message) {
  if (message == null) return null;
  return {
    'id': message.id,
    'message': message.message,
    'sender': userToJson(message.sender),
    'sentAt': message.sentAt,
  };
}

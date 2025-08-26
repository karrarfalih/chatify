import 'package:chatify/chatify.dart';

Map<String, dynamic> chatToJson(Chat chat) {
  return {
    'id': chat.id,
    'readAfter_${chat.sender}': chat.readAfter,
    'members': [chat.sender, chat.receiver],
    'membersDetails': {
      chat.sender.id: userToJson(chat.sender),
      chat.receiver.id: userToJson(chat.receiver),
    },
    'updatedAt': chat.updatedAt,
    'unseenBy_${chat.sender}': chat.unseenMessages,
    'lastMessage': chat.lastMessage,
  };
}


Map<String, dynamic> userToJson(User user) {
  return {
    'id': user.id,
    'name': user.name,
    'imageUrl': user.imageUrl,
  };
}
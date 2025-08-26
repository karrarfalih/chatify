import 'package:chatify/chatify.dart';

List<Map<String, String>> emojiToJson(List<MessageEmoji> emojis) {
  return emojis
      .map((e) => {
            'userId': e.userId,
            'emoji': e.emoji,
          })
      .toList();
}

class MessageEmoji {
  final String emoji;
  final String uid;

  MessageEmoji({required this.emoji, required this.uid});

  static MessageEmoji fromJson(Map data) {
    return MessageEmoji(emoji: data['emoji'], uid: data['uid']);
  }

  Map<String, dynamic> get toJson => {'emoji': emoji, 'uid': uid};
}

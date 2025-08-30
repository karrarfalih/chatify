import 'package:chatify/chatify.dart';

import 'chat.dart';

Message messageFromJson(
  Map<String, dynamic> data,
  String id,
  String currentUserId,
) {
  try {
    final emojis = emojiFromJson(data['emojis']);
    // Extract addon metadata (currently supporting reply)
    final Map<String, dynamic> metadata = {};
    if (data.containsKey('reply')) {
      metadata['reply'] = data['reply'];
    }
    return Message(
      isMine: data['sender']?['id'] == currentUserId,
      sender: userFromJson(data['sender'], ''),
      sentAt: data['sentAt'].toDate(),
      myEmoji: emojis
          .map((e) => e as MessageEmoji?)
          .firstWhere((e) => e?.userId == currentUserId, orElse: () => null)
          ?.emoji,
      emojis: emojis,
      isEdited: data['isEdited'] ?? false,
      isSeen: List.from(data['seenBy'] ?? []).length > 1,
      content: data['isDeleted'] == true
          ? DeletedMessage(id: id)
          : _getMessageFromJsonWithProvider(data, id),
      metadata: metadata,
    );
  } catch (e) {
    return Message(
      isMine: data['sender']?['id'] == currentUserId,
      sender: userFromJson(data['sender'], ''),
      sentAt: data['sentAt']?.toDate() ?? DateTime.now(),
      content: ErrorMessage(id: id),
    );
  }
}

MessageContent _getMessageFromJsonWithProvider(
  Map<String, dynamic> data,
  String id,
) {
  final type = data['type'] as String?;
  final provider = MessageProviderRegistry.instance.getByType(type);
  if (provider != null) {
    try {
      return provider.fromJson(data, id);
    } catch (_) {
      return ErrorMessage(id: id);
    }
  }
  if (type == 'DeletedMessage') return DeletedMessage(id: id);
  return UnsupportedMessage(id: id);
}

List<MessageEmoji> emojiFromJson(List<dynamic>? data) {
  if (data == null) return [];
  return data
      .map((e) => MessageEmoji(emoji: e['emoji'], userId: e['userId']))
      .toList();
}

import 'package:chatify/src/domain/models/chat.dart';
import 'package:collection/collection.dart';

Chat chatFromJson(Map<String, dynamic> data, String sender) {
  final members = List.from(data['members']);
  final receiver =
      members.firstWhereOrNull((e) => e != sender) ?? members.first;
  final membersDetails =
      Map<String, dynamic>.from(data['membersDetails'] ?? {});
  return Chat(
    id: data['id'],
    sender: userFromJson(membersDetails[sender], sender),
    receiver: userFromJson(membersDetails[receiver], receiver),
    updatedAt: data['updatedAt'].toDate(),
    unseenMessages: data['unseenBy_$sender']?.length ?? 0,
    readAfter: data['readAfter_$sender']?.toDate(),
    lastMessage: data['lastMessage'],
    isLastMessageMine: data['lastMessageSender'] == sender,
    isLastMessageSeen: data['unseenBy_$receiver']?.length == 0,
  );
}

User userFromJson(Map<String, dynamic>? data, String id) {
  if (data == null) {
    return User(
      id: id,
      name: id,
      imageUrl: '',
    );
  }
  return User(
    id: data['id'] ?? id,
    name: data['name'] ?? id,
    imageUrl: data['imageUrl'] ?? '',
  );
}

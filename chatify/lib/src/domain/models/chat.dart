import 'package:equatable/equatable.dart';

enum ChatStatus {
  none,
  typing,
  recording,
  sendingMedia,
}

final class Chat extends Equatable {
  final String id;
  final User sender;
  final User receiver;
  final DateTime updatedAt;
  final DateTime? readAfter;
  final int unseenMessages;
  final String? lastMessage;
  final bool isLastMessageMine;
  final bool isLastMessageSeen;

  const Chat({
    required this.id,
    required this.sender,
    required this.receiver,
    required this.updatedAt,
    required this.readAfter,
    required this.unseenMessages,
    required this.lastMessage,
    required this.isLastMessageMine,
    required this.isLastMessageSeen,
  });

  @override
  List<Object?> get props => [
        id,
        sender,
        receiver,
        updatedAt,
        readAfter,
        unseenMessages,
        lastMessage,
        isLastMessageMine,
        isLastMessageSeen,
      ];
}

class User extends Equatable {
  final String id;
  final String name;
  final String imageUrl;

  const User({
    required this.id,
    required this.name,
    required this.imageUrl,
  });

  @override
  List<Object?> get props => [id, name, imageUrl];
}

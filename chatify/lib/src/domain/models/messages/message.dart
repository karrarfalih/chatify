import '../chat.dart';
import '../emoji.dart';
import 'content.dart';
import 'package:equatable/equatable.dart';

class Message extends Equatable {
  final User sender;
  final DateTime sentAt;
  final String? myEmoji;
  final List<MessageEmoji> emojis;
  final bool isEdited;
  final bool isSeen;
  final bool isMine;
  final MessageContent content;
  final Map<String, dynamic> metadata;

  const Message({
    required this.sender,
    required this.sentAt,
    this.myEmoji,
    this.emojis = const [],
    this.isEdited = false,
    this.isSeen = false,
    this.isMine = true,
    required this.content,
    this.metadata = const {},
  });

  @override
  List<Object?> get props => [
        sender,
        sentAt,
        emojis,
        isEdited,
        isSeen,
        isMine,
        content,
        metadata,
      ];
}

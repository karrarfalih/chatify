import '../chat.dart';
import '../emoji.dart';
import 'content.dart';
import 'package:equatable/equatable.dart';

class Message extends Equatable {
  final User sender;
  final ReplyMessage? reply;
  final DateTime sentAt;
  final String? myEmoji;
  final List<MessageEmoji> emojis;
  final bool isEdited;
  final bool isSeen;
  final bool isMine;
  final MessageContent content;

  const Message({
    required this.sender,
    this.reply,
    required this.sentAt,
    this.myEmoji,
    this.emojis = const [],
    this.isEdited = false,
    this.isSeen = false,
    this.isMine = true,
    required this.content,
  });

  @override
  List<Object?> get props => [
        sender,
        reply,
        sentAt,
        emojis,
        isEdited,
        isSeen,
        isMine,
        content,
      ];
}

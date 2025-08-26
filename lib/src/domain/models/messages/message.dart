import 'package:chatify/src/domain/models/chat.dart';
import 'package:chatify/src/domain/models/emoji.dart';
import 'package:chatify/src/domain/models/messages/content.dart';
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

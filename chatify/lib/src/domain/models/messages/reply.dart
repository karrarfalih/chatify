part of 'content.dart';

final class ReplyMessage extends Equatable {
  final String id;
  final String message;
  final User sender;
  final DateTime sentAt;
  final bool isMine;

  const ReplyMessage({
    required this.id,
    required this.message,
    required this.sender,
    required this.sentAt,
    required this.isMine,
  });

  @override
  List<Object?> get props => [
        id,
        message,
        sender,
        sentAt,
        isMine,
      ];
}

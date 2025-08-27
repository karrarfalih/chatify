part of 'bloc.dart';

sealed class MessagesEvent {}

final class MessagesUpdated extends MessagesEvent {
  final PaginatedResult<Message> messages;

  MessagesUpdated(this.messages);
}

final class MessagesLoadMore extends MessagesEvent {}

final class MessagesStatusUpdated extends MessagesEvent {
  final ChatStatus status;

  MessagesStatusUpdated(this.status);
}

final class MessagesFocus extends MessagesEvent {
  final String message;
  final bool isShown;

  MessagesFocus(this.message, this.isShown);
}

final class MessageCopy extends MessagesEvent {
  final Message message;

  MessageCopy(this.message);
}

final class MessageReply extends MessagesEvent {
  final Message message;

  MessageReply(this.message);
}

final class MessageDelete extends MessagesEvent {
  final Message message;

  MessageDelete(this.message);
}

final class MessageEdit extends MessagesEvent {
  final Message message;

  MessageEdit(this.message);
}

final class MessageCancelEditReply extends MessagesEvent {}

final class MessageCancel extends MessagesEvent {
  final Message message;

  MessageCancel(this.message);
}

final class MessagesSendMessage extends MessagesEvent {
  final MessageContent message;

  MessagesSendMessage(this.message);
}

final class MessagesRetrySendingMessage extends MessagesEvent {
  final Message message;

  MessagesRetrySendingMessage(this.message);
}

final class MessagesTextChanged extends MessagesEvent {
  final String text;

  MessagesTextChanged(this.text);
}

final class MessagesSendText extends MessagesEvent {}

final class MessagesCancelSendingMessage extends MessagesEvent {
  final Message message;

  MessagesCancelSendingMessage(this.message);
}

final class MessagesAddMessageToPending extends MessagesEvent {
  final MessageContent message;
  final MediaComposerResult? result;

  MessagesAddMessageToPending(this.message, this.result);
}

final class MessagesComposerResultsPicked extends MessagesEvent {
  final List<ComposerResult> results;

  MessagesComposerResultsPicked(this.results);
}

final class MessagesAddMessageToFailed extends MessagesEvent {
  final String id;

  MessagesAddMessageToFailed(this.id);
}

final class MessagesRemoveMessageFromQueue extends MessagesEvent {
  final String id;
  MessagesRemoveMessageFromQueue(this.id);
}

final class MessageReaction extends MessagesEvent {
  final String messageId;
  final String emoji;

  MessageReaction(this.messageId, this.emoji);
}

final class MessagesRecordStart extends MessagesEvent {}

final class MessagesRecordStop extends MessagesEvent {}

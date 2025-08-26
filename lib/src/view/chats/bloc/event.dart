part of 'bloc.dart';

sealed class ChatsEvent {}

final class ChatsRingUser extends ChatsEvent {
  final Chat chat;

  ChatsRingUser(this.chat);
}

final class ChatsUpdated extends ChatsEvent {
  final PaginatedResult<Chat> chats;

  ChatsUpdated(this.chats);
}

final class ChatsLoadMore extends ChatsEvent {}
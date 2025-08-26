part of 'bloc.dart';

final class ChatsState extends Equatable {
  final PaginatedResult<Chat> chats;

  const ChatsState({required this.chats});

  ChatsState.initial()
      : this(
          chats: PaginatedResult.loading(),
        );

  ChatsState copyWith({
    PaginatedResult<Chat>? chats,
  }) {
    return ChatsState(
      chats: chats ?? this.chats,
    );
  }

  @override
  List<Object?> get props => [chats];
}

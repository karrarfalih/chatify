part of 'bloc.dart';

final class MessagesState extends Equatable {
  final PaginatedResult<Message> messages;
  final List<Message> pendingMessages;
  final List<Message> failedMessages;
  final String textMessage;
  final Nullable<String> focusedMessage;
  final Nullable<Message> editingMessage;
  final Nullable<Message> replyingMessage;
  final Map<String, Message> selectedMessages;
  final ChatStatus status;
  final bool isSelectionMode;
  final bool isRecording;

  const MessagesState({
    required this.messages,
    required this.pendingMessages,
    required this.failedMessages,
    required this.textMessage,
    required this.focusedMessage,
    required this.editingMessage,
    required this.replyingMessage,
    required this.selectedMessages,
    required this.isSelectionMode,
    required this.status,
    required this.isRecording,
  });

  const MessagesState.initial()
      : this(
          messages: const PaginatedResult.loading(),
          pendingMessages: const [],
          failedMessages: const [],
          textMessage: '',
          focusedMessage: const Nullable.nl(),
          editingMessage: const Nullable.nl(),
          replyingMessage: const Nullable.nl(),
          selectedMessages: const {},
          isSelectionMode: false,
          status: ChatStatus.none,
          isRecording: false,
        );

  MessagesState copyWith({
    PaginatedResult<Message>? messages,
    List<Message>? pendingMessages,
    List<Message>? failedMessages,
    String? textMessage,
    Nullable<String>? focusedMessage,
    Nullable<Message>? editingMessage,
    Nullable<Message>? replyingMessage,
    Map<String, Message>? selectedMessages,
    bool? isSelectionMode,
    ChatStatus? status,
    bool? isRecording,
  }) {
    return MessagesState(
      messages: messages ?? this.messages,
      pendingMessages: pendingMessages ?? this.pendingMessages,
      failedMessages: failedMessages ?? this.failedMessages,
      textMessage: textMessage ?? this.textMessage,
      focusedMessage: focusedMessage ?? this.focusedMessage,
      editingMessage: editingMessage ?? this.editingMessage,
      replyingMessage: replyingMessage ?? this.replyingMessage,
      selectedMessages: selectedMessages ?? this.selectedMessages,
      isSelectionMode: isSelectionMode ?? this.isSelectionMode,
      status: status ?? this.status,
      isRecording: isRecording ?? this.isRecording,
    );
  }

  @override
  List<Object?> get props => [
        messages,
        pendingMessages,
        failedMessages,
        textMessage,
        focusedMessage,
        editingMessage,
        replyingMessage,
        selectedMessages,
        isSelectionMode,
        status,
        isRecording,
      ];
}

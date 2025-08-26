part of 'bloc.dart';

final class ChatRecordState extends Equatable {
  final bool isRecording;

  const ChatRecordState({required this.isRecording});

  const ChatRecordState.initial()
      : this(
          isRecording: false,
        );

  ChatRecordState copyWith({
    bool? isRecording,
  }) {
    return ChatRecordState(
      isRecording: isRecording ?? this.isRecording,
    );
  }

  @override
  List<Object?> get props => [isRecording];
}

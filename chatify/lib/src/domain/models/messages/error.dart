part of 'content.dart';

final class ErrorMessage extends MessageContent {
  ErrorMessage({required super.id}) : super(content: 'Failed to load message data');

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
    };
  }

  @override
  List<Object?> get props => [id];
}

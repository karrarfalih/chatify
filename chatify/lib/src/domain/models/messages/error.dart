part of 'content.dart';

final class ErrorMessage extends MessageContent {
  ErrorMessage({required super.id})
      : super(content: 'Failed to load message data', type: 'TextMessage');

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
    };
  }

  @override
  List<Object?> get props => [id];
}

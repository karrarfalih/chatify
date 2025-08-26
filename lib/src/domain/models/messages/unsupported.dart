part of 'content.dart';

final class UnsupportedMessage extends MessageContent {
  UnsupportedMessage({required super.id})
      : super(content: 'Unsupported message');

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
    };
  }

  @override
  List<Object?> get props => [id];
}

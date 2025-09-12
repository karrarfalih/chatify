import 'package:chatify/chatify.dart';

final class TextMessage extends MessageContent {
  final String message;

  TextMessage({required this.message})
    : super(content: message, type: 'TextMessage');

  TextMessage.fromJson(super.json, super.id)
    : message = json['message'],
      super.fromJson();

  @override
  Map<String, dynamic> toJson() {
    return {'message': message, ...super.toJson()};
  }

  @override
  List<Object?> get props => [id, message];
}

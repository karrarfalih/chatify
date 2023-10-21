import 'package:chatify/src/enums.dart';
import 'package:chatify/src/models/models.dart';

getMessageFromJson(Map<String, dynamic> data) {
  final typeString = data['type'];
  final type = getMessageTypeFromString(typeString);
  switch (type) {
    case MessageType.text:
      return TextMessage.fromJson(data);
    case MessageType.image:
      return ImageMessage.fromJson(data);
    case MessageType.voice:
      return VoiceMessage.fromJson(data);
    default:
      return TextMessage.fromJson(data);
  }
}

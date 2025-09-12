import 'package:chatify/chatify.dart';
import 'package:flutter/widgets.dart';

import 'model.dart';
import 'widget.dart';

class TextMessageProvider extends BasicMessageProvider<TextMessage> {
  @override
  String get type => 'TextMessage';

  @override
  TextMessage fromJson(Map<String, dynamic> data, String id) {
    return TextMessage.fromJson(data, id);
  }

  @override
  Widget build(BuildContext context, MessageState message) {
    return TextMessageWidget(
      message: message.message,
      isPending: message.isPending,
      isFailed: message.isFailed,
    );
  }

  @override
  bool get supportsTextInput => true;

  @override
  TextMessage? createFromText(String text) {
    return TextMessage(message: text);
  }
}

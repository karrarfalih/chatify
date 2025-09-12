import 'package:chatify/chatify.dart';
import 'package:flutter/widgets.dart';

import 'model.dart';
import 'widget.dart';

class VoiceMessageProvider extends MediaMessageProvider<VoiceMessage> {
  @override
  String get type => 'VoiceMessage';

  @override
  VoiceMessage fromJson(Map<String, dynamic> data, String id) {
    return VoiceMessage.fromJson(data, id);
  }

  @override
  Widget build(BuildContext context, MessageState message) {
    return VoiceMessageWidget(message: message.message);
  }
}

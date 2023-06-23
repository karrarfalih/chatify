import 'package:chat/models/message.dart';
import 'package:flutter/material.dart';

class MessageWidget {
  final String key;
  final String chatText;
  final String notificationText;
  final Widget Function(BuildContext context, MessageModel msg) builder;

  MessageWidget({required this.key, required this.builder, this.chatText = 'Attachment', this.notificationText = 'send you an attachment', });
}

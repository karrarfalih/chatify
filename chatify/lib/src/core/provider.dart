import '../domain/models/messages/message.dart';
import '../domain/models/messages/content.dart';
import 'composer.dart';
import 'task.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

abstract class MessageProvider<T extends MessageContent> {
  String get type => T.toString();
  bool get isMedia => false;

  T fromJson(Map<String, dynamic> data, String id);

  bool get supportsTextInput => false;

  T? createFromText(String text) => null;

  List<ComposerAction> get composerActions => const [];

  Widget build(BuildContext context, MessageState message);
}

abstract class BasicMessageProvider<T extends MessageContent>
    extends MessageProvider<T> {
  @override
  List<ComposerAction<BasicComposerResult>> get composerActions => const [];
}

abstract class MediaMessageProvider<T extends MessageContent>
    extends MessageProvider<T> {
  @override
  bool get isMedia => true;

  Stream<MessageTask> getTaskStream(MessageContent message) {
    return MessageTaskRegistry.instance.streamFor(message) ??
        const Stream<MessageTask>.empty();
  }

  @override
  List<ComposerAction<MediaComposerResult>> get composerActions => const [];
}

class MessageState extends Equatable {
  final Message message;
  final bool isPending;
  final bool isFailed;

  const MessageState({
    required this.message,
    required this.isPending,
    required this.isFailed,
  });

  MessageState copyWith({
    Message? message,
    bool? isPending,
    bool? isFailed,
  }) {
    return MessageState(
      message: message ?? this.message,
      isPending: isPending ?? this.isPending,
      isFailed: isFailed ?? this.isFailed,
    );
  }

  @override
  List<Object?> get props => [message, isPending, isFailed];
}

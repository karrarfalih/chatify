import 'package:chatify/chatify.dart';
import 'package:chatify_reply/bloc/bloc.dart';
import 'package:chatify_reply/view/reply.dart';
import 'package:chatify_reply/view/replyed_message.dart';
import 'package:chatify_reply/view/swipe_to_reply.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ReplyAddon extends ChatAddon {
  const ReplyAddon();

  @override
  Widget wrapChat(BuildContext c, Chat chat, Widget child) {
    return BlocProvider(create: (context) => ReplyBloc(chat), child: child);
  }

  @override
  Widget wrapMessage(
    BuildContext c,
    Chat chat,
    Message m,
    int i,
    Widget child,
  ) {
    return SwipeToReply(message: m, child: child);
  }

  @override
  Widget? buildMessageLeading(BuildContext c, Chat chat, Message m, int i) {
    final reply = _parseReplyFromMetadata(m.metadata);
    if (reply == null) return null;
    return ReplyedMessageWidget(reply: reply);
  }

  @override
  List<OptionsItem> buildMessageOptions(BuildContext c, Chat chat, Message m) {
    return [
      OptionsItem(
        title: 'Reply',
        icon: Icons.reply,
        onSelect: () {
          c.read<ReplyBloc>().add(ReplyStart(m));
        },
      ),
    ];
  }

  @override
  Widget wrapInputField(BuildContext c, Chat chat, Widget child) {
    return Column(children: [const ReplyPreview(), child]);
  }

  @override
  Map<String, dynamic> buildOutgoingMetadata(Chat chat) {
    final state = ReplyBloc.instance?.state;
    final replying = state?.replying;
    if (replying == null) return const {};
    return {
      'reply': {
        'id': replying.content.id,
        'message': replying.content.content,
        'sender': replying.sender.id,
        'senderName': replying.sender.name,
        'isMine': replying.isMine,
      },
    };
  }

  @override
  void onMessageSent(Chat chat) {
    ReplyBloc.instance?.add(ReplyCancel());
  }

  ReplyData? _parseReplyFromMetadata(Map<String, dynamic> metadata) {
    final raw = metadata['reply'];
    if (raw is Map) {
      return ReplyData(
        id: raw['id']?.toString() ?? '',
        message: raw['message']?.toString() ?? '',
        senderId: raw['sender']?.toString() ?? '',
        senderName: raw['senderName']?.toString() ?? '',
        isMine: raw['isMine'] == true,
      );
    }
    return null;
  }
}

class ReplyData {
  final String id;
  final String message;
  final String senderId;
  final String senderName;
  final bool isMine;

  const ReplyData({
    required this.id,
    required this.message,
    required this.senderId,
    required this.senderName,
    required this.isMine,
  });
}

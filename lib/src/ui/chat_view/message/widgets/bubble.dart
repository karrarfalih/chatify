
import 'package:chatify/src/core/chatify.dart';
import 'package:chatify/src/models/models.dart';
import 'package:chatify/src/theme/theme_widget.dart';
import 'package:chatify/src/ui/chat_view/message/widgets/bubble/bubble.dart';
import 'package:flutter/material.dart';

class MyBubble extends StatelessWidget {
  const MyBubble({
    super.key,
    required this.message,
    required this.bkColor,
    required this.linkedWithBottom,
    required this.child,
  });

  final Message message;
  final Color bkColor;
  final bool linkedWithBottom;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final isMine = message.sender == Chatify.currentUserId;
    return Bubble(
      radius: const Radius.circular(12),
      nip: isMine ? BubbleNip.rightBottom : BubbleNip.leftBottom,
      nipWidth: 5,
      color: bkColor,
      elevation: 0,
      shadowColor: ChatifyTheme.of(context).primaryColor,
      showNip: !linkedWithBottom,
      padding: const BubbleEdges.all(0),
      child: child,
    );
  }
}

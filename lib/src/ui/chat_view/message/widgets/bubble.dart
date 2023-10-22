import 'package:chatify/src/models/models.dart';
import 'package:chatify/src/ui/chat_view/message/widgets/bubble/bubble.dart';
import 'package:flutter/material.dart';

class MyBubble extends StatelessWidget {
  const MyBubble({
    super.key,
    required this.message,
    required this.bkColor,
    required this.linkedWithBottom,
    required this.child,
    required this.linkedWithTop,
  });

  final Message message;
  final Color bkColor;
  final bool linkedWithBottom;
  final bool linkedWithTop;
  final Widget child;
  
  @override
  Widget build(BuildContext context) {
    final isMine = message.isMine;
    return Bubble(
      radius: 20,
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(isMine || !linkedWithTop ? 20 : 10),
        topRight: Radius.circular(!isMine || !linkedWithTop ? 20 : 10),
        bottomLeft: Radius.circular(isMine || !linkedWithBottom ? 20 : 10),
        bottomRight: Radius.circular(!isMine || !linkedWithBottom ? 20 : 10),
      ),
      nip: isMine ? BubbleNip.right : BubbleNip.left,
      color: bkColor,
      showNip: !linkedWithBottom,
      child: child,
    );
  }
}

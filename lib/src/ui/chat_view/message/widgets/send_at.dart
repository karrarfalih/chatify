import 'package:chatify/chatify.dart';
import 'package:flutter/material.dart';
import 'package:kr_extensions/kr_extensions.dart';

class SendAtWidget extends StatelessWidget {
  const SendAtWidget({
    Key? key,
    required this.message,
  }) : super(key: key);

  final Message message;

  @override
  Widget build(BuildContext context) {
    final isMine = message.sender == Chatify.currentUserId;
    final isSeen =
        message.seenBy.where((e) => e != Chatify.currentUserId).isNotEmpty;
    final isText = message.type == MessageType.text ||
        message.type == MessageType.unSupported;
    final isVoice = message.type == MessageType.voice;
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isMine)
            Image.asset(
              isSeen ? 'assets/icons/seen.png' : 'assets/icons/sent.png',
              package: 'chatify',
              height: 14,
              color: !isMine && isText
                  ? Colors.black.withOpacity(isText || isVoice ? 0.7 : 1)
                  : Colors.white.withOpacity(isText || isVoice ? 0.7 : 1),
            ),
          Text(
            (message.sendAt ?? DateTime.now()).format('h:mm a'),
            style: TextStyle(
              fontSize: 12,
              color: !isMine && isText
                  ? Colors.black.withOpacity(isText || isVoice ? 0.7 : 1)
                  : Colors.white.withOpacity(isText || isVoice ? 0.7 : 1),
              height: 1,
            ),
            textDirection: TextDirection.ltr,
          ),
          Text(
            message.isEdited ? ' ${'edited'} ' : '',
            style: TextStyle(
              fontSize: 12,
              color: !isMine && isText
                  ? Colors.black.withOpacity(isText || isVoice ? 0.7 : 1)
                  : Colors.white.withOpacity(isText || isVoice ? 0.7 : 1),
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:chatify/chatify.dart';
import 'package:chatify/src/theme/theme_widget.dart';
import 'package:chatify/src/utils/extensions.dart';
import 'package:flutter/material.dart';

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
    final isTextOrVoice =
        message.type.isTextOrUnsupported || message.type.isVoice;
    final isVoice = message.type == MessageType.voice;
    final theme = ChatifyTheme.of(context);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsetsDirectional.only(end: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isMine)
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 3),
                child: Image.asset(
                  isSeen ? 'assets/icons/seen.png' : 'assets/icons/sent.png',
                  package: 'chatify',
                  height: 14,
                  color: !isMine && isTextOrVoice
                      ? theme.chatForegroundColor
                          .withOpacity(isTextOrVoice || isVoice ? 0.7 : 1)
                      : Colors.white
                          .withOpacity(isTextOrVoice || isVoice ? 0.7 : 1),
                ),
              ),
            Text(
              (message.sendAt ?? DateTime.now()).format(context, 'h:mm a'),
              style: TextStyle(
                fontSize: 12,
                color: !isMine && isTextOrVoice
                    ? theme.chatForegroundColor
                        .withOpacity(isTextOrVoice || isVoice ? 0.7 : 1)
                    : Colors.white
                        .withOpacity(isTextOrVoice || isVoice ? 0.7 : 1),
                height: 1,
              ),
              textDirection: TextDirection.ltr,
            ),
            Text(
              message.isEdited ? ' ${'edited'} ' : '',
              style: TextStyle(
                fontSize: 12,
                color: !isMine && isTextOrVoice
                    ? theme.chatForegroundColor
                        .withOpacity(isTextOrVoice || isVoice ? 0.7 : 1)
                    : Colors.white
                        .withOpacity(isTextOrVoice || isVoice ? 0.7 : 1),
                height: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

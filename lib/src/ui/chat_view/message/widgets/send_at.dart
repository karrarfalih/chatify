import 'package:chatify/chatify.dart';
import 'package:chatify/src/theme/theme_widget.dart';
import 'package:chatify/src/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class SendAtWidget extends StatelessWidget {
  const SendAtWidget({
    Key? key,
    required this.message,
    this.isSending = false,
  }) : super(key: key);

  final Message message;
  final bool isSending;

  @override
  Widget build(BuildContext context) {
    final isMine = message.isMine;
    final isSeen =
        message.seenBy.where((e) => e != Chatify.currentUserId).isNotEmpty;
    final isTextOrVoice =
        message.type.isTextOrUnsupported || message.type.isVoice;
    final isVoice = message.type == MessageType.voice;
    final theme = ChatifyTheme.of(context);
    final iconColor = !isMine && isTextOrVoice
        ? theme.chatForegroundColor.withOpacity(
            isTextOrVoice || isVoice ? 0.7 : 1,
          )
        : Colors.white.withOpacity(
            isTextOrVoice || isVoice ? 0.7 : 1,
          );
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: EdgeInsets.only(left: isMine ? 8 : 0, right: isMine ? 0 : 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isMine)
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 3),
                child: SizedBox(
                  width: 14,
                  height: 14,
                  child: isSending
                      ? Icon(
                          Iconsax.clock,
                          size: 12,
                          color: iconColor,
                        )
                      : Image.asset(
                          isSeen
                              ? 'assets/icons/seen.png'
                              : 'assets/icons/sent.png',
                          package: 'chatify',
                          height: 14,
                          color: iconColor,
                        ),
                ),
              ),
            Text(
              (message.sendAt ?? DateTime.now()).format(context, 'h:mm a'),
              style: TextStyle(
                fontSize: 11,
                color: !isMine && isTextOrVoice
                    ? theme.chatForegroundColor
                        .withOpacity(isTextOrVoice || isVoice ? 0.5 : 1)
                    : Colors.white
                        .withOpacity(isTextOrVoice || isVoice ? 0.5 : 1),
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

import 'package:chatify/chatify.dart';
import 'package:chatify/src/localization/get_string.dart';
import 'package:chatify/src/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SendAtWidget extends StatelessWidget {
  const SendAtWidget({
    Key? key,
    required this.message,
    this.isSending = false,
    this.iconColor,
    this.textColor,
  }) : super(key: key);

  final Message message;
  final bool isSending;
  final Color? iconColor;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final isMine = message.isMine;
    final isSeen =
        message.seenBy.where((e) => e != Chatify.currentUserId).isNotEmpty;
    final isTextOrVoice =
        message.type.isTextOrUnsupported || message.type.isVoice || message.emojis.isNotEmpty;
    final isVoice = message.type == MessageType.voice;
    final theme = Chatify.theme;
    final iconColor = this.iconColor ??
        (!isMine && isTextOrVoice
            ? theme.chatForegroundColor.withOpacity(
                isTextOrVoice || isVoice ? 0.7 : 1,
              )
            : Colors.white.withOpacity(
                isTextOrVoice || isVoice ? 0.7 : 1,
              ));
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: EdgeInsets.only(left: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (isMine)
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 3),
                child: SizedBox(
                  width: 14,
                  height: 14,
                  child: isSending
                      ? Center(
                          child: Lottie.asset(
                            'assets/lottie/sending.json',
                            package: 'chatify',
                            fit: BoxFit.fitHeight,
                            height: 12,
                          ),
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
                color: textColor ??
                    (isTextOrVoice && !isMine
                        ? theme.chatForegroundColor.withOpacity(0.3)
                        : Colors.white.withOpacity(isTextOrVoice ? 0.5 : 1)),
                height: 1.2,
              ),
              textDirection: TextDirection.ltr,
            ),
            Text(
              message.isEdited ? ' ${localization(context).edited} ' : '',
              style: TextStyle(
                fontSize: 11,
                color: !isMine
                    ? theme.chatForegroundColor.withOpacity(0.6)
                    : Colors.white.withOpacity(0.6),
                height: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

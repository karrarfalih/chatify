import 'package:chatify/chatify.dart';
import 'package:flutter/material.dart';
import 'package:readmore/readmore.dart';

class TextMessageWidget extends StatelessWidget {
  const TextMessageWidget({
    super.key,
    required this.message,
    required this.isPending,
    required this.isFailed,
  });
  final Message message;
  final bool isPending;
  final bool isFailed;

  @override
  Widget build(BuildContext context) {
    final direction = message.content.content.directionByLanguage;
    if (message.content.content.length < 30 && message.emojis.isEmpty) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        textDirection: TextDirection.ltr,
        children: [
          Flexible(
            child: Padding(
              padding: const EdgeInsetsDirectional.only(
                start: 8,
                end: 16,
                top: 5,
                bottom: 5,
              ),
              child: Directionality(
                textDirection: direction,
                child: Text(
                  message.content.content,
                  textAlign: message.isMine ? TextAlign.end : TextAlign.start,
                ),
              ),
            ),
          ),
          SentAtWidget(
            message: message,
            isSending: isPending,
            isFailed: isFailed,
          ),
        ],
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      textDirection: TextDirection.ltr,
      children: [
        Flexible(
          child: Padding(
            padding: const EdgeInsetsDirectional.only(
              start: 10,
              end: 16,
              top: 5,
            ),
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: ReadMoreText(
                message.content.content,
                trimLines: 15,
                trimMode: TrimMode.Line,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ),
        ),
        SentAtWidget(
          message: message,
          isSending: isPending,
          isFailed: isFailed,
        ),
      ],
    );
  }
}

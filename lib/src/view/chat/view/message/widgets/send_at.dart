import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:lottie/lottie.dart';
import 'package:chatify/src/domain/models/messages/message.dart';
import 'package:chatify/src/domain/models/messages/content.dart';

class SentAtWidget extends StatelessWidget {
  const SentAtWidget({
    super.key,
    required this.message,
    this.isSending = false,
    this.isFailed = false,
    this.hasBackground = false,
  });

  final Message message;
  final bool isSending;
  final bool isFailed;
  final bool hasBackground;

  @override
  Widget build(BuildContext context) {
    final color = message.content is ErrorMessage
        ? Theme.of(context).colorScheme.error
        : hasBackground
            ? Theme.of(context).colorScheme.surfaceContainerHigh
            : Theme.of(context).colorScheme.outline;
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Padding(
        padding: const EdgeInsetsDirectional.only(end: 8, bottom: 4),
        child: Container(
          padding: hasBackground
              ? const EdgeInsets.symmetric(horizontal: 4, vertical: 2)
              : EdgeInsets.zero,
          decoration: hasBackground
              ? BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(50),
                )
              : null,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (message.emojis.isNotEmpty)
                Animate(
                  key: ValueKey(message.content.id),
                  effects: const [
                    FadeEffect(),
                    ScaleEffect(),
                  ],
                  child: Container(
                    margin: !hasBackground
                        ? const EdgeInsetsDirectional.only(start: 8, end: 8)
                        : EdgeInsets.zero,
                    decoration: !hasBackground
                        ? BoxDecoration(
                            color: message.isMine
                                ? Theme.of(context).colorScheme.surfaceContainer
                                : Theme.of(context)
                                    .colorScheme
                                    .secondaryContainer,
                            borderRadius: BorderRadius.circular(50),
                          )
                        : null,
                    padding: const EdgeInsets.only(
                      left: 4,
                      right: 2,
                      top: 2,
                      bottom: 2,
                    ),
                    child: Row(
                      children:
                          message.emojis.map((e) => Text(e.emoji)).toList(),
                    ),
                  ),
                ),
              Text(
                message.isEdited ? ' ${'edited'.tr} ' : '',
                style: TextStyle(
                  fontSize: 11,
                  color: color,
                  height: 1,
                ),
              ),
              Text(
                DateFormat('h:mm a').format(message.sentAt),
                style: TextStyle(
                  fontSize: 11,
                  color: color,
                ),
                textDirection: TextDirection.ltr,
              ),
              if (message.isMine || message.content is ErrorMessage)
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: 3),
                  child: SizedBox(
                    width: 14,
                    height: 14,
                    child: isSending
                        ? Center(
                            child: Lottie.asset(
                              'assets/sending${hasBackground ? '' : '_black'}.json',
                              package: 'chatify',
                              fit: BoxFit.fitHeight,
                              height: 12,
                            ),
                          )
                        : isFailed || message.content is ErrorMessage
                            ? Icon(Icons.error_outline,
                                color: Theme.of(context).colorScheme.error,
                                size: 14)
                            : Image.asset(
                                message.isSeen
                                    ? 'assets/seen.png'
                                    : 'assets/sent.png',
                                package: 'chatify',
                                height: 14,
                                color: color,
                              ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:chatify/src/domain/models/messages/content.dart';
import 'package:chatify/src/helpers/extensions.dart';
import 'package:flutter/material.dart';

class ReplyedMessageWidget extends StatelessWidget {
  const ReplyedMessageWidget({super.key, required this.reply});

  final ReplyMessage? reply;

  @override
  Widget build(BuildContext context) {
    if (reply == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Row(
          children: [
            const SizedBox(width: 12),
            Container(
              width: 2,
              height: 32,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reply!.isMine ? 'You' : reply!.sender.name,
                    style: const TextStyle(fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    reply!.message,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.5),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textDirection: reply!.message.directionByLanguage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

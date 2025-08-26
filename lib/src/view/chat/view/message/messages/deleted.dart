import '../../../../../domain/models/messages/message.dart';
import '../widgets/send_at.dart';
import 'package:flutter/material.dart';

class DeletedMessageWidget extends StatelessWidget {
  const DeletedMessageWidget(this.message, {super.key});
  final Message message;

  @override
  Widget build(BuildContext context) {
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
            child: Text(
              message.content.content,
              style: TextStyle(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.5)),
            ),
          ),
        ),
        SentAtWidget(message: message),
      ],
    );
  }
}

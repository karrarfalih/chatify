import '../../../../../domain/models/messages/message.dart';
import '../widgets/send_at.dart';
import 'package:flutter/material.dart';

class ErrorMessageWidget extends StatelessWidget {
  const ErrorMessageWidget(this.message, {super.key});
  final Message message;

  @override
  Widget build(BuildContext context) {
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
            child: Text(
              message.content.content,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        ),
        const SizedBox(height: 3),
        SentAtWidget(message: message),
      ],
    );
  }
}

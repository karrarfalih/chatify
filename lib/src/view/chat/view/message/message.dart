import 'package:chatify/chatify.dart';
import 'package:chatify/src/view/chat/view/message/widgets/constraints.dart';
import 'messages/deleted.dart';
import 'messages/error.dart';
import 'messages/unsupported.dart';
import 'widgets/bubble.dart';
import 'widgets/options.dart';
import 'widgets/reply.dart';
import 'selection/message.dart';
import 'widgets/swipe_to_reply.dart';
import 'package:flutter/material.dart';

class MessageWidget extends StatelessWidget {
  const MessageWidget({
    super.key,
    required this.message,
    required this.isLast,
    required this.isFirst,
    required this.isPending,
    required this.isFailed,
    required this.index,
  });

  final Message message;
  final bool isLast;
  final bool isFirst;
  final bool isPending;
  final bool isFailed;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: message.isMine ? TextDirection.rtl : TextDirection.ltr,
      child: MessageSelectionWidget(
        index: index,
        message: message,
        child: SwipeToReply(
          message: message,
          child: MessageOptions(
            message: message,
            isSending: isPending,
            isFailed: isFailed,
            child: MessageConstraints(
              message: message,
              child: MessageBubble(
                isFirst: isFirst,
                isLast: isLast,
                isMine: message.isMine,
                isError: message.content is ErrorMessage,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ReplyedMessageWidget(reply: message.reply),
                    Flexible(
                      child: switch (message.content) {
                        DeletedMessage() => DeletedMessageWidget(message),
                        UnsupportedMessage() =>
                          UnsupportedMessageWidget(message),
                        ErrorMessage() => ErrorMessageWidget(message),
                        _ => MessageProviderRegistry.instance
                                .getByMessage(message.content)
                                ?.build(
                                    context,
                                    MessageState(
                                      message: message,
                                      isPending: isPending,
                                      isFailed: isFailed,
                                    )) ??
                            UnsupportedMessageWidget(message),
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

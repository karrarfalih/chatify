import 'package:chatify/src/models/models.dart';
import 'package:chatify/src/core/chatify.dart';
import 'package:chatify/src/ui/chat_view/controllers/chat_controller.dart';
import 'package:chatify/src/ui/common/circular_button.dart';
import 'package:chatify/src/ui/common/expanded_section.dart';
import 'package:flutter/material.dart';

class MessageActionHeader extends StatelessWidget {
  const MessageActionHeader({
    super.key,
    required this.controller,
    required this.user,
  });

  final ChatController controller;
  final ChatifyUser user;

  @override
  Widget build(BuildContext context) {
    MessageActionArgs? latsArgs;
    final theme = Chatify.theme;
    return ValueListenableBuilder<MessageActionArgs?>(
      valueListenable: controller.messageAction,
      builder: (contex, value, child) {
        if (value != null) {
          latsArgs = value;
        }
        final args = value ?? latsArgs;
        final isMine = args?.message?.isMine ?? false;
        final name = isMine ? 'Me' : user.name;
        final message = args?.message;
        final icon =
            args?.type == MessageActionType.reply ? Icons.reply : Icons.edit;
        return Directionality(
          textDirection: TextDirection.ltr,
          child: KrExpandedSection(
            expand: value != null,
            onFinish: () {
              controller.messageAction.value = null;
            },
            child: Container(
              width: double.maxFinite,
              color: theme.chatForegroundColor.withOpacity(0.1),
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
              child: Row(
                children: [
                  Icon(
                    icon,
                    color: theme.chatForegroundColor,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.chatForegroundColor,
                          ),
                        ),
                        Text(
                          message?.message ?? '',
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.chatForegroundColor.withOpacity(0.5),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  CircularButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      controller.messageAction.value = null;
                      if (args?.type == MessageActionType.edit) {
                        controller.textController.clear();
                      }
                    },
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

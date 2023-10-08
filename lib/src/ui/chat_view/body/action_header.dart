import 'package:chatify/src/core/chatify.dart';
import 'package:chatify/src/models/models.dart';
import 'package:chatify/src/ui/chat_view/controllers/controller.dart';
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
    return ValueListenableBuilder<MessageActionArgs?>(
      valueListenable: controller.messageAction,
      builder: (contex, value, child) {
        final isMine = value?.message?.sender == Chatify.currentUserId;
        final name = isMine ? 'Me' : user.name;
        final message = value?.message;
        final icon = value?.type == MessageActionType.reply
            ? Icons.reply
            : Icons.edit;
        return Directionality(
          textDirection: TextDirection.ltr,
          child: KrExpandedSection(
            expand: message != null,
            onFinish: () {
              controller.messageAction.value = null;
            },
            child: Container(
              width: double.maxFinite,
              color: Colors.grey.shade300,
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
              child: Row(
                children: [
                  Icon(icon),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          message?.message ?? '',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
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

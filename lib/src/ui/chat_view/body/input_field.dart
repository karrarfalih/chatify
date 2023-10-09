import 'package:chatify/src/models/models.dart';
import 'package:chatify/src/theme/theme_widget.dart';
import 'package:chatify/src/ui/chat_view/controllers/controller.dart';
import 'package:chatify/src/ui/common/circular_button.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class ChatInputField extends StatelessWidget {
  const ChatInputField({
    super.key,
    required this.controller,
    required this.chat,
  });

  final ChatController controller;
  final Chat chat;

  @override
  Widget build(BuildContext context) {
    final iconColor = ChatifyTheme.of(
      context,
    ).chatBackgroundColor.withOpacity(0.5);
    return Row(
      children: [
        CircularButton(
          onPressed: () {},
          size: 60,
          icon: Padding(
            padding: const EdgeInsets.all(3),
            child: Icon(
              Iconsax.emoji_normal,
              color: iconColor,
              size: 26,
            ),
          ),
        ),
        Expanded(
          child: TextField(
            controller: controller.textController,
            maxLines: 5,
            minLines: 1,
            style: TextStyle(
              color: ChatifyTheme.of(
                context,
              ).chatBackgroundColor,
            ),
            onChanged: (x) {
              controller.isTyping.value = x.isNotEmpty;
            },
            focusNode: controller.focus,
            textInputAction: TextInputAction.newline,
            keyboardType: TextInputType.multiline,
            decoration: InputDecoration(
              fillColor: Colors.transparent,
              filled: true,
              hintText: 'Message',
              hintStyle: TextStyle(
                fontWeight: FontWeight.normal,
                color: ChatifyTheme.of(
                  context,
                ).chatBackgroundColor.withOpacity(0.4),
              ),
              isDense: true,
              enabledBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(30),
                ),
                borderSide: BorderSide(
                  color: Colors.transparent,
                ),
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(30),
                ),
                borderSide: BorderSide(
                  color: Colors.transparent,
                ),
              ),
            ),
          ),
        ),
        Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
          ),
          margin: const EdgeInsetsDirectional.only(start: 10),
          child: ValueListenableBuilder<bool>(
            valueListenable: controller.isTyping,
            builder: (
              contex,
              value,
              child,
            ) {
              return value
                  ? CircularButton(
                      onPressed: () {
                        controller.submitMessage(
                          controller.textController.text,
                          chat,
                        );
                      },
                      size: 60,
                      icon: Padding(
                        padding: const EdgeInsets.all(3),
                        child: Icon(
                          Icons.send,
                          color: ChatifyTheme.of(
                            context,
                          ).primaryColor,
                          size: 26,
                        ),
                      ),
                    )
                  : Row(
                      children: [
                        CircularButton(
                          onPressed: () {
                            controller.sendImage(chat);
                          },
                          size: 60,
                          icon: Icon(
                            Iconsax.document_1,
                            color: iconColor,
                            size: 24,
                          ),
                        ),
                        GestureDetector(
                          onHorizontalDragStart: (_) => controller.record(),
                          onHorizontalDragUpdate: (d) {
                            controller.micPos.value = d.localPosition;
                          },
                          onHorizontalDragEnd: (_) =>
                              controller.stopRecord(chat),
                          onHorizontalDragCancel: () =>
                              controller.stopRecord(chat),
                          child: Padding(
                            padding: const EdgeInsets.all(
                              3,
                            ),
                            child: Icon(
                              Iconsax.microphone,
                              color: iconColor,
                              size: 26,
                            ),
                          ),
                        ),
                      ],
                    );
            },
          ),
        )
      ],
    );
  }
}

bool isDrag = false;

import 'package:chatify/src/models/models.dart';
import 'package:chatify/src/theme/theme_widget.dart';
import 'package:chatify/src/ui/chat_view/controllers/controller.dart';
import 'package:chatify/src/ui/common/circular_button.dart';
import 'package:flutter/material.dart';

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
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: controller.textController,
            maxLines: 5,
            minLines: 1,
            style: TextStyle(
              color: ChatifyTheme.of(
                context,
              ).isChatDark
                  ? Colors.white
                  : Theme.of(context).textTheme.headline1!.color,
            ),
            onFieldSubmitted: (x) {
              controller.submitMessage(
                x,
                chat,
              );
            },
            onChanged: (x) {
              controller.isTyping.value = x.isNotEmpty;
            },
            focusNode: controller.focus,
            textInputAction: TextInputAction.newline,
            decoration: InputDecoration(
              fillColor: Colors.transparent,
              filled: true,
              hintText: 'Type a message ...',
              hintStyle: TextStyle(
                color: ChatifyTheme.of(
                  context,
                ).isChatDark
                    ? Colors.white54
                    : null,
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
                            // ImageMessage
                            //     .upload(
                            //   widget.chat,
                            // );
                          },
                          size: 60,
                          icon: Icon(
                            Icons.attach_file,
                            color: ChatifyTheme.of(
                              context,
                            ).chatBackgroundColor.withOpacity(
                                  0.5,
                                ),
                            size: 20,
                          ),
                        ),
                        ValueListenableBuilder<bool>(
                          valueListenable: controller.isRecording,
                          builder: (
                            contex,
                            value,
                            child,
                          ) {
                            return CircularButton(
                              onPressed: () => value,
                              size: 60,
                              icon: Padding(
                                padding: const EdgeInsets.all(
                                  3,
                                ),
                                child: Icon(
                                  Icons.mic_none,
                                  color: ChatifyTheme.of(context)
                                      .chatBackgroundColor
                                      .withOpacity(0.5),
                                  size: 26,
                                ),
                              ),
                            );
                          },
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

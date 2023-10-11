import 'package:chatify/src/models/models.dart';
import 'package:chatify/src/theme/theme_widget.dart';
import 'package:chatify/src/ui/chat_view/body/images/image_bottom_sheet.dart';
import 'package:chatify/src/ui/chat_view/controllers/chat_controller.dart';
import 'package:chatify/src/ui/common/circular_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
    ).chatForegroundColor.withOpacity(0.5);
    return Row(
      children: [
        CircularButton(
          onPressed: () {
            if (controller.isEmoji.value) {
              controller.isEmojiIcon.value = false;
              controller.keyboardController.forceEmoji = false;

              controller.focus.requestFocus();
              SystemChannels.textInput.invokeMethod('TextInput.show');
            } else {
              controller.keyboardController.forceEmoji = true;
              controller.isEmoji.value = true;
              controller.isEmojiIcon.value = true;
              SystemChannels.textInput.invokeMethod('TextInput.hide');
            }
          },
          size: 60,
          icon: Padding(
            padding: const EdgeInsets.all(3),
            child: ValueListenableBuilder<bool>(
              valueListenable: controller.isEmojiIcon,
              builder: (context, isEmoji, child) {
                return AnimatedSwitcher(
                  duration: Duration(milliseconds: 500),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                    return ScaleTransition(
                      scale: animation,
                      child: child,
                    );
                  },
                  child: isEmoji
                      ? Icon(
                          Iconsax.keyboard,
                          key: ValueKey('keyboard_icon'),
                          color: iconColor,
                          size: 26,
                        )
                      : Icon(
                          Iconsax.emoji_normal,
                          key: ValueKey('emoji_icon'),
                          color: iconColor,
                          size: 26,
                        ),
                );
              },
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
              ).chatForegroundColor,
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
                ).chatForegroundColor.withOpacity(0.4),
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
            builder: (contex, isTyping, child) {
              return isTyping
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
                        child: Animate(
                          effects: [
                            ScaleEffect(duration: Duration(milliseconds: 120))
                          ],
                          child: Icon(
                            Iconsax.send_1,
                            color: ChatifyTheme.of(
                              context,
                            ).primaryColor,
                            size: 26,
                          ),
                        ),
                      ),
                    )
                  : Row(
                      children: [
                        CircularButton(
                          onPressed: () {
                            showImagesGallery(contex);
                          },
                          size: 60,
                          icon: Animate(
                            effects: [
                              FadeEffect(
                                duration: Duration(milliseconds: 100),
                              ),
                              ScaleEffect(
                                duration: Duration(milliseconds: 100),
                                begin: Offset(0, 0),
                              )
                            ],
                            child: Icon(
                              Iconsax.document_1,
                              color: iconColor,
                              size: 24,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onHorizontalDragStart: (_) =>
                              controller.voiceController.record(),
                          onHorizontalDragUpdate: (d) {
                            controller.voiceController
                                .setMicPos(d.localPosition);
                            if (d.localPosition.dx < -250) {
                              controller.voiceController.stopRecord();
                            }
                          },
                          onHorizontalDragEnd: (_) =>
                              controller.voiceController.endMicDarg(chat),
                          onHorizontalDragCancel: () =>
                              controller.voiceController.endMicDarg(chat),
                          child: Padding(
                            padding: const EdgeInsets.all(
                              3,
                            ),
                            child: Animate(
                              effects: [
                                ScaleEffect(
                                  duration: Duration(milliseconds: 100),
                                  begin: Offset(0.5, 0.5),
                                )
                              ],
                              child: Icon(
                                Iconsax.microphone,
                                color: iconColor,
                                size: 26,
                              ),
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

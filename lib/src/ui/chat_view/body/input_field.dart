import 'dart:io';

import 'package:chatify/src/localization/get_string.dart';
import 'package:chatify/src/models/models.dart';
import 'package:chatify/src/core/chatify.dart';
import 'package:chatify/src/ui/chat_view/body/images/bottom_sheet.dart';
import 'package:chatify/src/ui/chat_view/controllers/chat_controller.dart';
import 'package:chatify/src/ui/common/circular_button.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import 'package:permission_handler/permission_handler.dart';

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
    final iconColor = Chatify.theme.chatForegroundColor.withOpacity(0.5);
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
              color: Chatify.theme.chatForegroundColor,
              height: 1.1,
              fontSize: 16,
            ),
            focusNode: controller.focus,
            textInputAction: TextInputAction.newline,
            keyboardType: TextInputType.multiline,
            decoration: InputDecoration(
              filled: false,
              hintText: localization(context).message,
              hintStyle: TextStyle(
                fontWeight: FontWeight.normal,
                color: Chatify.theme.chatForegroundColor.withOpacity(0.4),
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
                          contex,
                        );
                      },
                      size: 60,
                      icon: Padding(
                        padding: const EdgeInsets.all(3),
                        child: Animate(
                          effects: [
                            ScaleEffect(duration: Duration(milliseconds: 120)),
                          ],
                          child: Icon(
                            Iconsax.send_1,
                            color: Chatify.theme.primaryColor,
                            size: 26,
                          ),
                        ),
                      ),
                    )
                  : Row(
                      children: [
                        CircularButton(
                          onPressed: () async {
                            if (Platform.isAndroid) {
                              final androidInfo =
                                  await DeviceInfoPlugin().androidInfo;
                              if (androidInfo.version.sdkInt <= 32) {
                                var status = await Permission.storage.status;
                                if (status.isDenied) {
                                  await Permission.storage.request();
                                }
                              } else {
                                var status = await Permission.photos.status;
                                if (status.isDenied) {
                                  await Permission.storage.request();
                                }
                              }
                            }
                            showImagesGallery(contex, controller);
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
                              ),
                            ],
                            child: Icon(
                              Iconsax.document_1,
                              color: iconColor,
                              size: 24,
                            ),
                          ),
                        ),
                        Focus(
                          child: GestureDetector(
                            onTapDown: (details) {
                              controller.preventChatScroll.value = true;
                              controller.voiceController.record();
                            },
                            onTapUp: (details) {
                              controller.preventChatScroll.value = false;
                              controller.voiceController.endMicDarg(chat);
                            },
                            onHorizontalDragStart: (_){
                              controller.preventChatScroll.value = true;
                              controller.voiceController.record();
                            },
                            onHorizontalDragUpdate: (d) {
                              controller.preventChatScroll.value = false;
                              controller.voiceController
                                  .setMicPos(d.localPosition);
                            },
                            onHorizontalDragEnd: (_) {
                              controller.preventChatScroll.value = false;
                              controller.voiceController.endMicDarg(chat);
                            },
                            onHorizontalDragCancel: () {
                              controller.preventChatScroll.value = false;
                              controller.voiceController.endMicDarg(chat);
                            },
                            behavior: HitTestBehavior.opaque,
                            excludeFromSemantics: true,
                            trackpadScrollCausesScale: true,
                            child: Container(
                              height: 50,
                              width: 50,
                              color: Colors.transparent,
                              child: Animate(
                                effects: [
                                  ScaleEffect(
                                    duration: Duration(milliseconds: 100),
                                    begin: Offset(0.5, 0.5),
                                  ),
                                ],
                                child: Icon(
                                  Iconsax.microphone,
                                  color: iconColor,
                                  size: 26,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
            },
          ),
        ),
      ],
    );
  }
}

bool isDrag = false;

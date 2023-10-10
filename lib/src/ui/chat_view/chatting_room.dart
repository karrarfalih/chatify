import 'dart:math';

import 'package:chatify/chatify.dart';
import 'package:chatify/src/models/models.dart';
import 'package:chatify/src/theme/theme_widget.dart';
import 'package:chatify/src/ui/chat_view/body/action_header.dart';
import 'package:chatify/src/ui/chat_view/body/input_box.dart';
import 'package:chatify/src/ui/chat_view/body/input_field.dart';
import 'package:chatify/src/ui/chat_view/body/messages.dart';
import 'package:chatify/src/ui/chat_view/body/record_thumb.dart';
import 'package:chatify/src/ui/chat_view/controllers/controller.dart';
import 'package:chatify/src/ui/chat_view/body/app_bar.dart';
import 'package:chatify/src/ui/common/keyboard_size.dart';
import 'package:chatify/src/utils/context_provider.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' as foundation;

double _Kheight = 300;
double currentKeyboardHieght = 300;
bool isKeybaordOpen = false;

class ChatView extends StatefulWidget {
  const ChatView({
    Key? key,
    required this.chat,
    required this.user,
  }) : super(key: key);
  final Chat chat;
  final ChatifyUser user;
  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  late final ChatController controller;

  @override
  void initState() {
    controller = ChatController(widget.chat);
    super.initState();
  }

  @override
  dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: ChatifyTheme.of(context).isChatDark
          ? SystemUiOverlayStyle.light.copyWith(
              systemNavigationBarDividerColor: Colors.black,
              systemNavigationBarColor: Colors.black,
              systemNavigationBarIconBrightness: Brightness.light,
            )
          : SystemUiOverlayStyle.dark.copyWith(
              systemNavigationBarDividerColor: Colors.white,
              systemNavigationBarColor: Colors.white,
              systemNavigationBarIconBrightness: Brightness.dark,
            ),
      child: KeyboardSizeProvider(
        child: Scaffold(
          key: ContextProvider.chatKey,
          resizeToAvoidBottomInset: false,
          body: Container(
            decoration: ChatifyTheme.of(context).backgroundImage == null
                ? null
                : BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                        ChatifyTheme.of(context).backgroundImage!,
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
            child: Stack(
              alignment: AlignmentDirectional.topCenter,
              children: [
                Column(
                  children: [
                    Expanded(
                      child: ChatMessages(
                        chat: widget.chat,
                        user: widget.user,
                        controller: controller,
                      ),
                    ),
                    MessageActionHeader(
                      controller: controller,
                      user: widget.user,
                    ),
                    ChatInputBox(
                      controller: controller,
                      chat: widget.chat,
                    ),
                    ValueListenableBuilder<bool>(
                      valueListenable: controller.isEmoji,
                      builder: (context, isEmoji, child) {
                        return Consumer<ScreenHeight>(
                          builder: (context, keyboard, child) {
                            currentKeyboardHieght = keyboard.keyboardHeight;
                            if (currentKeyboardHieght == _Kheight &&
                                isEmoji &&
                                !forceEmoji) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                controller.isEmoji.value = false;
                                controller.isEmojiIcon.value = false;
                                forceEmoji = false;
                              });
                            }
                            if (forceEmoji) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                forceEmoji = false;
                              });
                            }
                            return Container(
                              color: ChatifyTheme.of(context).isChatDark
                                  ? Colors.black.withOpacity(0.4)
                                  : Colors.white.withOpacity(0.4),
                              child: SafeArea(
                                top: false,
                                bottom: !isEmoji,
                                child: Container(
                                  height: isEmoji ? 0 : keyboard.keyboardHeight,
                                  color: ChatifyTheme.of(context).isChatDark
                                      ? Colors.black.withOpacity(0.4)
                                      : Colors.white.withOpacity(0.4),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                    ValueListenableBuilder<bool>(
                      valueListenable: controller.isEmoji,
                      builder: (context, isEmoji, child) => Visibility(
                        child: child!,
                        visible: isEmoji,
                      ),
                      child: Consumer<ScreenHeight>(
                        builder: (context, keyboard, child) {
                          isKeybaordOpen = keyboard.isOpen;
                          controller.isKeyboardOpen = isKeybaordOpen;
                          if (keyboard.keyboardHeight > _Kheight) {
                            _Kheight = keyboard.keyboardHeight;
                          }
                          return SizedBox(
                            height: _Kheight,
                            child: child!,
                          );
                        },
                        child: EmojiPicker(
                          textEditingController: controller.textController,
                          config: Config(
                            columns: MediaQuery.of(context).size.width ~/ 45,
                            emojiSizeMax: 24 *
                                (foundation.defaultTargetPlatform ==
                                        TargetPlatform.iOS
                                    ? 1.30
                                    : 1.0),

                            verticalSpacing: 0,
                            horizontalSpacing: 0,
                            gridPadding: EdgeInsets.zero,
                            initCategory: Category.RECENT,
                            bgColor: Theme.of(context).scaffoldBackgroundColor,
                            indicatorColor:
                                ChatifyTheme.of(context).primaryColor,
                            iconColor: Colors.grey,
                            iconColorSelected:
                                ChatifyTheme.of(context).primaryColor,
                            backspaceColor:
                                ChatifyTheme.of(context).primaryColor,
                            skinToneDialogBgColor:
                                Theme.of(context).scaffoldBackgroundColor,
                            skinToneIndicatorColor: Colors.grey,
                            noRecents: const Text(
                              'No Recents',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.black26,
                              ),
                              textAlign: TextAlign.center,
                            ), // Needs to be const Widget
                            loadingIndicator: const SizedBox
                                .shrink(), // Needs to be const Widget
                            buttonMode: ButtonMode.CUPERTINO,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                ChatAppBar(
                  user: widget.user,
                ),
                RecordThumb(controller: controller),
                ValueListenableBuilder<bool>(
                  valueListenable: controller.isRecording,
                  builder: (contex, isRecording, child) {
                    if (!isRecording) return SizedBox.shrink();
                    return ValueListenableBuilder<Offset>(
                      valueListenable: controller.micPos,
                      child: Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: ChatifyTheme.of(context)
                                  .chatForegroundColor
                                  .withOpacity(0.3),
                              blurRadius: 2,
                            )
                          ],
                        ),
                        child: ValueListenableBuilder<bool>(
                          valueListenable: controller.isLocked,
                          builder: (contex, isLocked, _) {
                            return AnimatedSwitcher(
                              duration: Duration(milliseconds: 300),
                              transitionBuilder:
                                  (Widget child, Animation<double> animation) {
                                return ScaleTransition(
                                  scale: animation,
                                  child: child,
                                );
                              },
                              child: isLocked
                                  ? GestureDetector(
                                      key: ValueKey('stop_lock'),
                                      onTap: () => controller.stopRecord(
                                        false,
                                      ),
                                      child: Icon(
                                        Icons.stop_rounded,
                                        color: Colors.red,
                                        size: 30,
                                      ),
                                    )
                                  : Icon(
                                      Iconsax.lock5,
                                      key: ValueKey('lock_icon'),
                                      color: ChatifyTheme.of(context)
                                          .chatForegroundColor,
                                    ),
                            );
                          },
                        ),
                      ),
                      builder: (contex, micOffset, child) {
                        final screenSize = MediaQuery.of(context).size;
                        return ValueListenableBuilder<Offset>(
                          valueListenable: controller.micLockPos,
                          builder: (contex, micLockOffset, _) {
                            return AnimatedPositioned(
                              duration: Duration(milliseconds: 1500),
                              curve: Curves.linear,
                              right: 25,
                              top: screenSize.height -
                                  (micLockOffset.dy * 30) -
                                  (isKeybaordOpen ? currentKeyboardHieght : 0) +
                                  (micOffset.dy / exp(0.5)) -
                                  MediaQuery.of(context).padding.bottom -
                                  160,
                              child: child!,
                            );
                          },
                        );
                      },
                    );
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}


import 'package:chatify/src/theme/theme_widget.dart';
import 'package:chatify/src/ui/chat_view/controllers/chat_controller.dart';
import 'package:chatify/src/ui/common/keyboard_size.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatBottomSpace extends StatelessWidget {
  const ChatBottomSpace({
    super.key,
    required this.controller,
  });

  final ChatController controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: controller.isEmoji,
      builder: (context, isEmoji, child) {
        return Consumer<ScreenHeight>(
          builder: (context, keyboard, child) {
            controller.keyboardController
                .onKeyboardHeightChange(keyboard.keyboardHeight);
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
    );
  }
}

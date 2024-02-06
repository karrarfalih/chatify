import 'package:chatify/src/ui/chat_view/controllers/chat_controller.dart';
import 'package:chatify/src/ui/chat_view/controllers/keyboard_controller.dart';
import 'package:chatify/src/ui/common/keyboard_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class ChatBottomSpace extends StatelessWidget {
  const ChatBottomSpace({
    super.key,
    required this.controller,
  });

  final ChatController controller;

  @override
  Widget build(BuildContext context) {
    final keyboardController = Get.find<KeyboardController>();

    return ValueListenableBuilder<bool>(
      valueListenable: controller.isEmoji,
      builder: (context, isEmoji, child) {
        return Obx(
          () {
            keyboardController.height;
            return Consumer<ScreenHeight>(
              builder: (context, keyboard, child) {
                keyboardController
                    .onKeyboardHeightChange(keyboard.keyboardHeight);
                return _BottomSpaceWidget(
                  key: ValueKey('_BottomSpaceWidget'),
                  isEmoji: isEmoji,
                  keyboardHeight: keyboard.keyboardHeight,
                );
              },
            );
          },
        );
      },
    );
  }
}

class _BottomSpaceWidget extends StatelessWidget {
  const _BottomSpaceWidget({
    super.key,
    required this.isEmoji,
    required this.keyboardHeight,
  });

  final bool isEmoji;
  final double keyboardHeight;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: !isEmoji,
      child: SizedBox(
        height: isEmoji ? 0 : keyboardHeight,
        width: double.maxFinite,
      ),
    );
  }
}

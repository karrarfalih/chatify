
import 'package:chatify/src/ui/chat_view/controllers/chat_controller.dart';
import 'package:chatify/src/ui/common/keyboard_size.dart';
import 'package:chatify/src/ui/common/kr_stream_builder.dart';
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
        return KrStreamBuilder(
          stream: controller.keyboardController.stream ?? Stream.empty(),
          onEmpty: _BottomSpaceWidget(
            key: ValueKey('_BottomSpaceWidget'),
            isEmoji: isEmoji,
            keyboardHeight: 0,
          ),
          onLoading: _BottomSpaceWidget(
            key: ValueKey('_BottomSpaceWidget'),
            isEmoji: isEmoji,
            keyboardHeight: 0,
          ),
          builder: (context) {
            return Consumer<ScreenHeight>(
              builder: (context, keyboard, child) {
                controller.keyboardController
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

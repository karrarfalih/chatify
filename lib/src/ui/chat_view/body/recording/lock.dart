import 'package:chatify/src/core/chatify.dart';
import 'package:chatify/src/ui/chat_view/controllers/chat_controller.dart';
import 'package:chatify/src/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class RecordingLock extends StatelessWidget {
  const RecordingLock({
    super.key,
    required this.controller,
  });

  final ChatController controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: controller.voiceController.isRecording,
      builder: (contex, isRecording, child) {
        if (!isRecording) return SizedBox.shrink();
        return ValueListenableBuilder<Offset>(
          valueListenable: controller.voiceController.micPos,
          child: Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Chatify.theme.chatForegroundColor.withOpacity(0.3),
                  blurRadius: 2,
                )
              ],
            ),
            child: ValueListenableBuilder<bool>(
              valueListenable: controller.voiceController.isLocked,
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
                          onTap: () => controller.voiceController.stopRecord(
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
                          color: Chatify.theme.chatForegroundColor,
                        ),
                );
              },
            ),
          ),
          builder: (contex, micOffset, child) {
            final screenSize = MediaQuery.of(context).size;
            return ValueListenableBuilder<Offset>(
              valueListenable: controller.voiceController.micLockPos,
              builder: (contex, micLockOffset, _) {
                return AnimatedPositioned(
                  duration: Duration(milliseconds: 1500),
                  curve: Curves.linear,
                  right: 25,
                  top: screenSize.height -
                      (micLockOffset.dy * 30) -
                      (controller.keyboardController.isKeybaordOpen ||
                              controller.isEmoji.value
                          ? controller.keyboardController.keyboardHeight -
                              MediaQuery.of(context).padding.bottom
                          : 0) -
                      ((-micOffset.dy + 15).withRange(0, 100) * 0.5) -
                      MediaQuery.of(context).padding.bottom -
                      160,
                  child: child!,
                );
              },
            );
          },
        );
      },
    );
  }
}

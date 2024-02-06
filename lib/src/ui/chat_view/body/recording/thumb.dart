import 'dart:math';
import 'package:chatify/src/ui/chat_view/controllers/chat_controller.dart';
import 'package:chatify/src/ui/chat_view/controllers/keyboard_controller.dart';
import 'package:chatify/src/ui/common/media_query.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:chatify/src/utils/extensions.dart';

class RecordThumb extends StatelessWidget {
  const RecordThumb({
    super.key,
    required this.controller,
  });

  final ChatController controller;

  @override
  Widget build(BuildContext context) {
    final keyboardController = Get.find<KeyboardController>();
    return ValueListenableBuilder<bool>(
      valueListenable: controller.voiceController.isRecording,
      builder: (contex, isRecording, child) {
        if (!isRecording) return SizedBox.shrink();
        return ValueListenableBuilder<double>(
          valueListenable: controller.voiceController.micRadius,
          child: ValueListenableBuilder<bool>(
            valueListenable: controller.voiceController.isLocked,
            builder: (contex, isLocked, _) {
              return Icon(
                isLocked ? Iconsax.send_1 : Iconsax.microphone5,
                color: Colors.white,
              );
            },
          ),
          builder: (contex, radius, child) {
            final screenSize = mediaQuery(context).size;
            return ValueListenableBuilder<Offset>(
              valueListenable: controller.voiceController.micPos,
              builder: (contex, micPos, _) {
                final left = screenSize.width - (radius / 2) - 32 + micPos.dx;
                final primaryColor = Theme.of(context).primaryColor;
                return AnimatedPositioned(
                  duration: Duration(milliseconds: 300),
                  left: left,
                  top: screenSize.height -
                      (radius / 2) -
                      pow((-micPos.dy + 15).withRange(0, 1000), 1 / 1.3) -
                      (keyboardController.isKeybaordOpen ||
                              controller.isEmoji.value
                          ? keyboardController.height -
                              MediaQuery.of(context).padding.bottom
                          : 0) -
                      MediaQuery.of(context).padding.bottom -
                      30,
                  child: GestureDetector(
                    onTap: () => controller.voiceController.stopRecord(),
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      height: radius,
                      width: radius,
                      decoration: BoxDecoration(
                        color: interpolateColor(
                          primaryColor,
                          (screenSize.width -
                                  (left / screenSize.width) *
                                      screenSize.width) *
                              1.6,
                          screenSize.width,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: child,
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

Color interpolateColor(
  Color originalColor,
  double currentXOffset,
  double maxXOffset,
) {
  // Ensure currentXOffset is within the valid range [0, maxXOffset]
  currentXOffset = currentXOffset.clamp(0.0, maxXOffset);

  // Calculate the interpolation factor (between 0 and 1) based on the x offset
  double interpolationFactor = currentXOffset / maxXOffset;

  // Blend the original color with red based on the interpolation factor
  return Color.lerp(originalColor, Colors.red, interpolationFactor)!;
}

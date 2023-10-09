import 'dart:math';

import 'package:chatify/src/ui/chat_view/controllers/controller.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class RecordThumb extends StatelessWidget {
  const RecordThumb({
    super.key,
    required this.controller,
  });

  final ChatController controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: controller.isRecording,
      builder: (contex, isRecording, child) {
        if (!isRecording) return SizedBox.shrink();
        return ValueListenableBuilder<double>(
          valueListenable: controller.micRadius,
          child: Icon(
            Iconsax.microphone,
            color: Colors.white,
          ),
          builder: (contex, radius, child) {
            final screenSize = MediaQuery.of(context).size;
            return ValueListenableBuilder<Offset>(
              valueListenable: controller.micPos,
              builder: (contex, offset, _) {
                final left = screenSize.width -
                    (radius / 2) -
                    32 +
                    offset.dx;
                final primaryColor =
                    Theme.of(context).primaryColor;
                return AnimatedPositioned(
                  duration: Duration(milliseconds: 300),
                  left: left,
                  top: screenSize.height -
                      (radius / 2) +
                      (offset.dy / exp(2)) -
                      MediaQuery.of(context).padding.bottom -
                      30,
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    height: radius,
                    width: radius,
                    decoration: BoxDecoration(
                      color: interpolateColor(
                        primaryColor,
                        (screenSize.width -
                            (left / screenSize.width) *
                                screenSize.width),
                        screenSize.width,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: child,
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

extension Range on double {
  withRange(double minNumber, double maxNumber) =>
      min(max(this, minNumber), maxNumber);
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

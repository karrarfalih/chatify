import 'dart:math';

import 'package:chatify/src/models/models.dart';
import 'package:chatify/src/theme/theme_widget.dart';
import 'package:chatify/src/ui/chat_view/body/action_header.dart';
import 'package:chatify/src/ui/chat_view/body/input_box.dart';
import 'package:chatify/src/ui/chat_view/body/messages.dart';
import 'package:chatify/src/ui/chat_view/controllers/controller.dart';
import 'package:chatify/src/ui/chat_view/body/app_bar.dart';
import 'package:chatify/src/ui/common/keyboard_size.dart';
import 'package:chatify/src/utils/context_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

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
  final controller = ChatController();

  @override
  dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: ChatifyTheme.of(context).isChatDark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      child: KeyboardSizeProvider(
        smallSize: 500.0,
        child: Consumer<ScreenHeight>(
          builder: (context, _res, child) {
            controller.isKeyboardOpen = _res.isOpen;
            return child!;
          },
          child: Scaffold(
            key: ContextProvider.chatKey,
            resizeToAvoidBottomInset: true,
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
                      ChatInputBox(controller: controller, chat: widget.chat),
                    ],
                  ),
                  ChatAppBar(
                    user: widget.user,
                  ),
                  ValueListenableBuilder<bool>(
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
                  )
                ],
              ),
            ),
          ),
        ),
      ),
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

import 'package:chatify/src/core/chatify.dart';
import 'package:chatify/src/localization/get_string.dart';
import 'package:chatify/src/ui/chat_view/controllers/chat_controller.dart';
import 'package:chatify/src/ui/common/media_query.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' as foundation;

class EmojisKeyboard extends StatelessWidget {
  const EmojisKeyboard({
    super.key,
    required this.controller,
  });

  final ChatController controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: controller.isEmoji,
      builder: (context, isEmoji, child) => Visibility(
        child: child!,
        visible: isEmoji,
      ),
      child: WillPopScope(
        onWillPop: () async {
          controller.isEmoji.value = false;
          return false;
        },
        child: SizedBox(
          height: controller.keyboardController.keyboardHeight,
          child: EmojiPicker(
            key: ValueKey('emojis'),
            textEditingController: controller.textController,
            onBackspacePressed: () {},
            config: Config(
              columns: mediaQuery(context).size.width ~/ 45,
              emojiSizeMax: 24 *
                  (foundation.defaultTargetPlatform == TargetPlatform.iOS
                      ? 1.30
                      : 1.0),
              verticalSpacing: 0,
              horizontalSpacing: 0,
              gridPadding: EdgeInsets.zero,
              initCategory: Category.RECENT,
              bgColor: Colors.transparent,
              indicatorColor: Chatify.theme.primaryColor,
              iconColor: Chatify.theme.chatForegroundColor.withOpacity(0.3),

              iconColorSelected: Chatify.theme.primaryColor,
              backspaceColor: Chatify.theme.primaryColor,
              skinToneDialogBgColor: Theme.of(context).scaffoldBackgroundColor,
              skinToneIndicatorColor: Colors.grey,
              enableSkinTones: true,
              noRecents: Text(
                localization(context).noRecentsEmojis,
                style: TextStyle(
                  fontSize: 20,
                  color: Chatify.theme.chatForegroundColor,
                ),
                textAlign: TextAlign.center,
              ), // Needs to be const Widget
              loadingIndicator:
                  const SizedBox.shrink(), // Needs to be const Widget
              buttonMode: ButtonMode.CUPERTINO,
            ),
          ),
        ),
      ),
    );
  }
}

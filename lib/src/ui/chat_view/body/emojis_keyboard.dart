import 'package:chatify/src/theme/theme_widget.dart';
import 'package:chatify/src/ui/chat_view/controllers/chat_controller.dart';
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
      child: SizedBox(
        height: controller.keyboardController.keyboardHeight,
        child: EmojiPicker(
          key: ValueKey('emojis'),
          textEditingController: controller.textController,
          onBackspacePressed: () {
            if (controller.textController.text.isEmpty) {
              controller.isTyping.value = false;
            }
          },
          onEmojiSelected: (category, emoji) {
            controller.isTyping.value = true;
          },
          config: Config(
            columns: MediaQuery.of(context).size.width ~/ 45,
            emojiSizeMax: 24 *
                (foundation.defaultTargetPlatform == TargetPlatform.iOS
                    ? 1.30
                    : 1.0),
            verticalSpacing: 0,
            horizontalSpacing: 0,
            gridPadding: EdgeInsets.zero,
            initCategory: Category.RECENT,
            bgColor: Theme.of(context).scaffoldBackgroundColor,
            indicatorColor: ChatifyTheme.of(context).primaryColor,
            iconColor: Colors.grey,
            iconColorSelected: ChatifyTheme.of(context).primaryColor,
            backspaceColor: ChatifyTheme.of(context).primaryColor,
            skinToneDialogBgColor: Theme.of(context).scaffoldBackgroundColor,
            skinToneIndicatorColor: Colors.grey,
            noRecents: Text(
              'No Recents',
              style: TextStyle(
                fontSize: 20,
                color: ChatifyTheme.of(context).chatForegroundColor,
              ),
              textAlign: TextAlign.center,
            ), // Needs to be const Widget
            loadingIndicator:
                const SizedBox.shrink(), // Needs to be const Widget
            buttonMode: ButtonMode.CUPERTINO,
          ),
        ),
      ),
    );
  }
}

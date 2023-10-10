import 'package:chatify/src/ui/chat_view/controllers/chat_controller.dart';
import 'package:flutter/material.dart';

class KeyboardController {
  final ChatController controller;

  KeyboardController(this.controller);

  double keyboardHeight = 250;
  double currentKeyboardHieght = 250;
  bool isKeybaordOpen = false;

  double _maxKeyBoardHeight = 0;
  bool forceEmoji = false;

  bool _isCalculationFinished = false;
  _calculateMaximumKeyboardHeight(double height) {
    if (_isCalculationFinished) return;
    Future.delayed(Duration(seconds: 5)).then((value) {
      _isCalculationFinished = true;
      keyboardHeight = _maxKeyBoardHeight;
    });
    if (height > _maxKeyBoardHeight) {
      _maxKeyBoardHeight = height;
    }
  }

  onKeyboardHeightChange(double height) {
    currentKeyboardHieght = height;
    if (height > keyboardHeight) {
      keyboardHeight = height;
    }
    if (height == keyboardHeight &&
        controller.isEmoji.value &&
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
    _calculateMaximumKeyboardHeight(height);
  }
}

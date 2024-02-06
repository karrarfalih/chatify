import 'package:chatify/src/ui/chat_view/controllers/chat_controller.dart';
import 'package:chatify/src/utils/cache.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class KeyboardController extends GetxController {
  final ChatController controller;

  KeyboardController(this.controller);

  @override
  void onInit() {
    debounce<double>(
      _actualHeight,
      (value) {
        if (value < 20) return;
        Cache.instance.setDouble('keyboardHeight', value);
        _height.value = value;
      },
      time: const Duration(milliseconds: 300),
    );
    super.onInit();
  }

  final _actualHeight = (Cache.instance.getDouble('keyboardHeight') ?? 250).obs;
  late final _height = _actualHeight.value.obs;

  double get height {
    return _height.value;
  }

  double get actualHeight {
    return _actualHeight.value;
  }

  bool get isKeybaordOpen => _actualHeight.value > 10;

  bool forceEmoji = false;

  onKeyboardHeightChange(double value) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _actualHeight.value = value;
      if (value < 20) return;
      if (value == height && controller.isEmoji.value && !forceEmoji) {
        controller.isEmoji.value = false;
        controller.isEmojiIcon.value = false;
        forceEmoji = false;
      }
      if (forceEmoji) {
        forceEmoji = false;
      }
    });
  }

  @override
  onClose() {
    _actualHeight.close();
    _height.close();
    super.onClose();
  }
}

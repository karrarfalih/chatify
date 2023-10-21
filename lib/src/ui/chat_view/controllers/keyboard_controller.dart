import 'dart:async';

import 'package:chatify/src/ui/chat_view/controllers/chat_controller.dart';
import 'package:chatify/src/utils/cache.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class KeyboardController {
  final ChatController controller;

  KeyboardController(this.controller) {
    stream = keyboardHeightSubject
        .debounceTime(Duration(milliseconds: 300))
        .where((e) => e != 0)
        .distinct(
          (previous, next) => next == previous || next < 10,
        );
    _keyboardSubscription = stream?.listen((e) {
      _keyboardHeight = e;
      Cache.instance.setDouble('keyboardHeight', e);
    });
  }

  StreamSubscription<double>? _keyboardSubscription;
  double get keyboardHeight {
    return _keyboardHeight;
  }

  Stream<double>? stream;

  double _keyboardHeight = Cache.instance.getDouble('keyboardHeight') ?? 250;

  bool isKeybaordOpen = false;

  bool forceEmoji = false;

  BehaviorSubject<double> keyboardHeightSubject =
      BehaviorSubject<double>.seeded(
    Cache.instance.getDouble('keyboardHeight') ?? 250,
  );

  onKeyboardHeightChange(double height) {
    keyboardHeightSubject.add(height);
    if (height == keyboardHeight && controller.isEmoji.value && !forceEmoji) {
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
  }

  dispose() {
    _keyboardSubscription?.cancel();
    keyboardHeightSubject.close();
  }
}

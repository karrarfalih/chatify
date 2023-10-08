import 'dart:developer';
import 'package:flutter/foundation.dart';

class ChatifyLog {
  static void d(String message, {bool isError = false}) {
    if (isError || (kDebugMode)) {
      log(
        message,
        name: 'Chatify',
      );
    }
  }
}

import 'package:chatify/src/theme/theme.dart';
import 'package:flutter/material.dart';

class ChatifyTheme extends InheritedWidget {
  final ChatifyThemeData data;

  const ChatifyTheme({
    required this.data,
    required Widget child,
    Key? key,
  }) : super(key: key, child: child);

  static ChatifyThemeData of(BuildContext context) {
    final ChatifyTheme? theme =
        context.dependOnInheritedWidgetOfExactType<ChatifyTheme>();
    return theme?.data ?? ChatifyThemeData.fallbackTheme(context);
  }

  @override
  bool updateShouldNotify(ChatifyTheme oldWidget) {
    return data != oldWidget.data;
  }
}

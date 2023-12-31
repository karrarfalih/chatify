import 'package:flutter/material.dart';

class ChatifyThemeData {
  final Brightness recentChatsBrightness;
  final Brightness chatBrightness;
  final Color primaryColor;
  final String? backgroundImage;
  final String fontFamily;

  ChatifyThemeData({
    required this.recentChatsBrightness,
    required this.chatBrightness,
    required this.primaryColor,
    this.backgroundImage,
    this.fontFamily = 'Roboto',
  });

  factory ChatifyThemeData.fallbackTheme(BuildContext context) {
    return ChatifyThemeData(
      recentChatsBrightness: Theme.of(context).brightness,
      chatBrightness: Theme.of(context).brightness,
      primaryColor: Theme.of(context).primaryColor,
      fontFamily: Theme.of(context).textTheme.bodyLarge?.fontFamily ?? 'Roboto',
    );
  }

  bool get isChatDark => recentChatsBrightness == Brightness.dark;
  bool get isRecentChatsDark => recentChatsBrightness == Brightness.dark;

  Color get chatForegroundColor =>
      chatBrightness == Brightness.dark ? Colors.white : Colors.black;

  Color get chatGreyForegroundColor => chatBrightness == Brightness.dark
      ? Colors.grey.shade900
      : Colors.grey.shade200;

  Color get recentChatsForegroundColor =>
      recentChatsBrightness == Brightness.dark ? Colors.white : Colors.black;
}

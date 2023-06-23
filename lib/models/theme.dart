import 'package:flutter/material.dart';
import 'package:get/get.dart';

ChatTheme currentTheme = ChatTheme(
  primary: Get.theme.primaryColor,
  titleStyle: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: Color(0xFF141514),
    ),
    subTitleStyle: const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      // height: 1,
      color: Color(0xFFA1A1A1),
    ),
    messageStyle: const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      // height: 1,
      color: Color(0xFFA1A1A1),
    ),

);

class ChatTheme {
  final Color primary;

  const ChatTheme(
      {required this.primary,
      required this.messageStyle,
      required this.subTitleStyle,
      required this.titleStyle});
  final TextStyle titleStyle;
  final TextStyle subTitleStyle;
  final TextStyle messageStyle;
}

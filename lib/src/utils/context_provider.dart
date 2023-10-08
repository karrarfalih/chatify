import 'package:flutter/material.dart';

class ContextProvider {
  static GlobalKey<NavigatorState> recentChatsKey = GlobalKey<NavigatorState>();
  static GlobalKey<NavigatorState> chatKey = GlobalKey<NavigatorState>();
  static BuildContext? get context => recentChatsKey.currentContext ?? chatKey.currentContext;
}
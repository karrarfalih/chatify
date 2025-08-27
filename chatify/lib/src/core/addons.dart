import 'package:chatify/src/core/composer.dart';
import 'package:chatify/src/domain/models/chat.dart';
import 'package:chatify/src/domain/models/messages/message.dart';
import 'package:flutter/material.dart';
import 'package:chatify/src/view/common/options_builder.dart';

enum Layer { normal, elevated, modal }

class HeaderContribution {
  final String id;
  final Layer layer;
  final int priority; // lower first
  final bool Function(BuildContext) isVisible;
  final Widget Function(BuildContext) builder;
  const HeaderContribution({
    required this.id,
    this.layer = Layer.normal,
    this.priority = 0,
    this.isVisible = _always,
    required this.builder,
  });
  static bool _always(BuildContext _) => true;
}

abstract class ChatAddon {
  const ChatAddon();

  // Header
  List<HeaderContribution> buildHeaders(BuildContext c, Chat chat) => const [];

  // Messages area
  Widget wrapMessagesList(BuildContext c, Chat chat, Widget child) => child;
  List<Widget> buildMessagesOverlays(BuildContext c, Chat chat) => const [];

  // Per-message
  Widget wrapMessage(
          BuildContext c, Chat chat, Message m, int i, Widget child) =>
      child;
  Widget? buildMessageLeading(BuildContext c, Chat chat, Message m, int i) =>
      null;
  Widget? buildMessageTrailing(BuildContext c, Chat chat, Message m, int i) =>
      null;
  List<OptionsItem> buildMessageOptions(BuildContext c, Chat chat, Message m) =>
      const [];
  Widget? buildDateSeparator(BuildContext c, DateTime date) => null;
  Widget? buildStatusStrip(BuildContext c, Chat chat) => null;

  // Input/composer
  Widget wrapInput(BuildContext c, Chat chat, Widget child) => child;
  Widget wrapChat(BuildContext c, Chat chat, Widget child) => child;
  List<ComposerAction> get composerActions => const [];
  Widget? buildInputPrefix(BuildContext c, Chat chat) => null;
  Widget? buildInputSuffix(BuildContext c, Chat chat) => null;

  // Lifecycle/events
  void onOpen(BuildContext c, Chat chat) {}
  void onDispose(BuildContext c, Chat chat) {}
}

abstract class ChatsAddon {
  const ChatsAddon();

  // Screen chrome
  List<HeaderContribution> buildHeaders(BuildContext c) => const [];
  Widget wrapScreen(BuildContext c, Widget child) => child;

  // List + overlays
  Widget wrapList(BuildContext c, Widget child) => child;
  List<Widget> buildOverlays(BuildContext c) => const [];

  // Per-chat card
  Widget wrapChatCard(BuildContext c, Chat chat, Widget child) => child;
  List<Widget> buildChatCardBadges(BuildContext c, Chat chat) => const [];
  List<Widget> buildChatCardActions(BuildContext c, Chat chat) => const [];

  // Navigation
  Future<bool> onOpenChat(BuildContext c, Chat chat) async =>
      false; // return true to intercept

  // Lifecycle
  void onEnter(BuildContext c) {}
  void onLeave(BuildContext c) {}
}

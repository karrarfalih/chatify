import 'addons.dart';

class ChatAddonsRegistry {
  ChatAddonsRegistry._();

  static final instance = ChatAddonsRegistry._();

  final List<ChatAddon> chatAddons = [];
  final List<ChatsAddon> chatsAddons = [];

  void registerChatAddons(Iterable<ChatAddon> addons) {
    chatAddons.addAll(addons);
  }

  void registerChatsAddons(Iterable<ChatsAddon> addons) {
    chatsAddons.addAll(addons);
  }
}

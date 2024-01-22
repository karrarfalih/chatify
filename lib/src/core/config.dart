import 'package:chatify/src/enums.dart';
import 'package:chatify/src/models/models.dart';
import 'package:flutter/material.dart';

class ChatifyConfig {
  final String messagesCollectionName;
  final String chatsCollectionName;

  final bool enableLog;
  final ChatifyChatConfig chatConfig;
  final Future<ChatifyUser> Function(String id) _getUserById;
  Future<ChatifyUser> getUserById(String id) async {
    if (id == 'support') {
      return ChatifyUser.support();
    } else {
      return _getUserById(id);
    }
  }

  final Future<List<ChatifyUser>> Function(String query)? getUsersBySearch;
  final Future<List<ChatifyUser>> Function()? getUsersForNewChat;
  final Function(ChatifyUser user)? onUserClick;
  final Function(Message message, ChatifyUser receiver)? onSendMessage;
  final Function(Message message)? onMessageRead;
  final Function(Chat chat)? onOpenChat;
  final Widget? onEmptyChatList;
  final bool showSupportMessages;

  const ChatifyConfig({
    this.messagesCollectionName = 'chatify_messages',
    this.chatsCollectionName = 'chatify_chats',
    this.enableLog = true,
    this.chatConfig = const ChatifyChatConfig(),
    this.getUsersBySearch,
    this.getUsersForNewChat,
    this.onUserClick,
    this.onSendMessage,
    this.onMessageRead,
    this.onOpenChat,
    required Future<ChatifyUser> Function(String id) getUserById,
    this.onEmptyChatList,
    this.showSupportMessages = false,
  }) : _getUserById = getUserById;

  bool get canSearch => getUsersBySearch != null;
  bool get hasUserForNewChat => getUsersForNewChat != null;
  bool get canCreateNewChat => hasUserForNewChat || canSearch;
}

class ChatifyChatConfig {
  final bool canDelete;
  final bool canEdit;
  final bool canReply;
  final bool canForward;
  final bool canPin;
  final List<MessageType> supportedMessages;
  final bool showTypingStatus;
  final bool showActivityStatus;
  final bool showLastSeen;

  const ChatifyChatConfig({
    this.canDelete = true,
    this.canEdit = true,
    this.canReply = true,
    this.canForward = true,
    this.canPin = true,
    this.supportedMessages = MessageType.values,
    this.showTypingStatus = true,
    this.showActivityStatus = true,
    this.showLastSeen = true,
  });
}

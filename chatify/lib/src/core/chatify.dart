import 'provider.dart';
import 'uploader.dart';
import '../domain/chat_repo.dart';
import '../domain/message_repo.dart';
import '../domain/models/chat.dart';
import 'package:flutter/material.dart';
import 'addons.dart';
import 'addons_registry.dart';

class Chatify {
  Chatify._();

  static bool isInitialized = false;

  static late ChatRepo _chatRepo;
  static late MessageRepo Function(Chat chat) _messageRepoFactory;
  static late AttachmentUploader Function(Attachment attachment)
      _uploaderFactory;
  static late List<MessageProvider> _messageProviders;
  static late User _currentUser;

  static ChatRepo get chatRepo {
    if (!isInitialized) {
      throw Exception(
          'Chatify is not initialized. Did you forget to call Chatify.init()?');
    }
    return _chatRepo;
  }

  static set chatRepo(ChatRepo value) {
    _chatRepo = value;
  }

  static MessageRepo messageRepo(Chat chat) {
    if (!isInitialized) {
      throw Exception(
          'Chatify is not initialized. Did you forget to call Chatify.init()?');
    }
    return _messageRepoFactory(chat);
  }

  static set messageRepoFactory(MessageRepo Function(Chat chat) value) {
    _messageRepoFactory = value;
  }

  static AttachmentUploader uploader(Attachment attachment) {
    if (!isInitialized) {
      throw Exception(
          'Chatify is not initialized. Did you forget to call Chatify.init()?');
    }
    return _uploaderFactory(attachment);
  }

  static set uploaderFactory(
      AttachmentUploader Function(Attachment attachment) value) {
    _uploaderFactory = value;
  }

  static List<MessageProvider> get messageProviders {
    if (!isInitialized) {
      throw Exception(
          'Chatify is not initialized. Did you forget to call Chatify.init()?');
    }
    return _messageProviders;
  }

  static set messageProviders(List<MessageProvider> value) {
    _messageProviders = value;
  }

  static User get currentUser {
    if (!isInitialized) {
      throw Exception(
          'Chatify is not initialized. Did you forget to call Chatify.init()?');
    }
    return _currentUser;
  }

  static Future<void> init({
    required User currentUser,
    required ChatRepo chatRepo,
    required MessageRepo Function(Chat chat) messageRepoFactory,
    required AttachmentUploader Function(Attachment attachment) uploaderFactory,
    required List<MessageProvider> messageProviders,
    List<ChatAddon> chatAddons = const [],
    List<ChatsAddon> chatsAddons = const [],
  }) async {
    _currentUser = currentUser;
    _chatRepo = chatRepo;
    _messageRepoFactory = messageRepoFactory;
    _uploaderFactory = uploaderFactory;
    _messageProviders = messageProviders;
    if (chatAddons.isNotEmpty) {
      ChatAddonsRegistry.instance.registerChatAddons(chatAddons);
    }
    if (chatsAddons.isNotEmpty) {
      ChatAddonsRegistry.instance.registerChatsAddons(chatsAddons);
    }
    isInitialized = true;
  }

  static Future<void> dispose() async {
    isInitialized = false;
  }

  static Future<void> openChatById(
    BuildContext context, {
    required String chatId,
    GlobalKey<NavigatorState>? navigatorKey,
  }) async {
    final result = await chatRepo.findById(chatId);
    if (!result.isSuccess || result.data == null || !context.mounted) return;
    final chat = result.data!;
    final navigator = navigatorKey != null
        ? navigatorKey.currentState
        : Navigator.of(context);
    if (navigator == null) return;
    await navigator.pushReplacementNamed('/chat', arguments: {'chat': chat});
  }

  static Future<void> openChatByUser(
    BuildContext context, {
    required User user,
    GlobalKey<NavigatorState>? navigatorKey,
  }) async {
    var chat = await chatRepo.findByUser(user.id);
    if (chat.data == null) {
      chat = await chatRepo.create([currentUser, user]);
    }
    if (!context.mounted) return;
    if (!chat.isSuccess || chat.data == null) return;
    final navigator = navigatorKey != null
        ? navigatorKey.currentState
        : Navigator.of(context);
    if (navigator == null) return;
    await navigator
        .pushReplacementNamed('/chat', arguments: {'chat': chat.data});
  }
}

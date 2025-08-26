import 'package:chatify/src/core/provider.dart';
import 'package:chatify/src/core/uploader.dart';
import 'package:chatify/src/domain/chat_repo.dart';
import 'package:chatify/src/domain/message_repo.dart';
import 'package:chatify/src/domain/models/chat.dart';
import 'package:flutter/material.dart';

class Chatify {
  Chatify._();

  static bool isInitialized = false;

  static late ChatRepo _chatRepo;
  static late MessageRepo Function(Chat chat) _messageRepoFactory;
  static late AttachmentUploader Function(Attachment attachment) _uploaderFactory;
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

  static set uploaderFactory(AttachmentUploader Function(Attachment attachment) value) {
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
  }) async {
    _currentUser = currentUser;
    _chatRepo = chatRepo;
    _messageRepoFactory = messageRepoFactory;
    _uploaderFactory = uploaderFactory;
    _messageProviders = messageProviders;
    isInitialized = true;
  }

  static Future<void> dispose() async {
    isInitialized = false;
  }

  Future<void> openChatById(
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
    await navigator.pushNamed('/chat', arguments: {'chat': chat});
  }

  Future<void> openChatByUser(
    BuildContext context, {
    required User receiverUser,
    GlobalKey<NavigatorState>? navigatorKey,
  }) async {
    var chat = await chatRepo.findByUser(receiverUser.id);
    if (chat.data == null) {
      chat = await chatRepo.create([currentUser, receiverUser]);
    }
    if (!context.mounted) return;
    if (!chat.isSuccess || chat.data == null) return;
    final navigator = navigatorKey != null
        ? navigatorKey.currentState
        : Navigator.of(context);
    if (navigator == null) return;
    await navigator.pushNamed('/chat', arguments: {'chat': chat});
  }
}

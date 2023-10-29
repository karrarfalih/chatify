import 'dart:async';

import 'package:chatify/chatify.dart';
import 'package:chatify/src/firebase/firestore.dart';
import 'package:chatify/src/ui/chat_view/chatting_room.dart';
import 'package:chatify/src/ui/common/swipeable_page_route.dart';
import 'package:chatify/src/utils/cache.dart';
import 'package:chatify/src/utils/log.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class Chatify {
  static late ChatifyDatasource _datasource;
  static late ChatifyThemeData theme;

  /// The current datasource for the Chatify library.
  static ChatifyDatasource get datasource {
    if (!isInititialized) {
      throw Exception('Chatify is not initialized.');
    }
    return _datasource;
  }

  /// Sets the datasource for the Chatify library.
  static set datasource(ChatifyDatasource value) {
    _datasource = value;
  }

  static late ChatifyConfig _config;
  static bool isInititialized = false;

  /// The current configuration for the Chatify library.
  static ChatifyConfig get config {
    if (!isInititialized) {
      throw Exception('Chatify is not initialized.');
    }
    return _config;
  }

  /// Sets the configuration for the Chatify library.
  static set config(ChatifyConfig value) {
    ChatifyLog.d('Configs added.');
    _config = value;
  }

  static late String _currentUserId;

  /// The current user id for the Chatify library.
  static String get currentUserId => _currentUserId;

  /// Sets the current user id for the Chatify library.
  static set currentUserId(String value) {
    ChatifyLog.d('Current user id added: $value');
    _currentUserId = value;
  }

  static Future<void> init({
    required ChatifyConfig config,
    required String currentUserId,
  }) async {
    _config = config;
    if (isInititialized) {
      _removeConnectionHandler(_currentUserId);
    }
    _currentUserId = currentUserId;
    _setConnectionHandler(currentUserId);
    datasource = ChatifyDatasource(
      messagesCollectionName: config.messagesCollectionName,
      chatsCollectionName: config.chatsCollectionName,
    );
    await Cache.init();
    isInititialized = true;
    ChatifyLog.d('Chatify initialized.');
  }

  static StreamSubscription<DatabaseEvent>? _onMessageAddedSubscription;

  static void _setConnectionHandler(String userId) {
    final ref = FirebaseDatabase.instance.ref("users/$userId");
    ref.onDisconnect().set({
      'isActive': false,
      'lastConnection': ServerValue.timestamp,
      'chats': null,
    });
    _onMessageAddedSubscription =
        FirebaseDatabase.instance.ref('.info/connected').onValue.listen(
      (event) {
        final isConnected = event.snapshot.value == true;
        ref.set({
          'isActive': isConnected,
          'lastConnection': ServerValue.timestamp,
          if (!isConnected) 'chats': null,
        });
        ChatifyLog.d('User ${isConnected ? 'connected' : 'disconnected'}.');
      },
    );
  }

  static void _removeConnectionHandler(String userId) {
    final ref = FirebaseDatabase.instance.ref("users/$userId");
    ref.set({
      'online': false,
      'lastSeen': ServerValue.timestamp,
    });
    ref.onDisconnect().cancel();
    _onMessageAddedSubscription?.cancel();
  }

  static void endUserSeasion(String userId) {
    _removeConnectionHandler(userId);
    ChatifyLog.d('User session ended.');
  }

  static openAllChats(BuildContext context) {
    Navigator.of(context).push(
      SwipeablePageRoute(
        builder: (context) => ChatScreen(),
      ),
    );
  }

  static openChatByUser(
    BuildContext context, {
    required ChatifyUser user,
  }) async {
    final chat = await datasource.findChatOrCreate([user.id, currentUserId]);
    Navigator.of(context).push(
      SwipeablePageRoute(
        builder: (context) => ChatView(chat: chat, users: [user]),
      ),
    );
  }

  static openChat(
    BuildContext context, {
    required Chat chat,
    required ChatifyUser user,
  }) async {
    Navigator.of(context).push(
      SwipeablePageRoute(
        builder: (context) => ChatView(chat: chat, users: [user]),
      ),
    );
  }

  static Stream<int> get unreadMessagesCount {
    return datasource.getUnreadMessagesCount;
  }
}

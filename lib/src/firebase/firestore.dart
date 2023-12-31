import 'package:chatify/chatify.dart';
import 'package:chatify/src/models/messages/mapper.dart';
import 'package:chatify/src/utils/cache.dart';
import 'package:chatify/src/utils/extensions.dart';
import 'package:chatify/src/utils/identical_list.dart';
import 'package:chatify/src/utils/log.dart';
import 'package:chatify/src/utils/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:firebase_database/firebase_database.dart' hide Query;
import 'package:flutter/foundation.dart';

class ChatifyDatasource {
  final instance = FirebaseFirestore.instance;
  final String messagesCollectionName;
  final String chatsCollectionName;

  ChatifyDatasource({
    this.messagesCollectionName = 'chatify_messages',
    this.chatsCollectionName = 'chatify_chats',
  });

  CollectionReference<Message> get _messages => FirebaseFirestore.instance
      .collection(messagesCollectionName)
      .withConverter<Message>(
        fromFirestore: (snapshot, _) => getMessageFromJson(snapshot.data()!),
        toFirestore: (message, _) => message.toJson,
      );

  CollectionReference<Chat> get _chats => FirebaseFirestore.instance
      .collection(chatsCollectionName)
      .withConverter<Chat>(
        fromFirestore: (snapshot, _) =>
            Chat.fromJson(snapshot.data()!, snapshot.id),
        toFirestore: (chat, _) => chat.toJson,
      );

  Future<Message?> readMessage(String messageId) async {
    return (await _messages.doc(messageId).get()).data();
  }

  Future<void> addMessage(Message message, ChatifyUser? user) async {
    await _messages.doc(message.id).set(message, SetOptions(merge: true));
    if (user != null) Chatify.config.onSendMessage?.call(message, user);
    ChatifyLog.d('addMessage');
  }

  Future<void> updateMessageUsingFieldValue(
    String messageId,
    Map<String, FieldValue> data,
  ) async {
    await _messages.doc(messageId).update(data);
    ChatifyLog.d('updateMessageUsingFieldValue');
  }

  Future<VoiceMessage?> getNextVoice(Message message) async {
    if (message.sendAt == null) return null;
    final res = await _messages
        .where('chatId', isEqualTo: message.chatId)
        .where('sendAt', isGreaterThan: message.sendAt)
        .where('type', isEqualTo: MessageType.voice.name)
        .where('canReadBy', arrayContains: Chatify.currentUserId)
        .orderBy('sendAt', descending: false)
        .startAfter([message.sendAt!.stamp])
        .limit(1)
        .get();
    if (res.docs.isNotEmpty) {
      return res.docs.first.data() as VoiceMessage;
    }
    return null;
  }

  Future<void> addMessageEmojis(String messageId, String emoji) async {
    await _messages.doc(messageId).update({
      'emojis': FieldValue.arrayUnion(
        [MessageEmoji(emoji: emoji, uid: Chatify.currentUserId).toJson],
      )
    });
    ChatifyLog.d('addMessageEmojis');
  }

  Future<void> removeMessageEmojis(String messageId) async {
    ChatifyLog.d('removeMessageEmojis');

    return FirebaseFirestore.instance.runTransaction((t) async {
      final msg = await t.get(_messages.doc(messageId));
      final emojis = msg.data()!.emojis;
      emojis.removeWhere((e) => e.uid == Chatify.currentUserId);
      t.update(
        _messages.doc(messageId),
        {'emojis': emojis.map((e) => e.toJson)},
      );
    });
  }

  Future<void> deleteMessageForAll(String id) async {
    await _messages.doc(id).delete();
    ChatifyLog.d('deleteMessageForAll');
  }

  Future<void> deleteMessageForMe(String id) async {
    await _messages.doc(id).update({
      'canReadBy': FieldValue.arrayRemove([Chatify.currentUserId])
    });
    ChatifyLog.d('deleteMessageForMe');
  }

  Future<void> markAsSeen(String id) async {
    ChatifyLog.d('markAsSeen');

    await _messages.doc(id).update({
      'unSeenBy': FieldValue.arrayRemove([Chatify.currentUserId]),
      'seenBy': FieldValue.arrayUnion([Chatify.currentUserId])
    });
  }

  Future<void> markAllMessagesAsSeen(String chatId) async {
    final unSeenMessages = await _messages
        .where('chatId', isEqualTo: chatId)
        .where('unSeenBy', arrayContains: Chatify.currentUserId)
        .get();
    for (final message in unSeenMessages.docs) {
      await markAsSeen(message.id);
    }
    ChatifyLog.d('markAllMessagesAsSeen');
  }

  Future<void> markAsDelivered(String id) async {
    await _messages.doc(id).update({
      'deliveredTo': FieldValue.arrayUnion([Chatify.currentUserId])
    });
    ChatifyLog.d('markAsDelivered');
  }

  Future<void> addChat(Chat chat) async {
    await _chats.doc(chat.id).set(chat, SetOptions(merge: true));
    ChatifyLog.d('addChat');
  }

  Future<Chat> findChatOrCreate(List<String> members) async {
    bool isExist = MemoryCache.cache.entries.any(
      (e) =>
          e.value is Chat &&
          (e.value as Chat).members.hasSameElementsAs(members),
    );
    if (isExist) {
      return MemoryCache.cache.entries
          .firstWhere(
            (e) =>
                e.value is Chat &&
                (e.value as Chat).members.hasSameElementsAs(members),
          )
          .value as Chat;
    }
    final res = await _chats
        .where('membersCount', isEqualTo: members.length)
        .where('members', whereIn: [members, members.reversed.toList()]).get();
    if (res.size > 0) return res.docs.first.data();
    final chat = Chat(id: Uuid.generate(), members: members);
    return chat;
  }

  Future<void> deleteChatForMe(String id) async {
    await instance.runTransaction((transaction) async {
      final chat = await transaction.get(_chats.doc(id));
      final readAfter = chat.data()!.readAfter;
      transaction.update(_chats.doc(id), {
        'readAfter': {
          ...readAfter,
          Chatify.currentUserId: FieldValue.serverTimestamp()
        }
      });
    });
  }

  Future<void> deleteChatForAll(String chatId) async {
    final chat = await _chats.doc(chatId).get();
    final unSeenMessages = await _messages
        .where('chatId', isEqualTo: chatId)
        .where(
          'unSeenBy',
          arrayContains: chat
              .data()!
              .members
              .where((e) => e != Chatify.currentUserId)
              .first,
        )
        .get();
    for (final message in unSeenMessages.docs) {
      message.reference.update({
        'unSeenBy': [],
        'seenBy': chat.data()!.members.toList(),
      });
    }
    await _chats.doc(chatId).delete();
  }

  Query<Message> messagesQuery(Chat chat) {
    return _messages
        .where('chatId', isEqualTo: chat.id)
        .where('canReadBy', arrayContains: Chatify.currentUserId)
        .where(
          'sendAt',
          isGreaterThan:
              (chat.readAfter[Chatify.currentUserId] ?? DateTime(1990)).stamp,
        )
        .orderBy('sendAt', descending: true);
  }

  Query<Chat> get chatsQuery {
    return _chats
        .where('members', arrayContains: Chatify.currentUserId)
        .orderBy('updatedAt', descending: true);
  }

  Query<Message> unSeenMessages(String chatId) {
    return _messages
        .where('chatId', isEqualTo: chatId)
        .where('unSeenBy', arrayContains: Chatify.currentUserId);
  }

  Stream<int> unSeenMessagesCount(String chatId) =>
      unSeenMessages(chatId).snapshots().map((e) => e.size);

  Stream<int> get getUnreadMessagesCount {
    return _messages
        .where('unSeenBy', arrayContains: Chatify.currentUserId)
        .snapshots()
        .map((e) => e.docs.map((e) => e.data().chatId).toSet().length);
  }

  Future<Message?> lastMessage(Chat chat) async {
    var data = await messagesQuery(chat).limit(1).get();
    if (data.docs.isNotEmpty) return data.docs.first.data();
    return null;
  }

  Stream<Message?> lastMessageStream(Chat chat) {
    return messagesQuery(chat).limit(1).snapshots().map((event) {
      if (event.docs.isNotEmpty) return event.docs.first.data();
      return null;
    });
  }

  Stream<UserLastSeen> getUserLastSeen(String userId, String chatId) {
    return FirebaseDatabase.instance
        .ref("users/$userId")
        .onValue
        .asBroadcastStream()
        .map((event) {
      final data = event.snapshot.value;
      if (data is Map) {
        return UserLastSeen(
          isActive: data['isActive'] == true,
          lastSeen: data['lastSeen'] == null
              ? null
              : DateTime.fromMillisecondsSinceEpoch(data['lastSeen']),
          lastConnection: data['lastConnection'] == null
              ? null
              : DateTime.fromMillisecondsSinceEpoch(data['lastConnection']),
        );
      }
      return UserLastSeen(isActive: false);
    });
  }

  Stream<ChatStatus> getChatStatus(String userId, String chatId) {
    return FirebaseDatabase.instance
        .ref("users/$userId/chats/$chatId/status")
        .onValue
        .map((event) {
      final data = event.snapshot.value;
      if (data is String) {
        final chatStatus = ChatStatus.values.firstWhere(
          (e) => e.name == data,
          orElse: () => ChatStatus.none,
        );
        return chatStatus;
      }
      return ChatStatus.none;
    });
  }

  updateChatStaus(ChatStatus status, String chatId) {
    if (status == ChatStatus.none) {
      FirebaseDatabase.instance
          .ref("users/${Chatify.currentUserId}/chats/$chatId")
          .remove();
      return;
    }
    FirebaseDatabase.instance
        .ref("users/${Chatify.currentUserId}/chats/$chatId")
        .update({'status': status.name});
  }

  updateUserStaus(bool isOnline) {
    FirebaseDatabase.instance
        .ref("users/${Chatify.currentUserId}")
        .runTransaction((value) {
      if (value is Map) {
        if (value['isActive'] == isOnline) {
          return Transaction.abort();
        }
        value['isActive'] = isOnline;
        value['lastSeen'] =
            isOnline ? null : DateTime.now().millisecondsSinceEpoch;
        if (!isOnline) value['chats'] = null;
        return Transaction.success(value);
      }
      return Transaction.abort();
    });
  }

  void testAllQueries() {
    if (kDebugMode) {
      //next voice query
      _messages
          .where('chatId', isEqualTo: '')
          .where('sendAt', isGreaterThan: '')
          .where('type', isEqualTo: MessageType.voice.name)
          .where('canReadBy', arrayContains: '')
          .orderBy('sendAt', descending: false)
          .limit(1)
          .get();

      //find chat or create
      _chats
          .where('membersCount', isEqualTo: 0)
          .where('members', whereIn: [[], [].reversed.toList()])
          .limit(1)
          .get();

      //messages query
      _messages
          .where('chatId', isEqualTo: '')
          .where('canReadBy', arrayContains: '')
          .where(
            'sendAt',
            isGreaterThan: DateTime.now().stamp,
          )
          .orderBy('sendAt', descending: true)
          .limit(1)
          .get();

      //unseen messages
      _messages
          .where('chatId', isEqualTo: '')
          .where('unSeenBy', arrayContains: '')
          .limit(1)
          .get();

      //last message
      _messages
          .where('chatId', isEqualTo: '')
          .orderBy('sendAt', descending: true)
          .limit(1)
          .get();
    }
  }
}

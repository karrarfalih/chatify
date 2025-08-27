import 'package:chatify/chatify.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'from_json/message.dart';
import 'helper.dart';
import 'to_json/chat.dart';
import 'to_json/reply.dart';
import 'paginated_stream.dart';

class FirestoreMessageRepo extends MessageRepo with FirestoreHelper {
  FirestoreMessageRepo(super.chat);

  User get sender => chat.sender;
  User get receiver => chat.receiver;
  String get chatId => chat.id;

  late final _stream = PaginatedFirestoreStream(
    query: messagesCollection
        .where('chatId', isEqualTo: chat.id)
        .where('canReadBy', arrayContains: chat.sender.id)
        .orderBy('sentAt', descending: true),
    limit: 20,
  );

  @override
  Stream<PaginatedResult<Message>> messagesStream() => _stream.stream.map(
    (e) => e.map((doc) => messageFromJson(doc.data(), doc.id, sender.id)),
  );

  @override
  void loadMore() {
    _stream.fetch();
  }

  @override
  FutureResult<bool> add(
    MessageContent message,
    ReplyMessage? reply, {
    String? attachmentUrl,
  }) async {
    return instance.runTransaction<Result<bool>>((transaction) async {
      final messageDoc = messagesCollection.doc(message.id);
      final chatDoc = chatsCollection.doc(chatId);
      transaction.set(messageDoc, {
        ...message.toJson(),
        if (attachmentUrl != null) 'attachmentUrl': attachmentUrl,
        'reply': replyMessageToJson(reply),
        'chatId': chatId,
        'sender': userToJson(sender),
        'receiver': userToJson(receiver),
        'canReadBy': [sender.id, receiver.id],
        'unSeenBy': [receiver.id],
        'seenBy': [sender.id],
        'deliveredTo': [sender.id],
        'sentAt': FieldValue.serverTimestamp(),
        'type': message.runtimeType.toString(),
        'isEdited': false,
        'isDeleted': false,
      });
      transaction.update(chatDoc, {
        'lastMessage': message.content,
        'unseenBy_${receiver.id}': FieldValue.arrayUnion([message.id]),
        'updatedAt': FieldValue.serverTimestamp(),
        'lastMessageSender': sender.id,
        'isEmpty': false,
      });
      return const Result.success(true);
    });
  }

  @override
  FutureResult<bool> update(String content, String messageId) {
    return handleUpdate(messagesCollection.doc(messageId), {
      'message': content,
      'isEdited': true,
    });
  }

  @override
  FutureResult<bool> delete(String id, bool forMe) {
    return handleUpdate(messagesCollection.doc(id), {
      if (forMe)
        'canReadBy': FieldValue.arrayRemove([sender.id])
      else
        'isDeleted': true,
    });
  }

  @override
  FutureResult<Message> getById(String messageId) async {
    final doc = messagesCollection.doc(messageId);
    return await handleGet<Message>(
      doc,
      (data) => messageFromJson(data, messageId, sender.id),
    );
  }

  @override
  FutureResult<bool> addReaction(String messageId, String emoji) {
    return instance
        .runTransaction<Result<bool>>((transaction) async {
          final doc = messagesCollection.doc(messageId);
          final message = await transaction.get(doc);
          final emojis = List.from(message.data()?['emojis'] ?? []);
          final oldEmoji = emojis.firstWhere(
            (e) => e['userId'] == sender.id,
            orElse: () => null,
          )?['emoji'];
          emojis.removeWhere((e) => e['userId'] == sender.id);
          if (oldEmoji == null || oldEmoji != emoji) {
            emojis.add({'userId': sender.id, 'emoji': emoji});
          }
          transaction.update(doc, {'emojis': emojis});
          return const Result.success(true);
        })
        .catchError((e) => Result<bool>.failure(e.toString()));
  }

  @override
  FutureResult<bool> removeReaction(String id, String emoji) {
    return instance
        .runTransaction<Result<bool>>((transaction) async {
          final doc = messagesCollection.doc(id);
          final message = await transaction.get(doc);
          final emojis = List.from(message.data()?['emojis'] ?? []);
          emojis.removeWhere(
            (e) => e['userId'] == sender.id && e['emoji'] == emoji,
          );
          transaction.update(doc, {'emojis': emojis});
          return const Result.success(true);
        })
        .catchError((e) => Result<bool>.failure(e.toString()));
  }

  @override
  FutureResult<bool> markAsSeen(String id) {
    return instance.runTransaction<Result<bool>>((transaction) async {
      final messageDoc = messagesCollection.doc(id);
      final chatDoc = chatsCollection.doc(chatId);
      transaction.update(messageDoc, {
        'unSeenBy': FieldValue.arrayRemove([sender.id]),
        'seenBy': FieldValue.arrayUnion([sender.id]),
      });
      transaction.update(chatDoc, {
        'unseenBy_${sender.id}': FieldValue.arrayRemove([id]),
      });
      return const Result.success(true);
    });
  }

  @override
  FutureResult<bool> markAsDelivered(String id) {
    final query = messagesCollection.doc(id);
    return handleUpdate(query, {
      'deliveredTo': FieldValue.arrayUnion([sender.id]),
    });
  }

  @override
  FutureResult<bool> updateStatus(ChatStatus status) async {
    try {
      final ref = chatsDatabase.ref('chats/$chatId');
      await ref.update({sender.id: status.name});
      if (status == ChatStatus.none) {
        ref.onDisconnect().remove();
      } else {
        ref.onDisconnect().set({'sender': ChatStatus.none.name});
      }
      return const Result.success(true);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  @override
  Stream<ChatStatus> getStatus() {
    final ref = chatsDatabase.ref('chats/$chatId/${receiver.id}');
    return ref.onValue.map((e) {
      if (!e.snapshot.exists) return ChatStatus.none;
      return ChatStatus.values.byName(e.snapshot.value as String);
    });
  }

  @override
  void dispose() {
    _stream.dispose();
    updateStatus(ChatStatus.none);
  }
}

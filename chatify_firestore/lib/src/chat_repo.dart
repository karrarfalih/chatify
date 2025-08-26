import 'package:chatify/chatify.dart';

import 'helper.dart';
import 'from_json/chat.dart';
import 'paginated_stream.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreChatRepo extends ChatRepo with FirestoreHelper {
  FirestoreChatRepo({required super.userId});

  late final _stream = PaginatedFirestoreStream(
    query: chatsCollection
        .where('members', arrayContains: userId)
        .where('isEmpty', isEqualTo: false)
        .orderBy('updatedAt', descending: true),
    limit: 20,
  );

  @override
  Stream<PaginatedResult<Chat>> chatsStream() => _stream.stream.map(
    (e) => e.map((doc) => chatFromJson(doc.data(), userId)),
  );

  @override
  void loadMore() {
    _stream.fetch();
  }

  @override
  FutureResult<Chat> create(List<User> members) async {
    final doc = chatsCollection.doc();
    await doc.set({
      'id': doc.id,
      'members': members.map((e) => e.id).toList(),
      'membersDetails': {
        for (var member in members)
          member.id: {
            'id': member.id,
            'name': member.name,
            'imageUrl': member.imageUrl,
          },
      },
      'updatedAt': FieldValue.serverTimestamp(),
      for (var member in members) 'readAfter_${member.id}': null,
      for (var member in members) 'unseenBy_${member.id}': <String>[],
      'lastMessage': null,
      'lastMessageSender': null,
      'isEmpty': true,
    });

    final created = await findById(doc.id);
    return created;
  }

  @override
  FutureResult<Chat> findById(String id) {
    final doc = chatsCollection.doc(id);
    return handleGet(doc, (data) => chatFromJson(data, userId));
  }

  @override
  FutureResult<Chat?> findByUser(String receiverId) {
    final query = chatsCollection
        .where('members', isEqualTo: [userId, receiverId])
        .where('members', isEqualTo: [receiverId, userId]);
    return handleGetFirstItem(
      query,
      (data) => chatFromJson(data.data(), userId),
    );
  }

  @override
  FutureResult<bool> delete(String id) async {
    return await instance
        .runTransaction<Result<bool>>((transaction) async {
          final doc = chatsCollection.doc(id);
          final chat = await transaction.get(doc);
          final readAfter = chat.data()!['readAfter'];
          transaction.update(doc, {
            'readAfter': {...readAfter, userId: FieldValue.serverTimestamp()},
          });
          return const Result.success(true);
        })
        .catchError((e) => Result<bool>.failure(e.toString()));
  }

  @override
  Stream<int> get unreadCountStream {
    return messagesCollection
        .where('unSeenBy', arrayContains: userId)
        .snapshots()
        .map((event) => event.docs.length);
  }

  @override
  void dispose() {
    _stream.dispose();
  }
}

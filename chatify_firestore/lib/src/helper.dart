import 'package:chatify/chatify.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart' as db;


mixin FirestoreHelper {
  final instance = FirebaseFirestore.instance;
  late final chatsCollection = instance.collection('chatify_chats');
  late final messagesCollection = instance.collection('chatify_messages');

  late final chatsDatabase = db.FirebaseDatabase.instance;

  FutureResult<T> handleGet<T>(
    DocumentReference<Map<String, dynamic>> reference,
    T Function(Map<String, dynamic>) converter,
  ) async {
    try {
      final snapshot = await reference.get();
      if (snapshot.exists) return Result.success(converter(snapshot.data()!));
      return Result.failure('data not found');
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  FutureResult<T?> handleGetFirstItem<T>(
    Query<Map<String, dynamic>> query,
    T Function(QueryDocumentSnapshot<Map<String, dynamic>>) converter,
  ) async {
    try {
      final snapshot = await query.limit(1).get();
      if (snapshot.docs.isNotEmpty) {
        return Result.success(converter(snapshot.docs.first));
      }
      return Result.success(null);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  FutureResult<bool> handleSet(
    DocumentReference<Map<String, dynamic>> reference,
    Map<String, dynamic> data,
  ) async {
    try {
      await reference.set(data);
      return Result.success(true);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  FutureResult<bool> handleUpdate(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) async {
    try {
      await reference.update(data);
      return Result.success(true);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  FutureResult<bool> handleDelete(DocumentReference reference) async {
    try {
      await reference.delete();
      return Result.success(true);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:example/models/user.dart';

class FirestoreReferences {
  FirestoreReferences();

  final instance = FirebaseFirestore.instance;

  static const String _users = 'users';

  CollectionReference<User> get users =>
      instance.collection(_users).withConverter(
            fromFirestore: (snapshot, _) => User.fromMap(snapshot.data()!),
            toFirestore: (user, _) => user.toMap(),
          );

  CollectionReference<T> collection<T>() {
    switch (T) {
      case User:
        return users as CollectionReference<T>;
      default:
        throw Exception('Collection not found');
    }
  }
}

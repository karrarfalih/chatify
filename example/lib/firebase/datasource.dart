import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:example/firebase/cache.dart';
import 'package:example/firebase/references.dart';
import 'package:example/models/base_model.dart';
import 'package:example/models/user.dart';
import 'package:example/utilz/extensions.dart';

part 'queries.dart';

class Datasource {
  final _cache = Cache(supportedTypes: [User]);
  final _collections = FirestoreReferences();

  Future<T?> get<T>(String id) async {
    final cached = _cache.get<T>(id);
    if (cached != null) {
      return cached;
    }
    final res = await _collections.collection<T>().doc(id).get();
    return _cache.set(id, res.data());
  }

  Future<T?> getByPostAndUserId<T>(String postId, String userId) async {
    final cached = _cache.get<T>(postId);
    if (cached != null) {
      return cached;
    }
    final res = await _collections.collection<T>().doc('$postId$userId').get();
    return res.data();
  }

  Future<void> put<T>(T data) async {
    _cache.set((data as BaseModel).id, data);
    await _collections
        .collection<T>()
        .doc(data.id)
        .set(data, SetOptions(merge: true));
  }

  Future<void> delete<T>(T data) async {
    await _collections.collection<T>().doc((data as BaseModel).id).delete();
  }

  Future<User?> getUserById(String id) async {
    final cached = _cache.get<User>(id);
    if (cached != null) {
      return cached;
    }
    final snapshot = await _collections.users.doc(id).get();
    final user = !snapshot.exists ? null : snapshot.data();
    _cache.set(id, user);
    return user;
  }

  Future<User?> getUserByPhoneNumber(String phone) async {
    final cached = _cache.get<User>(phone);
    if (cached != null) {
      return cached;
    }
    final snapshot = await _collections.users
        .where('phone', isEqualTo: phone.phoneUniversal)
        .get();
    final user = snapshot.size == 0 ? null : snapshot.docs.first.data();
    _cache.set(phone, user);
    return user;
  }

  Future<List<User>> getUsers(String query) async {
    final snapshot = await _collections.users
        .where('searchTerms', arrayContains: query)
        .limit(10)
        .get();
    return snapshot.docs.map((e) => e.data()).toList();
  }
}

import 'dart:async';
import 'package:chatify/chatify.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';

class PaginatedFirestoreStream {
  PaginatedFirestoreStream({required this.query, required this.limit});

  final int limit;
  final Query<Map<String, dynamic>> query;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _streamSubscription;

  late final stream = BehaviorSubject.seeded(
    const PaginatedResult<
      QueryDocumentSnapshot<Map<String, dynamic>>
    >.loading(),
    onListen: () => fetch(),
    onCancel: () => dispose(),
  );

  DateTime? _lastFetchTime;
  int _currentLimit = 0;

  void fetch() {
    if (stream.value.hasReachedEnd) return;
    if (_lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!) <
            const Duration(seconds: 1)) {
      return;
    }
    _lastFetchTime = DateTime.now();

    _streamSubscription?.cancel();
    _currentLimit += limit;

    final localQuery = query.limit(_currentLimit);

    _streamSubscription = localQuery.snapshots().listen((querySnapshot) {
      final newList = querySnapshot.docs;

      final hasReachedEnd = newList.length < _currentLimit;

      stream.add(PaginatedResult.success(newList, hasReachedEnd));
    });
  }

  void dispose() {
    _streamSubscription?.cancel();
    _streamSubscription = null;
  }
}

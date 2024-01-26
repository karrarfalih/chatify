import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:rxdart/rxdart.dart';

enum ConnectivityStatus { waiting, connecting, connected }

class ChatifyConnectivity {
  ChatifyConnectivity() {
    init();
  }

  late final BehaviorSubject<ConnectivityStatus> connection;
  StreamSubscription? subscription;

  void init() {
    final connectivity = Connectivity();
    connection = BehaviorSubject<ConnectivityStatus>();
    subscription = Rx.combineLatest2<ConnectivityResult, DatabaseEvent?,
            ConnectivityStatus>(
        connectivity.onConnectivityChanged.startWith(ConnectivityResult.none),
        FirebaseDatabase.instance
            .ref('.info/connected')
            .onValue
            .cast<DatabaseEvent?>()
            .startWith(null), (connectivity, database) {
      if (database?.snapshot.value != true) {
        if (connectivity == ConnectivityResult.none) {
          return ConnectivityStatus.waiting;
        }
        return ConnectivityStatus.connecting;
      }
      return ConnectivityStatus.connected;
    }).distinct().listen((event) {
      connection.add(event);
    });
  }

  void dispose() {
    connection.close();
    subscription?.cancel();
  }
}

import 'package:chat/models/controller.dart';
import 'package:chat/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kr_extensions/kr_extensions.dart';
import 'package:uuid/uuid.dart';

class UserConnection {
  final String id;
  String targetUser;
  String targetUserUid;
  String user;
  final DateTime createdAt;
  int score;
  bool isConnected;

  UserConnection(
      {String? id,
      String? user,
      required this.targetUser,
      required this.targetUserUid,
      DateTime? createdAt,
      int? score,
      this.isConnected = true})
      : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        user = user ?? ChatUser.current?.id ?? '',
        score = score ?? 0;

  Map<String, dynamic> get toJson => {
        'id': id,
        'targetUser': targetUser,
        'targetUserTerms': targetUserUid.generateSearchTerms,
        'user': user,
        'createdAt': Timestamp.fromDate(createdAt),
        'score': score,
        'isConnected': isConnected,
        'targetUserUid': targetUserUid
      };

  static UserConnection fromJson(Map<String, dynamic> e) => UserConnection(
      score: e['score'],
      targetUser: e['targetUser'],
      createdAt: e['createdAt'].toDate(),
      user: e['user'],
      id: e['id'],
      isConnected: e['isConnected'],
      targetUserUid: e['targetUserUid'] ?? '');

  static final CollectionReference<UserConnection> ref = FirebaseFirestore
      .instance
      .collection('connections')
      .withConverter<UserConnection>(
          fromFirestore: (x, _) => UserConnection.fromJson(x.data()!),
          toFirestore: (x, _) => x.toJson);

  static Query<UserConnection> get connections => ref
      .where('user', isEqualTo: ChatUser.current?.id ?? const Uuid().v4())
      .orderBy('score', descending: true);

  static Query<UserConnection> connectionsStatus(String target) => ref
      .where('user', isEqualTo: ChatUser.current?.id ?? const Uuid().v4())
      .where('targetUser', isEqualTo: target);

  static Query<UserConnection> connectionsSearch(String searchTerm) =>
      connections.where('targetUserTerms', arrayContains: searchTerm).limit(5);

  static Query<ChatUser> accountSearch(String searchTerm) =>
      options.userReference
          .where(options.userData.searchTerms!,
              arrayContains: searchTerm.toLowerCase())
          .limit(10);

  Future<void> save() async {
    await ref.doc(id).set(this, SetOptions(merge: true));
  }

  static Future<UserConnection> getConnection(ChatUser user) async {
    var res = await connectionsStatus(user.id).get();
    if (res.size > 0) {
      var connection = res.docs.first.data();
      return connection;
    } else {
      return UserConnection(
          targetUser: user.id,
          targetUserUid: user.uid ?? '',
          isConnected: false);
    }
  }
}

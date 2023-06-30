import 'package:chatify/models/controller.dart';

class UserData {
  final String id;
  final String? uid;
  final String name;
  final String? clientNotificationId;
  final String? profileImage;
  String? searchTerms;
  UserData(
      {required this.id,
      this.uid,
      required this.name,
      this.clientNotificationId,
      this.searchTerms,
      this.profileImage});
}

class ChatUser {
  String id;
  String? uid;
  String name;
  String? clientNotificationId;
  String? profileImage;
  Map<String, dynamic> data;
  ChatUser(
      {required this.id,
      this.uid,
      required this.data,
      required this.name,
      this.clientNotificationId,
      this.profileImage});

  static ChatUser? _current;
  static ChatUser? get current{
    if(options.currentUser != null){
      return _current ?? options.currentUser!();
    }
    return _current;
  }
  
  static set current(ChatUser? user){
    _current = user;
  }

  static final Map<String, ChatUser?> _cahce = {};

  static Future<ChatUser?> getById(String id) async {
    if (_cahce[id] != null) return _cahce[id];
    var res = await options.userReference
        .where(options.userData.id, isEqualTo: id)
        .get();
    return _cahce.putIfAbsent(
        id, () => res.docs.isEmpty ? null : res.docs.first.data());
  }
}

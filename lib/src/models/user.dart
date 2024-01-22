import 'package:chatify/chatify.dart';

class ChatifyUser {
  final String id;
  final String? uid;
  final String name;
  final List<String>? clientNotificationIds;
  final String? profileImage;
  final Map<String, dynamic>? data;

  ChatifyUser({
    required this.id,
    this.uid,
    required this.name,
    this.clientNotificationIds,
    this.profileImage,
    this.data,
  });

  ChatifyUser.support()
      : id = 'support',
        uid = null,
        name = 'Support',
        clientNotificationIds = null,
        profileImage = 'https://i.imgur.com/BoN9kdC.png',
        data = null;
}

enum ChatStatus {
  none,
  attend,
  typing,
  recording,
  sendingMedia,
}

class UserLastSeen {
  final bool isActive;
  final DateTime? _lastSeen;
  final DateTime? _lastConnection;

  UserLastSeen({
    required this.isActive,
    DateTime? lastSeen,
    DateTime? lastConnection,
  })  : _lastConnection = lastConnection,
        _lastSeen = lastSeen;

  DateTime? get lastSeen => _lastSeen ?? _lastConnection;
}

extension Users on Iterable<ChatifyUser> {
  List<ChatifyUser> get withoutMe =>
      where((e) => e.id != Chatify.currentUserId && e.id != 'support').toList();

  List<ChatifyUser> get withoutMeOrMe {
    final users = withoutMe;
    if (users.isEmpty) return [first];
    return users;
  }

  String get usersName {
    if(isEmpty) return '';
    if (length == 1) return first.name;
    return withoutMe.map((e) => e.name.split(' ').first).join(', ');
  }
}

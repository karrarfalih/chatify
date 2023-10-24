class ChatifyUser {
  final String id;
  final String? uid;
  final String name;
  final String? clientNotificationId;
  final String? profileImage;
  final Map<String, dynamic>? data;

  ChatifyUser({
    required this.id,
    this.uid,
    required this.name,
    this.clientNotificationId,
    this.profileImage,
    this.data,
  });
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

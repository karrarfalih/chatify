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

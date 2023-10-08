import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

@immutable
class Chat {
  final String id;
  final List<String> members;
  final String? imageUrl;
  final String? title;
  final DateTime? updatedAt;

  const Chat({
    required this.id,
    required this.members,
    this.imageUrl,
    this.title,
    this.updatedAt,
  });

  static Chat fromJson(Map data, String id) {
    return Chat(
      id: id,
      members: List.from(data['members'] ?? []),
      imageUrl: data['imageUrl'],
      title: data['title'],
      updatedAt: data['updatedAt']?.toDate(),
    );
  }

  Map<String, dynamic> get toJson => {
        'id': id,
        'members': members.toSet().toList(),
        'imageUrl': imageUrl,
        'title': title,
        'updatedAt': updatedAt == null
            ? FieldValue.serverTimestamp()
            : Timestamp.fromDate(updatedAt!),
      };

  Chat copyWith({
    String? id,
    List<String>? members,
    String? imageUrl,
    String? title,
    DateTime? updatedAt,
  }) {
    return Chat(
      id: id ?? this.id,
      members: members ?? this.members,
      imageUrl: imageUrl ?? this.imageUrl,
      title: title ?? this.title,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

import 'package:chatify/src/utils/extensions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

@immutable
class Chat {
  final String id;
  final List<String> members;
  final int membersCount;
  final String? imageUrl;
  final String? title;
  final DateTime? updatedAt;
  final Map<String, DateTime?> readAfter; 

  const Chat({
    required this.id,
    required this.members,
    this.imageUrl,
    this.title,
    this.updatedAt,
    this.readAfter = const {},
  }) : membersCount = members.length;

  static Chat fromJson(Map data, String id) {
    return Chat(
      id: id,
      members: List.from(data['members'] ?? []),
      imageUrl: data['imageUrl'],
      title: data['title'],
      updatedAt: data['updatedAt']?.toDate(),
      readAfter: Map.from(data['readAfter'] ?? {}).map((key, value) => MapEntry(key, value?.toDate())),
    );
  }

  Map<String, dynamic> get toJson => {
        'id': id,
        'members': members.toSet().toList(),
        'membersCount': members.length,
        'imageUrl': imageUrl,
        'title': title,
        'updatedAt': FieldValue.serverTimestamp(),
        'readAfter': readAfter.map((key, value) => MapEntry(key, value?.stamp)),
      };

  Chat copyWith({
    String? id,
    List<String>? members,
    String? imageUrl,
    String? title,
    DateTime? updatedAt,
    Map<String, DateTime?>? readAfter,
  }) {
    return Chat(
      id: id ?? this.id,
      members: members ?? this.members,
      imageUrl: imageUrl ?? this.imageUrl,
      title: title ?? this.title,
      updatedAt: updatedAt ?? this.updatedAt,
      readAfter: readAfter ?? this.readAfter,
    );
  }
}

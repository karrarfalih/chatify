import '../chat.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';

part 'unsupported.dart';
part 'deleted.dart';
part 'error.dart';
part 'reply.dart';

abstract class MessageContent extends Equatable {
  final String id;
  final String content;
  final String? url;

  MessageContent({required this.content, this.url, String? id})
      : id = id ?? const Uuid().v4();

  MessageContent.fromJson(Map<String, dynamic> json, this.id)
      : content = json['content'],
        url = json['attachmentUrl'];

  @mustCallSuper
  @mustBeOverridden
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'attachmentUrl': url,
    };
  }

  @override
  List<Object?> get props => [id, content, url];
}

import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';

part 'unsupported.dart';
part 'deleted.dart';
part 'error.dart';

abstract class MessageContent extends Equatable {
  final String id;
  final String content;
  final String? url;
  final String type;

  MessageContent({required this.content, this.url, String? id, required this.type})
      : id = id ?? const Uuid().v4();

  MessageContent.fromJson(Map<String, dynamic> json, this.id)
      : content = json['content'],
        url = json['attachmentUrl'],
        type = json['type'];

  @mustCallSuper
  @mustBeOverridden
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'attachmentUrl': url,
      'type': type,
    };
  }

  @override
  List<Object?> get props => [id, content, url];
}

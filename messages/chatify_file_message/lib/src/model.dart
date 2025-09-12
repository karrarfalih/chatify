import 'package:chatify/chatify.dart';

final class FileMessage extends MessageContent {
  final String name;
  final String extension;
  final int size;

  FileMessage({
    required String url,
    required this.name,
    required this.extension,
    required this.size,
  }) : super(content: 'File message', url: url, type: 'FileMessage');

  FileMessage.fromJson(super.json, super.id)
    : name = json['name'] ?? 'unknown',
      extension = json['extension'] ?? '',
      size = json['size'] ?? 0,
      super.fromJson();

  @override
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'extension': extension,
      'size': size,
      ...super.toJson(),
    };
  }

  @override
  List<Object?> get props => [url, name, extension, size, ...super.props];
}

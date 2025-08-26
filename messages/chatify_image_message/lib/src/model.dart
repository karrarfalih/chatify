import 'dart:typed_data';
import 'package:chatify/chatify.dart';

final class ImageMessage extends MessageContent {
  final Uint8List thumbnail;
  final int width;
  final int height;

  ImageMessage({
    required String url,
    required this.thumbnail,
    required this.width,
    required this.height,
  }) : super(content: 'Image message', url: url);

  ImageMessage.fromJson(super.json, super.id)
      : thumbnail =
            json['thumbnailBytes'] == null || json['thumbnailBytes'].isEmpty
                ? Uint8List(0)
                : Uint8List.fromList(List.from(json['thumbnailBytes'] ?? [])),
        width = json['width'],
        height = json['height'],
        super.fromJson();

  @override
  Map<String, dynamic> toJson() {
    return {
      'thumbnailBytes': thumbnail,
      'width': width,
      'height': height,
      ...super.toJson(),
    };
  }

  @override
  List<Object?> get props => [
        url,
        thumbnail.length,
        width,
        height,
        ...super.props,
      ];
}

import 'package:chatify/src/enums.dart';
import 'package:chatify/src/models/models.dart';
import 'package:chatify/src/utils/storage_utils.dart';
import 'package:flutter/services.dart';

class ImageMessage extends Message {
  final String imageUrl;
  final List<int> thumbnailBytes;
  final double width;
  final double height;
  final UploadAttachment? attachment;
  final Uint8List? bytes;

  ImageMessage({
    required this.imageUrl,
    required this.thumbnailBytes,
    required this.width,
    required this.height,
    super.id,
    required super.chatId,
    super.sender,
    super.isEdited,
    super.sendAt,
    super.seenBy,
    required super.unSeenBy,
    required super.canReadBy,
    super.deliveredTo,
    super.emojis,
    super.replyId,
    super.replyUid,
    super.isPending,
    this.attachment,
    required this.bytes,
  }) : super(type: MessageType.image);

  @override
  Map<String, dynamic> get toJson {
    return {
      'imageUrl': imageUrl,
      'thumbnailBytes': thumbnailBytes,
      'width': width,
      'height': height,
      ...super.toJson,
    };
  }

  ImageMessage.fromJson(Map data)
      : imageUrl = data['imageUrl'],
        thumbnailBytes = List.from(data['thumbnailBytes']),
        width = data['width'],
        height = data['height'],
        attachment = null,
        bytes = null,
        super.fromJson(data);

  ImageMessage copyWith({
    required String imageUrl,
    required List<int> thumbnailBytes,
  }) =>
      ImageMessage(
        imageUrl: imageUrl,
        thumbnailBytes: thumbnailBytes,
        width: width,
        height: height,
        chatId: chatId,
        unSeenBy: unSeenBy,
        id: id,
        sender: sender,
        isEdited: isEdited,
        sendAt: sendAt,
        seenBy: seenBy,
        canReadBy: canReadBy,
        deliveredTo: deliveredTo,
        emojis: emojis,
        replyId: replyId,
        replyUid: replyUid,
        attachment: attachment,
        bytes: bytes,
      );
}

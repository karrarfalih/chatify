import 'package:chatify/chatify.dart';
import 'package:flutter/widgets.dart';
import 'package:iconsax/iconsax.dart';
import 'package:uuid/uuid.dart';

import 'model.dart';
import 'widget.dart';
import 'get_image.dart';

class ImageMessageProvider extends MediaMessageProvider<ImageMessage> {
  @override
  String get type => 'ImageMessage';

  @override
  ImageMessage fromJson(Map<String, dynamic> data, String id) {
    return ImageMessage.fromJson(data, id);
  }

  @override
  Widget build(BuildContext context, MessageState message) {
    final img = message.message.content as ImageMessage;
    return ImageMessageWidget(
      key: Key(message.message.content.url ?? ''),
      message: message.message,
      isFailed: message.isFailed,
      isSending: message.isPending,
      taskStream: getTaskStream(img),
    );
  }

  @override
  List<ComposerAction<MediaComposerResult>> get composerActions => [
    ComposerAction(
      title: 'Image',
      icon: Iconsax.image,
      onPick: (context) async {
        final picker = await pickImages();
        return picker
            .map(
              (e) => MediaComposerResult(
                message: ImageMessage(
                  url: '',
                  thumbnail: e.thumbnail,
                  width: e.width,
                  height: e.height,
                ),
                bytes: e.image,
                storageFolder: 'images',
                fileName: const Uuid().v4(),
              ),
            )
            .toList();
      },
    ),
  ];
}

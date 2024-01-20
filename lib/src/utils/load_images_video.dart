import 'package:chatify/src/ui/chat_view/body/images/image_mode.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:chatify/src/utils/log.dart';
import 'package:flutter/services.dart';

Future<List<ImageAttachment>> getImages(List<ImageModel> images) async {
  if (images.isEmpty) {
    ChatifyLog.d('No images selected');
    return [];
  }
  final attachments = <ImageAttachment>[];
  for (final image in images) {
    Uint8List? bytes;
    if (image.medium != null) {
      bytes = await image.medium!.getFile().then((value) => value.readAsBytes());
    } else if (image.file != null) {
      bytes = await image.file!.readAsBytes();
    }
    var imageBytes = await FlutterImageCompress.compressWithList(
      bytes!,
      minWidth: 1200,
      minHeight: 1200,
      quality: 95,
    );
    Uint8List? thumbnailBytes;
    if (image.medium != null) {
      final thumbnailList = await image.medium!.getThumbnail(width: 30, height: 30);
      thumbnailBytes = Uint8List.fromList(thumbnailList);
    } else if (image.file != null) {
      thumbnailBytes = await FlutterImageCompress.compressWithList(
        bytes,
        minWidth: 30,
        minHeight: 30,
        quality: 30,
      );
    }

    attachments.add(
      ImageAttachment(
        image: imageBytes,
        thumbnail: thumbnailBytes!,
        width: image.width.toDouble(),
        height: image.height.toDouble(),
      ),
    );
  }
  ChatifyLog.d('Selected ${attachments.length} images');
  return attachments;
}

class ImageAttachment {
  final Uint8List image;
  final Uint8List thumbnail;
  final double width;
  final double height;

  ImageAttachment({
    required this.image,
    required this.thumbnail,
    required this.width,
    required this.height,
  });
}

Future<Uint8List?> getVideo() async {
  final picker = ImagePicker();
  final video = await picker.pickVideo(source: ImageSource.gallery);
  if (video == null) {
    ChatifyLog.d('No video selected');
    return null;
  }
  final data = await video.readAsBytes();
  ChatifyLog.d('Selected video');
  return data;
}

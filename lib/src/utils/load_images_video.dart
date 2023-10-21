import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:chatify/src/utils/log.dart';
import 'package:flutter/services.dart';
import 'package:photo_gallery/photo_gallery.dart';

Future<List<ImageAttachment>> getImages(List<Medium> images) async {
  if (images.isEmpty) {
    ChatifyLog.d('No images selected');
    return [];
  }
  final attachments = <ImageAttachment>[];
  for (final image in images) {
    final imageFile = await image.getFile();
    var imageBytes = await FlutterImageCompress.compressWithList(
      imageFile.readAsBytesSync(),
      minWidth: 1200,
      minHeight: 1200,
      quality: 95,
    );
    final thumbnailList = await image.getThumbnail(width: 30, height: 30);
    final thumbnailBytes = Uint8List.fromList(thumbnailList);
    attachments.add(
      ImageAttachment(
        image: imageBytes,
        thumbnail: thumbnailBytes,
        width: (image.width ?? 1200).toDouble(),
        height: (image.height ?? 1200).toDouble(),
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

import 'package:image_picker/image_picker.dart';
import 'package:chatify/src/utils/log.dart';
import 'package:flutter/services.dart';

Future<List<Uint8List>> getImages() async {
  final picker = ImagePicker();
  final images = await picker.pickMultiImage(maxHeight: 1440, maxWidth: 1440);
  if (images.isEmpty) {
    ChatifyLog.d('No images selected');
    return [];
  }
  final bytes = <Uint8List>[];
  for (final image in images) {
    final data = await image.readAsBytes();
    bytes.add(data);
  }
  ChatifyLog.d('Selected ${bytes.length} images');
  return bytes;
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
import 'dart:async';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart' as image_picker;
import 'dart:ui' as ui;

class ChatifyImage {
  final Uint8List image;
  final Uint8List thumbnail;
  final int width;
  final int height;

  ChatifyImage({
    required this.image,
    required this.thumbnail,
    required this.width,
    required this.height,
  });
}

Future<ui.Image> _getImageFromBytes(Uint8List bytes) async {
  final Completer<ui.Image> completer = Completer();
  ui.decodeImageFromList(bytes, (ui.Image img) {
    completer.complete(img);
  });
  return completer.future;
}

Future<List<ChatifyImage>> pickImages() async {
  List<XFile> images = [];
  List<ChatifyImage> results = [];
  final result = await image_picker.ImagePicker().pickMultiImage();
  if (result.isEmpty) return [];
  images.addAll(result);

  for (final image in images) {
    final bytes = await image.readAsBytes();
    final imageBytes = await FlutterImageCompress.compressWithList(
      bytes,
      minWidth: 1200,
      minHeight: 1200,
      quality: 95,
    );
    final thumbnailBytes = await FlutterImageCompress.compressWithList(
      bytes,
      minWidth: 30,
      minHeight: 30,
      quality: 30,
    );
    final ui.Image decodedImage = await _getImageFromBytes(imageBytes);
    final width = decodedImage.width;
    final height = decodedImage.height;

    results.add(
      ChatifyImage(
        image: imageBytes,
        thumbnail: thumbnailBytes,
        width: width,
        height: height,
      ),
    );
  }
  return results;
}

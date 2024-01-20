import 'package:image_picker/image_picker.dart';
import 'package:photo_gallery/photo_gallery.dart';

class ImageModel {
  final Medium? medium;
  final XFile? file;
  final int width;
  final int height;

  ImageModel({
    this.medium,
    this.file,
    required this.width,
    required this.height,
  });
}

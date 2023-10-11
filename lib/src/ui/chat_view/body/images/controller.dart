import 'package:chatify/src/utils/value_notifiers.dart';
import 'package:photo_gallery/photo_gallery.dart';

class GalleryController {
  GalleryController() {
    init();
  }

  final images = <Medium>[].obs;
  final selected = <Medium>[].obs;

  init() async {
    final List<Album> imageAlbums = await PhotoGallery.listAlbums();
    for (final e in imageAlbums) {
      final MediaPage imagePage = await e.listMedia();
      images.value = [...images.value, ...imagePage.items];
    }
  }
}

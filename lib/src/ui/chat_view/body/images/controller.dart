import 'dart:convert';

import 'package:chatify/src/utils/cache.dart';
import 'package:chatify/src/utils/log.dart';
import 'package:chatify/src/utils/value_notifiers.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_gallery/photo_gallery.dart';
import 'package:camera/camera.dart';

import 'image_mode.dart';

class GalleryController {
  GalleryController();

  final images = <ImageModel>[].obs;
  final selected = <ImageModel>[].obs;
  final canUseCameraThumnail = false.obs;
  final _cameras = <CameraDescription>[];
  Album? _allAlbums;

  static List<Medium> _initialImages = [];

  CameraController? camera;

  addImage(ImageModel image) {
    selected.value.add(image);
    selected.refresh();
  }

  removeImage(ImageModel image) {
    selected.value.remove(image);
    selected.refresh();
  }

  Future<bool> init() async {
    var photoesStatus = await Permission.photos.status;
    if (photoesStatus.isDenied) {
      photoesStatus = await Permission.photos.request();
    }
    if (photoesStatus.isDenied) return false;
    final List<Album> imageAlbums = await PhotoGallery.listAlbums();
    if (_initialImages.isEmpty) {
      final cachedImages = Cache.instance.getString('initialGalleryImages');
      if (cachedImages != null) {
        final decodedImages = Map.from(jsonDecode(cachedImages));
        for (final cachedImage in (List.from(decodedImages['images']))) {
          _initialImages.add(Medium.fromJson(cachedImage));
        }
      }
    }
    images.value.addAll(
      _initialImages.map(
        (e) => ImageModel(
          width: e.width ?? 1200,
          height: e.height ?? 1200,
          medium: e,
        ),
      ),
    );
    if (imageAlbums.any((e) => e.name == 'All')) {
      _allAlbums = imageAlbums.firstWhere((e) => e.name == 'All');
      final MediaPage imagePage =
          await _allAlbums!.listMedia(take: 30, lightWeight: true);
      final pageImages = imagePage.items.map(
        (e) => ImageModel(
          width: e.width ?? 1200,
          height: e.height ?? 1200,
          medium: e,
        ),
      );
      images.value.insertAll(
        0,
        pageImages.where(
            (e) => !images.value.any((old) => e.medium!.id == old.medium!.id)),
      );
      _initialImages = imagePage.items.take(30).toList();
      final imagesJson = _initialImages.map((e) => _imageToJson(e));
      Cache.instance.setString(
        'initialGalleryImages',
        jsonEncode({'images': imagesJson.toList()}),
      );
    } else {
      for (final e in imageAlbums) {
        final MediaPage imagePage = await e.listMedia();
        final pageImages = imagePage.items.map(
          (e) => ImageModel(
            width: e.width ?? 1200,
            height: e.height ?? 1200,
            medium: e,
          ),
        );
        images.value.addAll(pageImages);
      }
    }
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      images.refresh();
    });
    getThumbnailCamera();
    return true;
  }

  bool _isBusy = false;
  bool _finished = false;

  loadMoreImages() async {
    if (_isBusy || _finished) return;
    _isBusy = true;
    final MediaPage imagePage = await _allAlbums!
        .listMedia(skip: images.value.length, take: 100, lightWeight: true);
    if (imagePage.items.isEmpty) {
      _finished = true;
    }
    final pageImages = imagePage.items.map(
      (e) => ImageModel(
        width: e.width ?? 1200,
        height: e.height ?? 1200,
        medium: e,
      ),
    );
    images.value.addAll(pageImages);
    images.refresh();
    _isBusy = false;
  }

  Map<String, dynamic> _imageToJson(Medium media) {
    return {
      'id': media.id,
      'filename': media.filename,
      'title': media.title,
      'mediumType': mediumTypeToJson(media.mediumType),
      'width': media.width,
      'height': media.height,
      'size': media.size,
      'orientation': media.orientation,
      'mimeType': media.mimeType,
      'duration': media.duration,
      'creationDate': media.creationDate?.millisecondsSinceEpoch,
      'modifiedDate': media.modifiedDate?.millisecondsSinceEpoch,
    };
  }

  Future<void> getThumbnailCamera() async {
    if (_cameras.isEmpty) {
      await _getCameras();
      if (_cameras.isEmpty) {
        ChatifyLog.d('Can not access the camera');
        return;
      }
    }
    await disposeCamera();
    camera = CameraController(_cameras.first, ResolutionPreset.high);
    await camera!.initialize();
    canUseCameraThumnail.value = true;
  }

  Future<CameraController?> getFullCamera() async {
    if (canUseCameraThumnail.value) {
      canUseCameraThumnail.value = false;
      await disposeCamera();
      camera = CameraController(_cameras.first, ResolutionPreset.high);
      await camera!.initialize();
    }
    return camera;
  }

  Future<void> _getCameras() async {
    var camerStatus = await Permission.camera.status;
    if (camerStatus.isDenied || camerStatus.isPermanentlyDenied) {
      camerStatus = await Permission.camera.request();
    }
    if (!camerStatus.isDenied && !camerStatus.isPermanentlyDenied) {
      _cameras.addAll(await availableCameras());
    }
  }

  switchCamera() async {
    await disposeCamera();
    final currentIndex =
        _cameras.indexWhere((e) => e.name == camera?.description.name);
    final newIndex = currentIndex == 1 ? 0 : 1;
    camera =
        CameraController(_cameras.elementAt(newIndex), ResolutionPreset.high);
    await camera!.initialize();
    return camera;
  }

  Future disposeCamera() async {
    await camera?.dispose();
  }

  dispos() {
    canUseCameraThumnail.value = false;
    disposeCamera();
    images.dispose();
    selected.dispose();
    canUseCameraThumnail.dispose();
  }
}

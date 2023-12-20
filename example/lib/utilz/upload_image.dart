import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:image_cropper/image_cropper.dart';

Future<String?> getPhoto() async {
  final ImagePicker picker = ImagePicker();
  final XFile? image = await picker.pickImage(source: ImageSource.gallery);
  if (image != null) {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: image.path,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
      ],
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      cropStyle: CropStyle.circle,
      maxWidth: 600,
      maxHeight: 600,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Profile Photo',
          toolbarColor: Colors.black,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: true,
          showCropGrid: false,
          backgroundColor: Colors.black,
          hideBottomControls: true,
          activeControlsWidgetColor: Colors.black,
          statusBarColor: Colors.black,
          cropFrameColor: Colors.transparent,
        ),
        IOSUiSettings(
          title: 'Profile Photo',
          rectX: 1,
          rectY: 1,
          aspectRatioLockEnabled: true,
          doneButtonTitle: 'Done',
          cancelButtonTitle: 'Cancel',
        ),
      ],
    );
    final bytes = await croppedFile?.readAsBytes();
    if (bytes == null) return null;
    return uploadPhoto(bytes);
  }
  return null;
}

Future<String> uploadPhoto(Uint8List e) async {
  var res = await FirebaseStorage.instance
      .ref('userProfiles/${const Uuid().v4()}.jpg')
      .putData(e);
  return await res.ref.getDownloadURL();
}

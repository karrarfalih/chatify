import 'package:camera/camera.dart';
import 'package:chatify/src/ui/chat_view/body/images/camera_screen.dart';
import 'package:chatify/src/ui/chat_view/body/images/controller.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class CameraThumnail extends StatelessWidget {
  const CameraThumnail({super.key, required this.controller});
  final GalleryController controller;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => CameraScreen(
              controller: controller,
            ),
          ),
        );
        controller.getThumbnailCamera();
      },
      child: ValueListenableBuilder<bool>(
        valueListenable: controller.canUseCameraThumnail,
        builder: (context, canUseCamera, child) {
          final camera = controller.camera;
          if (!canUseCamera || camera == null) {
            return Container(
              color: Colors.black,
              width: double.maxFinite,
              height: double.maxFinite,
            );
          }
          return Stack(
            alignment: Alignment.center,
            children: [
              Transform.scale(
                scale: camera.value.aspectRatio,
                child: ClipRRect(
                  child: Center(
                    child: CameraPreview(camera),
                  ),
                ),
              ),
              Icon(
                Iconsax.camera5,
                size: 36,
                color: Theme.of(context).scaffoldBackgroundColor,
              )
            ],
          );
        },
      ),
    );
  }
}

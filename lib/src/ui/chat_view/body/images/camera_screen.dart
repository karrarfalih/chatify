import 'dart:io';

import 'package:camera/camera.dart';
import 'package:chatify/src/ui/chat_view/body/images/controller.dart';
import 'package:chatify/src/ui/chat_view/body/images/image_mode.dart';
import 'package:chatify/src/ui/chat_view/body/images/image_preview.dart';
import 'package:chatify/src/ui/chat_view/controllers/chat_controller.dart';
import 'package:chatify/src/ui/common/media_query.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({
    super.key,
    required this.controller,
    required this.chatController,
  });

  final GalleryController controller;
  final ChatController chatController;

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  FlashMode flash = FlashMode.off;
  bool canUseCamera = false;
  ImageModel? image = null;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      final res = await widget.controller.getFullCamera();
      setState(() {
        canUseCamera = res != null;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = mediaQuery(context).size;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        systemNavigationBarDividerColor: Colors.black,
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: image != null
          ? GalleryImagePreview(
              image: image!,
              isSelecetd: true,
              controller: widget.controller,
              chatController: widget.chatController,
              width: mediaQuery(context).size.width,
              height: mediaQuery(context).size.height,
            )
          : Scaffold(
              body: Stack(
                children: [
                  if (canUseCamera && image == null)
                    Transform.scale(
                      scale: size.height /
                          (widget.controller.camera!.value.aspectRatio *
                              size.width),
                      child: ClipRRect(
                        child: Center(
                          child: CameraPreview(widget.controller.camera!),
                        ),
                      ),
                    )
                  else if (image == null)
                    Container(
                      color: Colors.black,
                      width: double.maxFinite,
                      height: double.maxFinite,
                    )
                  else
                    Image.file(
                      File(image!.file!.path),
                      fit: BoxFit.cover,
                      width: double.maxFinite,
                      height: double.maxFinite,
                    ),
                  AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    iconTheme: IconThemeData(color: Colors.white),
                  ),
                  if (image == null)
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 300),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 30),
                          child: SafeArea(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                StatefulBuilder(
                                  builder: (context, setState) {
                                    return IconButton(
                                      onPressed: () {
                                        switch (flash) {
                                          case FlashMode.off:
                                            flash = FlashMode.always;
                                            break;
                                          case FlashMode.always:
                                            flash = FlashMode.auto;
                                            break;
                                          default:
                                            flash = FlashMode.off;
                                        }
                                        setState(() {});
                                        widget.controller.camera
                                            ?.setFlashMode(flash);
                                      },
                                      icon: AnimatedSwitcher(
                                        duration: Duration(milliseconds: 200),
                                        transitionBuilder: (
                                          Widget child,
                                          Animation<double> animation,
                                        ) {
                                          return SlideTransition(
                                            position: Tween<Offset>(
                                              begin: Offset(0.0, 1.0),
                                              end: Offset(0.0, 0.0),
                                            ).animate(animation),
                                            child: child,
                                          );
                                        },
                                        child: flash == FlashMode.off
                                            ? Icon(
                                                Iconsax.flash_1,
                                                key: ValueKey('flash_1'),
                                                size: 36,
                                                color: Colors.white,
                                              )
                                            : flash == FlashMode.always
                                                ? Icon(
                                                    Iconsax.flash,
                                                    key: ValueKey('flash'),
                                                    size: 36,
                                                    color: Colors.white,
                                                  )
                                                : Icon(
                                                    Iconsax.flash_slash,
                                                    size: 36,
                                                    key:
                                                        ValueKey('flash_slash'),
                                                    color: Colors.white,
                                                  ),
                                      ),
                                    );
                                  },
                                ),
                                TextButton(
                                  onPressed: () async {
                                    final cameraImage = await widget
                                        .controller.camera
                                        ?.takePicture();
                                    final size = widget
                                        .controller.camera?.value.previewSize;
                                    image = ImageModel(
                                      width: size?.width.toInt() ?? 12000,
                                      height: size?.height.toInt() ?? 12000,
                                      file: cameraImage,
                                    );

                                    if (image != null) {
                                      widget.controller.addImage(image!);
                                    }
                                    setState(() {});
                                  },
                                  style: TextButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(60),
                                      side: BorderSide(
                                        color: Colors.white,
                                        width: 3,
                                      ),
                                    ),
                                    fixedSize: Size.square(60),
                                    minimumSize: Size.square(60),
                                  ),
                                  child: SizedBox.shrink(),
                                ),
                                IconButton(
                                  onPressed: () async {
                                    await widget.controller.switchCamera();
                                    setState(() {});
                                  },
                                  icon: Icon(
                                    Iconsax.repeat,
                                    size: 36,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  Positioned.fill(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTapUp: (details) {
                        widget.controller.camera!
                            .setFocusMode(FocusMode.locked);
                        widget.controller.camera!.setFocusPoint(
                          Offset(
                            details.globalPosition.dx / size.width,
                            details.globalPosition.dy / size.height,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

import 'package:camera/camera.dart';
import 'package:chatify/src/ui/chat_view/body/images/controller.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({
    super.key,
    required this.controller,
  });

  final GalleryController controller;

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  FlashMode flash = FlashMode.off;
  bool canUseCamera = false;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await widget.controller.getFullCamera();
      setState(() {
        canUseCamera = true;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          if (canUseCamera)
            Transform.scale(
              scale: size.height /
                  (widget.controller.camera!.value.aspectRatio * size.width),
              child: ClipRRect(
                child: Center(
                  child: CameraPreview(widget.controller.camera!),
                ),
              ),
            ) else Container(
              color: Colors.black,
              width: double.maxFinite,
              height: double.maxFinite,
            ),
          AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: IconThemeData(color: Colors.white),
          ),
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
                              widget.controller.camera?.setFlashMode(flash);
                            },
                            icon: AnimatedSwitcher(
                              duration: Duration(milliseconds: 200),
                              transitionBuilder:
                                  (Widget child, Animation<double> animation) {
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
                                          key: ValueKey('flash_slash'),
                                          color: Colors.white,
                                        ),
                            ),
                          );
                        },
                      ),
                      TextButton(
                        onPressed: () {},
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
          )
        ],
      ),
    );
  }
}

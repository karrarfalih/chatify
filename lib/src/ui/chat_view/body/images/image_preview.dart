import 'package:chatify/src/core/chatify.dart';
import 'package:chatify/src/ui/chat_view/body/images/controller.dart';
import 'package:chatify/src/ui/chat_view/body/images/image_mode.dart';
import 'package:chatify/src/ui/chat_view/body/images/input_field.dart';
import 'package:chatify/src/ui/chat_view/controllers/chat_controller.dart';
import 'package:chatify/src/ui/common/hero_dialog.dart';
import 'package:chatify/src/ui/common/image.dart';
import 'package:chatify/src/ui/common/kr_builder.dart';
import 'package:chatify/src/utils/extensions.dart';
import 'package:chatify/src/utils/value_notifiers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_gallery/photo_gallery.dart';
import 'package:zoom_widget/zoom_widget.dart';

class GalleryImagePreview extends StatefulWidget {
  const GalleryImagePreview({
    super.key,
    required this.image,
    required this.isSelecetd,
    required this.controller,
    required this.chatController,
    this.width = double.infinity,
    this.height = double.infinity,
    this.fromCameraSource = false,
  });

  static show({
    required ImageModel image,
    required bool isSelecetd,
    required GalleryController controller,
    required ChatController chatController,
    required BuildContext context,
    bool fromCameraSource = false,
  }) async {
    showDialogWithHero(
      child: GalleryImagePreview(
        image: image,
        isSelecetd: isSelecetd,
        controller: controller,
        chatController: chatController,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        fromCameraSource: fromCameraSource,
      ),
      context: context,
    );
  }

  final ImageModel image;
  final bool isSelecetd;
  final GalleryController controller;
  final ChatController chatController;
  final double width;
  final double height;
  final bool fromCameraSource;

  @override
  State<GalleryImagePreview> createState() => _GalleryImagePreviewState();
}

class _GalleryImagePreviewState extends State<GalleryImagePreview> {
  late final Rx<bool> isSelected;
  final showBar = true.obs;
  final hasZoom = false.obs;
  final swipeProgress = .0.obs;

  @override
  void initState() {
    isSelected = widget.isSelecetd.obs;
    super.initState();
  }

  @override
  void dispose() {
    showBar.dispose();
    swipeProgress.dispose();
    hasZoom.dispose();
    isSelected.dispose();
    super.dispose();
  }

  toggleBar([bool? show]) {
    showBar.value = show ?? !showBar.value;
  }

  Future<Uint8List> get getBytes async {
    if (widget.image.medium != null) {
      return await PhotoGallery.getFile(mediumId: widget.image.medium!.id)
          .then((value) => value.readAsBytesSync());
    }
    return widget.image.file!.readAsBytes();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        systemNavigationBarDividerColor: Colors.black,
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: PopScope(
        onPopInvoked: (didPop) {
          if (didPop && widget.fromCameraSource) {
            widget.controller.removeImage(widget.image);
          }
        },
        child: ValueListenableBuilder<double>(
          valueListenable: swipeProgress,
          builder: (context, value, child) {
            return Scaffold(
              resizeToAvoidBottomInset: false,
              backgroundColor:
                  Colors.black.withOpacity(1 - (value * 4).withRange(0, 0.6)),
              body: child,
            );
          },
          child: Stack(
            children: [
              Center(
                child: GestureDetector(
                  onTap: toggleBar,
                  child: ValueListenableBuilder<bool>(
                    valueListenable: hasZoom,
                    builder: (context, value, child) {
                      return Dismissible(
                        key: const ValueKey('image'),
                        direction: value
                            ? DismissDirection.none
                            : DismissDirection.vertical,
                        onDismissed: (direction) => Navigator.of(context).pop(),
                        onUpdate: (details) {
                          toggleBar(false);
                          swipeProgress.value = details.progress;
                        },
                        child: child!,
                      );
                    },
                    child: KrFutureBuilder<Uint8List>(
                      future: getBytes,
                      builder: (image) {
                        return Zoom(
                          backgroundColor: Colors.transparent,
                          enableScroll: false,
                          initTotalZoomOut: true,
                          initScale: 0.1,
                          doubleTapZoom: true,
                          scrollWeight: 0,
                          onScaleUpdate: (p0, p1) {
                            hasZoom.value = true;
                          },
                          onMinZoom: (_) => hasZoom.value = false,
                          child: CustomImage(
                            bytes: image,
                            fit: BoxFit.contain,
                            width: widget.width,
                            height: widget.height,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: ValueListenableBuilder<bool>(
                  valueListenable: showBar,
                  builder: (context, show, child) {
                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      switchInCurve: Curves.easeOutQuad,
                      switchOutCurve: Curves.easeInQuad,
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SizeTransition(
                            sizeFactor: animation,
                            child: child,
                          ),
                        );
                      },
                      child: show ? child : const SizedBox(),
                    );
                  },
                  child: GestureDetector(
                    onTap: toggleBar,
                    child: Scaffold(
                      resizeToAvoidBottomInset: true,
                      backgroundColor: Colors.transparent,
                      body: Stack(
                        children: [
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              padding: EdgeInsets.only(bottom: 40),
                              width: double.maxFinite,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.black.withOpacity(.5),
                                    Colors.black.withOpacity(0),
                                  ],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                              ),
                              child: SafeArea(
                                bottom: false,
                                child: SizedBox.shrink(),
                              ),
                            ),
                          ),
                          GalleryInputField(
                            controller: widget.controller,
                            chatController: widget.chatController,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topRight,
                child: ValueListenableBuilder<bool>(
                  valueListenable: showBar,
                  builder: (context, show, child) {
                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      switchInCurve: Curves.easeOutQuad,
                      switchOutCurve: Curves.easeInQuad,
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SizeTransition(
                            sizeFactor: animation,
                            child: child,
                          ),
                        );
                      },
                      child: show ? child : const SizedBox(),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(.6),
                          Colors.black.withOpacity(.5),
                          Colors.black.withOpacity(.3),
                          Colors.black.withOpacity(0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    padding: EdgeInsets.only(bottom: 20, left: 10, right: 10),
                    child: SafeArea(
                      bottom: false,
                      child: Row(
                        children: [
                          BackButton(color: Colors.white),
                          const Spacer(),
                          ValueListenableBuilder<bool>(
                            valueListenable: isSelected,
                            builder: (context, isSelected, child) {
                              return GestureDetector(
                                onTap: () {
                                  if (isSelected) {
                                    widget.controller.removeImage(widget.image);
                                  } else {
                                    widget.controller.addImage(widget.image);
                                  }
                                  this.isSelected.value = !isSelected;
                                },
                                child: Row(
                                  children: [
                                    AnimatedSwitcher(
                                      duration: Duration(milliseconds: 200),
                                      transitionBuilder: (child, animation) =>
                                          ScaleTransition(
                                        scale: animation,
                                        child: child,
                                      ),
                                      child: widget
                                              .controller.selected.value.isEmpty
                                          ? SizedBox()
                                          : Container(
                                              key: ValueKey(
                                                'count_with_value',
                                              ),
                                              height: 32,
                                              width: 32,
                                              margin: EdgeInsets.symmetric(
                                                horizontal: 20,
                                              ),
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: Colors.white,
                                                  width: 2,
                                                ),
                                              ),
                                              alignment: Alignment.center,
                                              child: Text(
                                                widget.controller.selected.value
                                                    .length
                                                    .toString(),
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                    ),
                                    Container(
                                      height: 32,
                                      width: 32,
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? Chatify.theme.primaryColor
                                            : null,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2,
                                        ),
                                      ),
                                      alignment: Alignment.center,
                                      child: isSelected
                                          ? Icon(
                                              Icons.check,
                                              size: 18,
                                              color: Colors.white,
                                            )
                                          : SizedBox.shrink(),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

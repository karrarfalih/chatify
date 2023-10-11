import 'dart:io';
import 'package:chatify/src/theme/theme_widget.dart';
import 'package:chatify/src/ui/chat_view/body/images/controller.dart';
import 'package:chatify/src/ui/chat_view/body/images/input_field.dart';
import 'package:chatify/src/ui/common/image.dart';
import 'package:chatify/src/ui/common/kr_builder.dart';
import 'package:chatify/src/utils/value_notifiers.dart';
import 'package:flutter/material.dart';
import 'package:photo_gallery/photo_gallery.dart';

class ImagePreview extends StatefulWidget {
  const ImagePreview({
    super.key,
    required this.image,
    required this.isSelecetd,
    required this.controller,
  });

  final Medium image;
  final bool isSelecetd;
  final GalleryController controller;

  @override
  State<ImagePreview> createState() => _ImagePreviewState();
}

class _ImagePreviewState extends State<ImagePreview> {
  late final Rx<bool> isSelected;

  @override
  void initState() {
    isSelected = widget.isSelecetd.obs;
    super.initState();
  }

  @override
  void dispose() {
    isSelected.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 0,
        automaticallyImplyLeading: false,
      ),
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          KrFutureBuilder<File>(
            future: PhotoGallery.getFile(mediumId: widget.image.id),
            builder: (image) {
              return CustomImage(
                file: image,
                height: double.maxFinite,
                width: double.maxFinite,
                fit: BoxFit.contain,
              );
            },
          ),
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
          Column(
            children: [
              Container(
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
                                  child:
                                      widget.controller.selected.value.isEmpty
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
                                        ? ChatifyTheme.of(context).primaryColor
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
              Expanded(
                child: Scaffold(
                  backgroundColor: Colors.transparent,
                  body: GalleryInputField(controller: widget.controller),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

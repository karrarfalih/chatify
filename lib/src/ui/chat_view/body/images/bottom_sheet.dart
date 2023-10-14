import 'package:chatify/src/const.dart';
import 'package:chatify/src/theme/theme_widget.dart';
import 'package:chatify/src/ui/chat_view/body/images/camera_thumnail.dart';
import 'package:chatify/src/ui/chat_view/body/images/controller.dart';
import 'package:chatify/src/ui/chat_view/body/images/image_preview.dart';
import 'package:chatify/src/ui/chat_view/body/images/input_field.dart';
import 'package:chatify/src/ui/common/bottom_sheet/flexible_bottom_sheet_route.dart';
import 'package:chatify/src/ui/common/sliver/sliver_container.dart';
import 'package:chatify/src/ui/common/sliver_group.dart';
import 'package:chatify/src/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:photo_gallery/photo_gallery.dart';

showImagesGallery(BuildContext context) async {
  final controller = GalleryController();
  await showFlexibleBottomSheet(
    minHeight: 0,
    initHeight: 0.7,
    context: context,
    builder: (context, scrollController, bottomSheetOffset) => _ChatImages(
      controller: controller,
      scrollController: scrollController,
    ),
    anchors: [],
    isSafeArea: false,
    decoration: BoxDecoration(
      color: Theme.of(context).scaffoldBackgroundColor,
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    bottomSheetBorderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  );
  controller.dispos();
}

class _ChatImages extends StatefulWidget {
  _ChatImages({
    required this.controller,
    required this.scrollController,
  });

  final GalleryController controller;
  final ScrollController scrollController;

  @override
  State<_ChatImages> createState() => _ChatImagesState();
}

class _ChatImagesState extends State<_ChatImages> {
  @override
  void initState() {
    widget.controller.init().then((isSuccess) {
      if (!isSuccess) Navigator.of(context).pop();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ChatifyTheme.of(context);
    return Stack(
      children: [
        NotificationListener(
          onNotification: (x) {
            if (x is ScrollMetricsNotification &&
                widget.controller.images.value.isNotEmpty) {
              final rowsCount =
                  ((widget.controller.images.value.length + 1) / 3).ceil() - 6;
              final spacing = (rowsCount ~/ 2) * 4;
              final imageHeight = (MediaQuery.of(context).size.width - 20) / 3;
              final imagesHeight = (rowsCount * imageHeight) + spacing - 50;
              if (x.metrics.pixels >= imagesHeight) {
                widget.controller.loadMoreImages();
              }
            }
            return false;
          },
          child: CustomScrollView(
            physics: ClampingScrollPhysics(),
            controller: widget.scrollController,
            slivers: [
              SliverToBoxAdapter(
                child: ValueListenableBuilder<List<Medium>>(
                  valueListenable: widget.controller.selected,
                  builder: (context, selected, child) {
                    return Padding(
                      padding: EdgeInsetsDirectional.only(
                        start: 20,
                        bottom: 14,
                        top: 16,
                      ),
                      child: Text(
                        selected.isEmpty
                            ? 'Select Media'
                            : '${selected.length} photo selected',
                        style: TextStyle(fontSize: 16),
                      ),
                    );
                  },
                ),
              ),
              DecoratedSliver(
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                ),
                sliver: SliverContainer(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  background: Container(
                    color: Theme.of(context).scaffoldBackgroundColor,
                  ),
                  margin: EdgeInsets.symmetric(horizontal: 6),
                  sliver: ValueListenableBuilder<List<Medium>>(
                    valueListenable: widget.controller.images,
                    builder: (context, images, child) {
                      return SliverGrid.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 1,
                          crossAxisSpacing: 4,
                          mainAxisSpacing: 4,
                        ),
                        itemCount: images.length + 1,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return CameraThumnail(
                              controller: widget.controller,
                            );
                          }
                          return StatefulBuilder(
                            builder: (context, setState) {
                              final image = images.elementAt(index - 1);
                              bool isSelected = widget.controller.selected.value
                                  .contains(image);
                              return Stack(
                                alignment: AlignmentDirectional.topEnd,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => ImagePreview(
                                            image: image,
                                            isSelecetd: isSelected,
                                            controller: widget.controller,
                                          ),
                                        ),
                                      );
                                    },
                                    child: AnimatedScale(
                                      duration: Duration(milliseconds: 170),
                                      scale: isSelected ? 0.8 : 1,
                                      child: Container(
                                        height: double.maxFinite,
                                        width: double.maxFinite,
                                        color: Theme.of(context)
                                            .scaffoldBackgroundColor,
                                        child: Stack(
                                          children: [
                                            Container(
                                              width: double.maxFinite,
                                              height: double.maxFinite,
                                              color: theme.chatForegroundColor
                                                  .withOpacity(0.07),
                                              child: Icon(
                                                Iconsax.gallery,
                                                color: theme.chatForegroundColor
                                                    .withOpacity(0.4),
                                              ),
                                            ),
                                            AspectRatio(
                                              aspectRatio: 1,
                                              child: FadeInImage(
                                                fit: BoxFit.cover,
                                                placeholder: MemoryImage(
                                                  kTransparentImage,
                                                ),
                                                image: ThumbnailProvider(
                                                  mediumId: image.id,
                                                  highQuality: true,
                                                ),
                                              ),
                                            ),
                                            if (image.mediumType ==
                                                MediumType.video)
                                              Align(
                                                alignment: AlignmentDirectional
                                                    .bottomStart,
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 5,
                                                    vertical: 2,
                                                  ),
                                                  margin: EdgeInsets.all(4),
                                                  decoration: BoxDecoration(
                                                    color: Colors.black26,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                      5,
                                                    ),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        Icons
                                                            .play_arrow_rounded,
                                                        size: 16,
                                                        color: Colors.white,
                                                      ),
                                                      Text(
                                                        (image.duration ~/ 1000)
                                                            .toDurationString,
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => setState(() {
                                      if (isSelected) {
                                        widget.controller.selected.value =
                                            widget.controller.selected.value
                                                .where((e) => e != image)
                                                .toList();
                                      } else {
                                        widget.controller.selected.value = [
                                          ...widget.controller.selected.value,
                                          image
                                        ];
                                      }
                                    }),
                                    icon: isSelected
                                        ? Container(
                                            width: 26,
                                            height: 26,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: theme.primaryColor,
                                            ),
                                            alignment: Alignment.center,
                                            child: ValueListenableBuilder<
                                                List<Medium>>(
                                              valueListenable:
                                                  widget.controller.selected,
                                              builder:
                                                  (context, selected, child) {
                                                return Text(
                                                  (selected.indexOf(image) + 1)
                                                      .toString(),
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    height: 1,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                );
                                              },
                                            ),
                                          )
                                        : Container(
                                            height: 23,
                                            width: 23,
                                            decoration: BoxDecoration(
                                              color: ChatifyTheme.of(context)
                                                  .chatForegroundColor
                                                  .withOpacity(0.07),
                                              border: Border.all(
                                                color: Colors.white,
                                                width: 2,
                                              ),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: ValueListenableBuilder<List<Medium>>(
            valueListenable: widget.controller.selected,
            builder: (context, selected, child) {
              if (selected.isEmpty) return SizedBox.shrink();
              return GalleryInputField(
                controller: widget.controller,
                isSubmit: false,
              );
            },
          ),
        )
      ],
    );
  }
}

class Images extends StatefulWidget {
  const Images({super.key});

  @override
  State<Images> createState() => _ImagesState();
}

class _ImagesState extends State<Images> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

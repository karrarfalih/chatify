import 'package:chatify/src/theme/theme_widget.dart';
import 'package:chatify/src/ui/chat_view/body/images/controller.dart';
import 'package:chatify/src/ui/common/sliver/sliver_container.dart';
import 'package:chatify/src/ui/common/sliver_group.dart';
import 'package:flutter/material.dart';
import 'package:photo_gallery/photo_gallery.dart';
import 'package:transparent_image/transparent_image.dart';

showImagesGallery(BuildContext context) {
  final controller = GalleryController();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.black.withOpacity(0.1),
    builder: (BuildContext bc) {
      return _ChatImages(
        controller: controller,
      );
    },
  );
}

class _ChatImages extends StatelessWidget {
  _ChatImages({
    required this.controller,
  });

  final GalleryController controller;

  @override
  Widget build(BuildContext context) {
    final theme = ChatifyTheme.of(context);
    bool isClosed = false;
    return Stack(
      children: [
        NotificationListener(
          onNotification: (not) {
            if (isClosed) return false;
            if (not is ScrollUpdateNotification) {
              if (not.metrics.pixels < -100) {
                isClosed = true;
                Navigator.pop(context);
              }
            }
            return false;
          },
          child: CustomScrollView(
            physics: BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: GestureDetector(
                  onTap: Navigator.of(context).pop,
                  child: ValueListenableBuilder<List<Medium>>(
                    valueListenable: controller.selected,
                    builder: (context, selected, child) {
                      return Container(
                        height: selected.isEmpty ? 300 : 265,
                        color: Colors.transparent,
                      );
                    },
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: ValueListenableBuilder<List<Medium>>(
                  valueListenable: controller.selected,
                  builder: (context, selected, child) {
                    if (selected.isEmpty) return SizedBox.shrink();
                    return Container(
                      height: 35,
                      color: Theme.of(context).scaffoldBackgroundColor,
                      padding: EdgeInsetsDirectional.only(
                        start: 20,
                        bottom: 10,
                      ),
                      child: Text(
                        '${selected.length} photo slected',
                        style: TextStyle(fontSize: 16),
                      ),
                    );
                  },
                ),
              ),
              ValueListenableBuilder<List<Medium>>(
                valueListenable: controller.images,
                builder: (context, images, child) {
                  return DecoratedSliver(
                    decoration: BoxDecoration(color: Colors.white),
                    sliver: SliverPadding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverContainer(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(20)),
                        sliver: SliverGrid.builder(
                          gridDelegate:
                              SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 170,
                            crossAxisSpacing: 4,
                            mainAxisSpacing: 4,
                          ),
                          itemCount: images.length,
                          itemBuilder: (context, index) {
                            return StatefulBuilder(
                              builder: (context, setState) {
                                final image = images.elementAt(index);
                                bool isSelected =
                                    controller.selected.value.contains(image);
                                return Stack(
                                  alignment: AlignmentDirectional.topEnd,
                                  children: [
                                    AnimatedScale(
                                      duration: Duration(milliseconds: 300),
                                      scale: isSelected ? 0.8 : 1,
                                      child: Container(
                                        height: double.maxFinite,
                                        width: double.maxFinite,
                                        color: Theme.of(context)
                                            .scaffoldBackgroundColor,
                                        child: FadeInImage(
                                          fit: BoxFit.cover,
                                          placeholder:
                                              MemoryImage(kTransparentImage),
                                          image: ThumbnailProvider(
                                            mediumId: image.id,
                                            width: 300,
                                            height: 300,
                                          ),
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () => setState(() {
                                        if (isSelected) {
                                          controller.selected.value = controller
                                              .selected.value
                                              .where((e) => e != image)
                                              .toList();
                                        } else {
                                          controller.selected.value = [
                                            ...controller.selected.value,
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
                                                    controller.selected,
                                                builder:
                                                    (context, selected, child) {
                                                  return Text(
                                                    (selected.indexOf(image) +
                                                            1)
                                                        .toString(),
                                                    style: TextStyle(
                                                      color: Theme.of(context)
                                                          .scaffoldBackgroundColor,
                                                      height: 1,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  );
                                                },
                                              ),
                                            )
                                          : Icon(
                                              isSelected
                                                  ? Icons.circle
                                                  : Icons
                                                      .radio_button_unchecked,
                                              size: 26,
                                            ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              )
            ],
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: ValueListenableBuilder<List<Medium>>(
            valueListenable: controller.selected,
            builder: (context, selected, child) {
              if (selected.isEmpty) return SizedBox.shrink();
              return SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextButton(
                    onPressed: Navigator.of(context).pop,
                    style: TextButton.styleFrom(
                      backgroundColor: theme.primaryColor,
                      minimumSize: Size(200, 0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Send photos (${selected.length})',
                      style: TextStyle(
                        fontSize: 18,
                        color: Theme.of(context).scaffoldBackgroundColor,
                      ),
                    ),
                  ),
                ),
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

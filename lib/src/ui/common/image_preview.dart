import 'package:chatify/chatify.dart';
import 'package:chatify/src/ui/chat_view/message/widgets/image/controller.dart';
import 'package:chatify/src/ui/common/circular_button.dart';
import 'package:chatify/src/ui/common/hero_dialog.dart';
import 'package:chatify/src/ui/common/image.dart';
import 'package:chatify/src/ui/common/toast.dart';
import 'package:chatify/src/theme/theme_widget.dart';
import 'package:chatify/src/utils/extensions.dart';
import 'package:chatify/src/utils/image_saver.dart';
import 'package:chatify/src/utils/value_notifiers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide Actions;
import 'package:flutter/services.dart';
import 'package:kr_pull_down_button/pull_down_button.dart';
import 'package:zoom_widget/zoom_widget.dart';

class ChatImagePreview extends StatefulWidget {
  final ImageMessage msg;
  final ChatifyUser user;
  final ImageMessageController controller;

  const ChatImagePreview({
    Key? key,
    required this.msg,
    required this.user,
    required this.controller,
  }) : super(key: key);

  static show({
    required ImageMessage message,
    required ChatifyUser user,
    required ImageMessageController controller,
    required BuildContext context,
  }) async {
    showDialogWithHero(
      child: ChatImagePreview(
        msg: message,
        user: user,
        controller: controller,
      ),
      context: context,
    );
  }

  @override
  State<ChatImagePreview> createState() => _ChatImagePreviewState();
}

class _ChatImagePreviewState extends State<ChatImagePreview> {
  final showBar = true.obs;
  final hasZoom = false.obs;
  final swipeProgress = .0.obs;

  @override
  void dispose() {
    showBar.dispose();
    swipeProgress.dispose();
    hasZoom.dispose();
    super.dispose();
  }

  toggleBar([bool? show]) {
    showBar.value = show ?? !showBar.value;
  }

  @override
  Widget build(BuildContext context) {
    return ImagePreview(
      heroId: widget.msg.id,
      bytes: widget.controller.bytes!,
      topBar: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CircularButton(
            onPressed: Navigator.of(context).pop,
            icon: const Icon(
              Icons.arrow_back_ios,
              size: 24,
              color: Colors.white,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                (widget.msg.isMine ? 'Me' : widget.user.name),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                widget.msg.sendAt?.format(context, 'MM.dd.yy hh:mm a') ?? '',
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
          Spacer(),
          PullDownButton(
            routeTheme: const PullDownMenuRouteTheme(
              backgroundColor: Color(0xff222222),
              width: 150,
            ),
            offset: const Offset(0, 10),
            itemBuilder: (context) => [
              PullDownMenuItem(
                title: 'Save',
                icon: Icons.save,
                iconColor: Colors.white,
                itemTheme: const PullDownMenuItemTheme(
                  textStyle: TextStyle(color: Colors.white),
                ),
                onTap: () async {
                  final res = await ImageGallerySaver.downloadAndSaveFile(
                    widget.msg.imageUrl,
                  );
                  showToast(
                    res ? "Saved to gallery" : 'Download failed',
                    ChatifyTheme.of(context).primaryColor.withOpacity(0.5),
                  );
                },
              ),
              const PullDownMenuDivider(),
              PullDownMenuItem(
                title: 'Delete',
                icon: CupertinoIcons.delete,
                itemTheme: const PullDownMenuItemTheme(
                  textStyle: TextStyle(color: Colors.white),
                ),
                iconColor: Colors.red,
                onTap: () {
                  // Chatify.datasource.deleteMessageForAll(msg!.id);
                  Navigator.pop(context);
                },
              ),
            ],
            position: PullDownMenuPosition.automatic,
            applyOpacity: true,
            buttonBuilder: (context, showMenu) => CircularButton(
              onPressed: showMenu,
              icon: const Icon(
                Icons.more_vert,
                size: 24,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ImagePreview extends StatefulWidget {
  const ImagePreview({
    super.key,
    required this.heroId,
    required this.bytes,
    required this.topBar,
    this.bottomBar,
  });

  final String heroId;
  final Uint8List bytes;
  final Widget topBar;
  final Widget? bottomBar;

  @override
  State<ImagePreview> createState() => _ImagePreviewState();
}

class _ImagePreviewState extends State<ImagePreview> {
  final showBar = true.obs;
  final hasZoom = false.obs;
  final swipeProgress = .0.obs;

  @override
  void dispose() {
    showBar.dispose();
    swipeProgress.dispose();
    hasZoom.dispose();
    super.dispose();
  }

  toggleBar([bool? show]) {
    showBar.value = show ?? !showBar.value;
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        systemNavigationBarDividerColor: Colors.black,
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: ValueListenableBuilder<double>(
        valueListenable: swipeProgress,
        builder: (context, value, child) {
          return Scaffold(
            backgroundColor:
                Colors.black.withOpacity(1 - (value * 4).withRange(0, 0.6)),
            body: child,
          );
        },
        child: Stack(
          children: [
            Center(
              child: Center(
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
                    child: Zoom(
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
                      child: Hero(
                        tag: widget.heroId,
                        placeholderBuilder: (context, size, child) {
                          return Container(
                            width: size.width,
                            height: size.height,
                            color: Colors.black,
                          );
                        },
                        child: CustomImage(
                          bytes: widget.bytes,
                          width: MediaQuery.of(context).size.width,
                          fit: BoxFit.cover,
                        ),
                      ),
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
                  key: ValueKey('topBar'),
                  padding:
                      const EdgeInsetsDirectional.only(start: 20, bottom: 10),
                  color: Colors.black.withOpacity(0.5),
                  child: SafeArea(
                    bottom: false,
                    child: widget.topBar,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

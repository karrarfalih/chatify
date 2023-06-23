import 'package:chat/assets/image.dart';
import 'package:chat/models/message.dart';
import 'package:chat/models/theme.dart';
import 'package:chat/models/user.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide Actions;
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:chat/assets/circular_button.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:kr_extensions/kr_extensions.dart';
import 'package:kr_pull_down_button/pull_down_button.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

bool showedForm = true;

Future<void> showImage({String? url, MessageModel? msg, ChatUser? user}) async {
  await Get.to(
      ImagePreview(
        msg: msg,
        user: user,
        url: url,
      ),
      popGesture: true,
      transition: Transition.fadeIn);
}

class ImagePreview extends StatelessWidget {
  final MessageModel? msg;
  final ChatUser? user;
  final String? url;
  const ImagePreview(
      {Key? key, required this.msg, required this.user, this.url})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: Hero(
              tag: url ?? msg?.messageAttachment ?? '',
              child: MyImage(
                url: url ?? msg?.messageAttachment,
                isCircle: false,
                width: Get.width,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CircularButton(
                      onPressed: Get.back,
                      icon: const Icon(Icons.arrow_back_ios,
                          size: 24, color: Colors.white60),
                    ),
                    PullDownButton(
                      routeTheme: const PullDownMenuRouteTheme(
                          backgroundColor: Color(0xff222222), width: 150),
                          offset: Offset(0, 10),
                      itemBuilder: (context) => [
                        PullDownMenuItem(
                          title: 'Save'.tr,
                          icon: Icons.save,
                          iconColor: Colors.white,
                          itemTheme: const PullDownMenuItemTheme(
                            textStyle: TextStyle(color: Colors.white),
                          ),
                          onTap: () async {
                            var appDocDir = await getTemporaryDirectory();
                            String savePath =
                                "${appDocDir.path}/${const Uuid().v4()}";
                            await Dio().download(
                                msg?.messageAttachment ?? '', savePath);
                            await ImageGallerySaver.saveFile(savePath);
                            Fluttertoast.showToast(
                                msg: "Saved to gallery".tr,
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.CENTER,
                                timeInSecForIosWeb: 1,
                                backgroundColor:
                                    currentTheme.primary.withOpacity(0.5),
                                textColor: Colors.white,
                                fontSize: 16.0);
                          },
                        ),
                        if (url == null) const PullDownMenuDivider(),
                        if (url == null)
                          PullDownMenuItem(
                            title: 'Delete'.tr,
                            icon: CupertinoIcons.delete,
                            itemTheme: const PullDownMenuItemTheme(
                              textStyle: TextStyle(color: Colors.white),
                            ),
                            iconColor: Colors.red,
                            onTap: () {
                              msg?.delete();
                              Get.back();
                            },
                          ),
                      ],
                      position: PullDownMenuPosition.automatic,
                      applyOpacity: true,
                      buttonBuilder: (context, showMenu) => CircularButton(
                        onPressed: showMenu,
                        icon: const Icon(Icons.more_vert,
                            size: 24, color: Colors.white60),
                      ),
                    ),
                  ],
                ),
              )),
          if (url == null)
            Align(
                alignment: AlignmentDirectional.bottomStart,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          (msg!.sender == ChatUser.current?.id
                                  ? ChatUser.current!
                                  : user!)
                              .name,
                          style: const TextStyle(color: Colors.white),
                        ),
                        Text(
                          msg!.sendAt?.format('MM.dd.yy hh:mm a') ?? '',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                )),
        ],
      ),
    );
  }
}

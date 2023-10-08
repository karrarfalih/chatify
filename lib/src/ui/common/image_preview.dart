import 'package:chatify/chatify.dart';
import 'package:chatify/src/assets/image.dart';
import 'package:chatify/src/models/models.dart';
import 'package:chatify/src/theme/theme_widget.dart';
import 'package:chatify/src/utils/uuid.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide Actions;
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:chatify/src/assets/circular_button.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:kr_extensions/kr_extensions.dart';
import 'package:kr_pull_down_button/pull_down_button.dart';
import 'package:path_provider/path_provider.dart';

bool showedForm = true;

class ImagePreview extends StatelessWidget {
  final Message? msg;
  final ChatifyUser? user;
  final String? url;

  const ImagePreview(
      {Key? key, required this.msg, required this.user, this.url})
      : super(key: key);

  static route({required Message? message, ChatifyUser? user, String? url}) =>
      MaterialPageRoute(
          builder: (ctx) => ImagePreview(
                msg: message,
                url: url,
                user: user,
              ));

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
              tag: url ?? msg?.attachment ?? '',
              child: CustomImage(
                url: url ?? msg?.attachment,
                width: MediaQuery.of(context).size.width,
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
                      onPressed: Navigator.of(context).pop,
                      icon: const Icon(Icons.arrow_back_ios,
                          size: 24, color: Colors.white60),
                    ),
                    PullDownButton(
                      routeTheme: const PullDownMenuRouteTheme(
                          backgroundColor: Color(0xff222222), width: 150),
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
                            var appDocDir = await getTemporaryDirectory();
                            String savePath =
                                "${appDocDir.path}/${Uuid.generate()}";
                            await Dio()
                                .download(msg?.attachment ?? '', savePath);
                            await ImageGallerySaver.saveFile(savePath);
                            Fluttertoast.showToast(
                                msg: "Saved to gallery",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.CENTER,
                                timeInSecForIosWeb: 1,
                                backgroundColor: ChatifyTheme.of(context)
                                    .primaryColor
                                    .withOpacity(0.5),
                                textColor: Colors.white,
                                fontSize: 16.0);
                          },
                        ),
                        if (url == null) const PullDownMenuDivider(),
                        if (url == null)
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
                          (msg!.sender == Chatify.currentUserId
                              ? 'Me'
                              : user!.name),
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

import 'dart:ui';
import 'package:chatify/src/theme/theme_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kr_pull_down_button/pull_down_button.dart';
import 'package:chatify/src/assets/circular_button.dart';

class ChatAppBar extends StatelessWidget {
  const ChatAppBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: Container(
              padding: const EdgeInsets.only(bottom: 4),
              decoration: BoxDecoration(
                color: ChatifyTheme.of(context).isChatDark
                    ? Colors.black.withOpacity(0.4)
                    : Colors.white.withOpacity(0.4),
                border: Border(
                  bottom: BorderSide(
                    color: (ChatifyTheme.of(context).isChatDark
                            ? Colors.white
                            : Colors.black)
                        .withOpacity(0.07),
                    width: 1,
                  ),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Row(
                  children: [
                    InkWell(
                      highlightColor: Colors.transparent,
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsetsDirectional.only(
                          start: 16,
                          end: 16,
                          top: 16,
                          bottom: 16,
                        ),
                        child: Icon(
                          CupertinoIcons.back,
                          color:
                              ChatifyTheme.of(context).isChatDark
                                  ? Colors.white
                                  : Colors.black,
                        ),
                      ),
                    ),
                    // UserAvatar(
                    //   uid: widget.user.id,
                    //   onTap: options.onUserClick,
                    // ),
                    const Spacer(),
                    PullDownButton(
                      routeTheme: PullDownMenuRouteTheme(
                        width: 140,
                        backgroundColor:
                            ChatifyTheme.of(context).isChatDark
                                ? Colors.black
                                : Colors.white,
                      ),
                      itemBuilder: (context) => [
                        PullDownMenuItem(
                          title: 'Delete',
                          icon: Icons.delete,
                          iconColor: Colors.red,
                          itemTheme: PullDownMenuItemTheme(
                            textStyle: TextStyle(
                              color: ChatifyTheme.of(
                                context,
                              ).isChatDark
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                          onTap: () async {
                            // if (await confirm(
                            //   Get.context!,
                            //   title: Text('Confirm'.tr),
                            //   content: Text(
                            //     'All messages will be deleted. Are you sure?'
                            //         .tr,
                            //   ),
                            //   textOK: Text('Yes'.tr),
                            //   textCancel: Text('No'.tr),
                            // )) {
                            //   await widget.chat.delete();
                            //   Get.back();
                            // }
                          },
                        ),
                      ],
                      position: PullDownMenuPosition.automatic,
                      applyOpacity: false,
                      buttonBuilder: (context, showMenu) =>
                          CircularButton(
                        icon: Icon(
                          Icons.more_vert,
                          color:
                              ChatifyTheme.of(context).isChatDark
                                  ? Colors.white
                                  : Colors.black,
                        ),
                        onPressed: showMenu,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

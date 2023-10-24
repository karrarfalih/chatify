import 'dart:ui';
import 'package:chatify/chatify.dart';
import 'package:chatify/src/ui/chat_view/controllers/chat_controller.dart';
import 'package:chatify/src/ui/common/animated_flip_counter.dart';
import 'package:chatify/src/ui/common/circular_button.dart';
import 'package:chatify/src/ui/common/confirm.dart';
import 'package:chatify/src/ui/common/expanded_section.dart';
import 'package:chatify/src/ui/common/image.dart';
import 'package:chatify/src/core/chatify.dart';
import 'package:chatify/src/ui/common/kr_stream_builder.dart';
import 'package:chatify/src/ui/common/timer_refresher.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:kr_pull_down_button/pull_down_button.dart';

class ChatAppBar extends StatelessWidget {
  const ChatAppBar({
    super.key,
    required this.user,
    required this.chatController,
  });

  final ChatifyUser user;
  final ChatController chatController;

  @override
  Widget build(BuildContext context) {
    final theme = Chatify.theme;
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: ValueListenableBuilder<Map<String, Message>>(
          valueListenable: chatController.selecetdMessages,
          builder: (context, selecetdMessages, child) {
            return Container(
              padding: const EdgeInsets.only(bottom: 10, top: 16),
              decoration: BoxDecoration(
                color: selecetdMessages.isEmpty
                    ? (theme.isChatDark ? Colors.black : Colors.white)
                        .withOpacity(0.4)
                    : theme.primaryColor.withOpacity(0.4),
                border: Border(
                  bottom: BorderSide(
                    color: (theme.isChatDark ? Colors.white : Colors.black)
                        .withOpacity(0.07),
                    width: 1,
                  ),
                ),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: selecetdMessages.isEmpty
                    ? child!
                    : SafeArea(
                        key: ValueKey('chat_appbar_selected_messages'),
                        bottom: false,
                        child: SizedBox(
                          height: 45,
                          child: Row(
                            children: [
                              InkWell(
                                highlightColor: Colors.transparent,
                                onTap: () {
                                  chatController.selecetdMessages
                                    ..value.clear()
                                    ..refresh();
                                },
                                child: Container(
                                  padding: const EdgeInsetsDirectional.only(
                                    start: 16,
                                    end: 16,
                                    top: 16,
                                    bottom: 16,
                                  ),
                                  child: Icon(
                                    Icons.close,
                                    color: theme.isChatDark
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                              ),
                              AnimatedFlipCounter(
                                value: selecetdMessages.length,
                                duration: Duration(milliseconds: 200),
                                textStyle: TextStyle(
                                  color: theme.chatForegroundColor,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                ' selected',
                                style: TextStyle(
                                  color: theme.chatForegroundColor,
                                  fontSize: 16,
                                ),
                              ),
                              Spacer(),
                              IconButton(
                                onPressed: () async {
                                  if (await showConfirm(
                                    context: context,
                                    message: 'Delete selected message?',
                                    textOK: 'Yes',
                                    textCancel: 'No',
                                    isKeyboardShown: chatController
                                        .keyboardController.isKeybaordOpen,
                                  )) {
                                    for (final msg in selecetdMessages.values) {
                                      Chatify.datasource
                                          .deleteMessageForAll(msg.id);
                                    }
                                    chatController.selecetdMessages
                                      ..value.clear()
                                      ..refresh();
                                  }
                                },
                                icon: Icon(
                                  Iconsax.trash,
                                  color: theme.chatForegroundColor,
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
            );
          },
          child: SafeArea(
            key: ValueKey('chat_appbar_no_selected_messages'),
            bottom: false,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 45),
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
                        color: theme.isChatDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () => Chatify.config.onUserClick?.call(user),
                      child: Row(
                        children: [
                          CustomImage(
                            url: user.profileImage,
                            width: 45,
                            height: 45,
                            radius: 45,
                            fit: BoxFit.cover,
                            onError:
                                const Icon(Icons.person, color: Colors.grey),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  user.name,
                                  style: TextStyle(
                                    color: theme.chatForegroundColor,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(
                                  height: 15,
                                  child: KrStreamBuilder<UserLastSeen>(
                                    stream: Chatify.datasource.getUserLastSeen(
                                      user.id,
                                      chatController.chat.id,
                                    ),
                                    onLoading: SizedBox.shrink(),
                                    onError: (e) {
                                      print(e);
                                      return SizedBox.shrink();
                                    },
                                    builder: (user) {
                                      return KrExpandedSection(
                                        expand: true,
                                        child: Column(
                                          key: ValueKey('none_user_status'),
                                          children: [
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                if (user.isActive)
                                                  Container(
                                                    height: 8,
                                                    width: 8,
                                                    margin:
                                                        EdgeInsetsDirectional
                                                            .only(
                                                      end: 5,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: Colors.green,
                                                    ),
                                                  ),
                                                TimerRefresher(
                                                  lastSeen: user.lastSeen,
                                                  isActive: user.isActive,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  PullDownButton(
                    routeTheme: PullDownMenuRouteTheme(
                      width: 140,
                      backgroundColor:
                          theme.isChatDark ? Colors.black : Colors.white,
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
                    buttonBuilder: (context, showMenu) => CircularButton(
                      icon: Icon(
                        Icons.more_vert,
                        color: theme.isChatDark ? Colors.white : Colors.black,
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
    );
  }
}

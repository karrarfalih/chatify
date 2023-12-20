import 'dart:io';
import 'dart:ui';
import 'package:chatify/chatify.dart';
import 'package:chatify/src/ui/chat_view/controllers/chat_controller.dart';
import 'package:chatify/src/ui/chats/chat_image.dart';
import 'package:chatify/src/ui/chats/connectivity.dart';
import 'package:chatify/src/ui/common/animated_flip_counter.dart';
import 'package:chatify/src/ui/common/circular_button.dart';
import 'package:chatify/src/ui/common/circular_loading.dart';
import 'package:chatify/src/ui/common/confirm.dart';
import 'package:chatify/src/ui/common/expanded_section.dart';
import 'package:chatify/src/ui/common/kr_stream_builder.dart';
import 'package:chatify/src/ui/common/timer_refresher.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:kr_pull_down_button/pull_down_button.dart';
import 'package:rxdart/rxdart.dart';

class ChatAppBar extends StatelessWidget {
  const ChatAppBar({
    super.key,
    required this.users,
    required this.chatController,
    required this.connectivity,
  });

  final List<ChatifyUser> users;
  final ChatController chatController;
  final ChatifyConnectivity connectivity;

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
              padding:
                  EdgeInsets.only(bottom: 10, top: Platform.isIOS ? 0 : 16),
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
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
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
                                final deleteForAll = await showConfirmDialog(
                                  context: context,
                                  message:
                                      'Are you sure you want to delete these messages?',
                                  title:
                                      'Delete ${selecetdMessages.values.length} messages',
                                  textOK: 'Delete',
                                  textCancel: 'Cacnel',
                                  showDeleteForAll: true,
                                  isKeyboardShown: chatController
                                      .keyboardController.isKeybaordOpen,
                                );
                                if (deleteForAll == null) return;
                                for (final msg in selecetdMessages.values) {
                                  if (deleteForAll == true) {
                                    Chatify.datasource.deleteMessageForMe(
                                      msg.id,
                                    );
                                  } else {
                                    Chatify.datasource.deleteMessageForMe(
                                      msg.id,
                                    );
                                  }
                                }
                                chatController.selecetdMessages
                                  ..value.clear()
                                  ..refresh();
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
            );
          },
          child: SafeArea(
            key: ValueKey('chat_appbar_no_selected_messages'),
            bottom: false,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 55),
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
                      child: Row(
                        children: [
                          if (chatController.chat.title == 'Saved Messages')
                            Container(
                              height: 44,
                              width: 44,
                              decoration: BoxDecoration(
                                color: Chatify.theme.primaryColor,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Iconsax.save_2,
                                color: Colors.white,
                              ),
                            )
                          else
                            Transform.scale(
                              scale: 44 / 50,
                              child: ChatImage(users: users.withoutMeOrMe),
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
                                  chatController.chat.title ??
                                      users.withoutMeOrMe
                                          .map((e) => e.name.split(' ').first)
                                          .join(', '),
                                  style: TextStyle(
                                    color: theme.chatForegroundColor,
                                    fontSize: 16,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (chatController.chat.title !=
                                    'Saved Messages')
                                  SizedBox(
                                    height: 15,
                                    child: _ChatStatus(
                                      chatController: chatController,
                                      users: users,
                                      connectivity: connectivity,
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
                          final deleteForAll = await showConfirmDialog(
                            context: context,
                            message:
                                'Are you sure you want to delete this chat?',
                            title: 'Delete chat',
                            textOK: 'Delete',
                            textCancel: 'Cacnel',
                            showDeleteForAll: true,
                            isKeyboardShown: chatController
                                .keyboardController.isKeybaordOpen,
                          );
                          if (deleteForAll == null) return;
                          if (deleteForAll == true) {
                            Chatify.datasource.deleteChatForAll(
                              chatController.chat.id,
                            );
                            Navigator.pop(context);
                          } else if (deleteForAll == false) {
                            Chatify.datasource
                                .deleteChatForMe(chatController.chat.id);
                            Navigator.pop(context);
                          }
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

class _ChatStatus extends StatelessWidget {
  const _ChatStatus({
    required this.chatController,
    required this.users,
    required this.connectivity,
  });
  final ChatController chatController;
  final List<ChatifyUser> users;
  final ChatifyConnectivity connectivity;

  @override
  Widget build(BuildContext context) {
    return KrStreamBuilder<ConnectivityStatus>(
      stream: connectivity.connection,
      onLoading: SizedBox.shrink(),
      builder: (connectionStatus) {
        if (connectionStatus == ConnectivityStatus.waiting) {
          return Row(
            children: [
              LoadingWidget(
                size: 10,
                lineWidth: 1,
                color: Chatify.theme.chatForegroundColor.withOpacity(
                  0.5,
                ),
              ),
              SizedBox(
                width: 6,
              ),
              Text(
                'Waiting connection...',
                style: TextStyle(
                  color: Chatify.theme.chatForegroundColor.withOpacity(
                    0.5,
                  ),
                  fontSize: 11,
                  height: 1,
                ),
              ),
            ],
          );
        } else if (connectionStatus == ConnectivityStatus.connecting)
          return Row(
            children: [
              LoadingWidget(
                size: 10,
                lineWidth: 1,
                color: Chatify.theme.chatForegroundColor.withOpacity(
                  0.5,
                ),
              ),
              SizedBox(
                width: 6,
              ),
              Text(
                'Connecting...',
                style: TextStyle(
                  color: Chatify.theme.chatForegroundColor.withOpacity(
                    0.5,
                  ),
                  fontSize: 11,
                  height: 1,
                ),
              ),
            ],
          );
        if (users.length > 2) {
          return _MutipleUsersLastSeen(
            chatController: chatController,
            users: users,
          );
        }
        return _SingleUserLastSeen(
          chatController: chatController,
          user: users.withoutMeOrMe.first,
        );
      },
    );
  }
}

class _SingleUserLastSeen extends StatelessWidget {
  const _SingleUserLastSeen({
    required this.chatController,
    required this.user,
  });

  final ChatController chatController;
  final ChatifyUser user;

  @override
  Widget build(BuildContext context) {
    return KrStreamBuilder<UserLastSeen>(
      stream: Chatify.datasource.getUserLastSeen(
        user.id,
        chatController.chat.id,
      ),
      onLoading: SizedBox.shrink(),
      builder: (user) {
        return KrExpandedSection(
          key: ValueKey(user.isActive),
          expand: true,
          child: Column(
            key: ValueKey('none_user_status'),
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (user.isActive)
                    Container(
                      height: 8,
                      width: 8,
                      margin: EdgeInsetsDirectional.only(
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
    );
  }
}

class _MutipleUsersLastSeen extends StatefulWidget {
  const _MutipleUsersLastSeen({
    required this.chatController,
    required this.users,
  });

  final ChatController chatController;
  final List<ChatifyUser> users;

  @override
  State<_MutipleUsersLastSeen> createState() => _MutipleUsersLastSeenState();
}

class _MutipleUsersLastSeenState extends State<_MutipleUsersLastSeen> {
  late Stream<int> activeUserCount;

  _SingleUserLastSeen getSingleUserScreen(ChatifyUser user) =>
      _SingleUserLastSeen(
        chatController: widget.chatController,
        user: user,
      );

  @override
  void initState() {
    activeUserCount = Rx.combineLatest(
      widget.users.withoutMeOrMe.map(
        (e) => Chatify.datasource.getUserLastSeen(
          e.id,
          widget.chatController.chat.id,
        ),
      ),
      (List<UserLastSeen> users) {
        return users.where((e) => e.isActive).length;
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return KrStreamBuilder<int>(
      stream: activeUserCount,
      onLoading: SizedBox.shrink(),
      builder: (activeUsers) {
        return KrExpandedSection(
          expand: true,
          child: Column(
            key: ValueKey('none_user_status'),
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '${widget.users.length} Members',
                    style: TextStyle(
                      color: Chatify.theme.chatForegroundColor.withOpacity(
                        0.5,
                      ),
                      fontSize: 11,
                      height: 1,
                    ),
                  ),
                  if (activeUsers != 0)
                    Text(
                      ', $activeUsers Online',
                      style: TextStyle(
                        color: Chatify.theme.chatForegroundColor.withOpacity(
                          0.5,
                        ),
                        fontSize: 11,
                        height: 1,
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

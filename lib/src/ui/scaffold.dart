import 'package:chatify/src/core/chatify.dart';
import 'package:chatify/src/theme/theme_widget.dart';
import 'package:chatify/src/ui/chats/new_chat/new_chat.dart';
import 'package:chatify/src/ui/chats/search.dart';
import 'package:chatify/src/utils/context_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'chats/recent_chats.dart';

class ChatScreen extends StatelessWidget {
  ChatScreen({Key? key})
      : assert(
          Chatify.isInititialized,
          'initialize the chat options. use init method in the main entry.',
        ),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = ChatifyTheme.of(context);
    print(theme.isRecentChatsDark);
    return Scaffold(
      key: ContextProvider.recentChatsKey,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: theme.isRecentChatsDark
            ? SystemUiOverlayStyle.light.copyWith(
                systemNavigationBarDividerColor: Colors.black,
                systemNavigationBarColor: Colors.black,
                systemNavigationBarIconBrightness: Brightness.light,
              )
            : SystemUiOverlayStyle.dark.copyWith(
                systemNavigationBarDividerColor: Colors.white,
                systemNavigationBarColor: Colors.white,
                systemNavigationBarIconBrightness: Brightness.dark,
              ),
        title: Text(
          'Messages',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: theme.recentChatsForegroundColor,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          padding: EdgeInsets.all(14),
          icon: Icon(
            CupertinoIcons.back,
            color: theme.recentChatsForegroundColor,
            opticalSize: 1,
          ),
        ),
        centerTitle: true,
        actionsIconTheme: IconThemeData(
          color: theme.recentChatsForegroundColor,
          size: 24,
        ),
        actions: [
          if (Chatify.config.canCreateNewChat)
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NewChat(),
                  ),
                );
              },
              padding: const EdgeInsets.all(14),
              icon: Icon(
                Iconsax.message_add_1,
                size: 24,
                color: theme.recentChatsForegroundColor,
              ),
            ),
          const SizedBox(
            width: 12,
          ),
        ],
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: const Padding(
        padding: EdgeInsetsDirectional.only(top: 10),
        child: Column(
          children: [
            ChatSearch(),
            Expanded(child: RecentChats()),
          ],
        ),
      ),
    );
  }
}

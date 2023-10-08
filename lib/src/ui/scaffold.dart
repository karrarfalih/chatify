import 'package:chatify/src/core/chatify.dart';
import 'package:chatify/src/theme/theme_widget.dart';
import 'package:chatify/src/ui/chats/new_chat/new_message.dart';
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
    return Scaffold(
      key: ContextProvider.recentChatsKey,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        title: Text(
          'Messages',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: ChatifyTheme.of(context).recentChatsBackgroundColor,
          ),
        ),
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: const Icon(
              CupertinoIcons.back,
              color: Colors.black,
              opticalSize: 1,
            ),
          ),
        ),
        centerTitle: true,
        actionsIconTheme: IconThemeData(
          color: ChatifyTheme.of(context).recentChatsBackgroundColor,
          size: 24,
        ),
        actions: [
          if (Chatify.config.canCreateNewChat)
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NewMessages(),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Icon(
                  Iconsax.message_add_1,
                  size: 24,
                  color: ChatifyTheme.of(context).recentChatsBackgroundColor,
                ),
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

import 'package:chatify/src/core/chatify.dart';
import 'package:chatify/src/localization/get_string.dart';
import 'package:chatify/src/ui/chat_view/body/voice_palyer.dart';
import 'package:chatify/src/ui/chat_view/controllers/pending_messages.dart';
import 'package:chatify/src/ui/chats/connectivity.dart';
import 'package:chatify/src/ui/chats/new_chat/new_chat.dart';
import 'package:chatify/src/ui/chats/search.dart';
import 'package:chatify/src/ui/common/circular_loading.dart';
import 'package:chatify/src/ui/common/kr_stream_builder.dart';
import 'package:chatify/src/utils/context_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'chats/recent_chats.dart';

class ChatScreen extends StatefulWidget {
  ChatScreen({
    Key? key,
    this.leading,
    this.title,
    this.isCenter = true,
    this.actionButton,
  })  : assert(
          Chatify.isInititialized,
          'initialize the chat options. use init method in the main entry.',
        ),
        super(key: key);

  final Widget? leading;
  final Widget? actionButton;
  final String? title;
  final bool isCenter;

  @override
  State<ChatScreen> createState() => _ChatScreenState();

  static Map<String, PendingMessagesHandler> pendingMessagesHandlers = {};
}

class _ChatScreenState extends State<ChatScreen>
    with SingleTickerProviderStateMixin {
  final connectivity = ChatifyConnectivity();

  @override
  void dispose() {
    connectivity.dispose();
    ChatScreen.pendingMessagesHandlers.forEach((key, value) {
      value.dispose();
    });
    ChatScreen.pendingMessagesHandlers.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Chatify.theme;
    return Scaffold(
      key: ContextProvider.recentChatsKey,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 0,
        leading: widget.leading,
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
        titleSpacing: 0,
        title: KrStreamBuilder<ConnectivityStatus>(
          stream: connectivity.connection,
          onLoading: SizedBox.shrink(),
          builder: (connectionStatus) {
            if (connectionStatus == ConnectivityStatus.waiting) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LoadingWidget(
                    size: 14,
                    lineWidth: 1,
                    color: Chatify.theme.recentChatsForegroundColor.withOpacity(
                      0.5,
                    ),
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Text(
                    localization(context).waitingConnection,
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.recentChatsForegroundColor,
                    ),
                  ),
                ],
              );
            } else if (connectionStatus == ConnectivityStatus.connecting)
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LoadingWidget(
                    size: 10,
                    lineWidth: 1,
                    color: Chatify.theme.recentChatsForegroundColor.withOpacity(
                      0.5,
                    ),
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Text(
                    localization(context).connecting,
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.recentChatsForegroundColor,
                    ),
                  ),
                ],
              );
            return Text(
              widget.title ?? localization(context).messeges,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: theme.recentChatsForegroundColor,
              ),
            );
          },
        ),
        centerTitle: widget.isCenter,
        actionsIconTheme: IconThemeData(
          color: theme.recentChatsForegroundColor,
          size: 24,
        ),
        actions: [
          if (Chatify.config.canCreateNewChat)
            widget.actionButton ??
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
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 5),
            child: CurrentVoicePlayer(),
          ),
          ChatSearch(),
          Expanded(
            child: RecentChats(
              connectivity: connectivity,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:chatify/src/domain/models/chat.dart';
import 'package:chatify/src/view/chats/view/card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:chatify/src/view/chats/bloc/bloc.dart';
import 'package:chatify/src/view/chat/view/chat.dart';
import 'package:chatify/src/view/common/paginated_builder.dart';

class ChatsLayout {
  final Widget Function(BuildContext context, Widget body)? bodyBuilder;
  final Widget Function(BuildContext context, Chat chat)? chatBuilder;

  ChatsLayout({
    this.bodyBuilder,
    this.chatBuilder,
  });
}

class ChatLayout {
  final Widget Function(BuildContext context, Widget body, Chat chat)?
      bodyBuilder;

  ChatLayout({
    this.bodyBuilder,
  });
}

class ChatsPage extends StatelessWidget {
  const ChatsPage({
    super.key,
    required this.userId,
    this.backgroundBuilder,
    this.chatsLayout,
    this.chatConfig,
  });

  final String userId;
  final Widget Function(BuildContext context, Widget child)? backgroundBuilder;
  final ChatsLayout? chatsLayout;
  final ChatLayout? chatConfig;

  @override
  Widget build(BuildContext context) {
    final child = Directionality(
      textDirection: TextDirection.ltr,
      child: BlocProvider(
        create: (context) => ChatsBloc(userId: userId),
        child: Navigator(
          onGenerateRoute: (settings) {
            if (settings.name == '/chat') {
              final args = settings.arguments as Map<String, dynamic>;
              return MaterialPageRoute(
                builder: (context) => MessagesPage(
                  chat: args['chat'],
                  layout: chatConfig,
                ),
              );
            }
            return MaterialPageRoute(
              builder: (context) => _ChatsListPage(
                userId: userId,
                layout: chatsLayout,
              ),
            );
          },
          initialRoute: '/',
        ),
      ),
    );
    if (backgroundBuilder != null) {
      return backgroundBuilder!(context, child);
    }
    return child;
  }
}

class _ChatsListPage extends StatelessWidget {
  const _ChatsListPage({
    required this.userId,
    this.layout,
  });

  final String userId;
  final ChatsLayout? layout;

  @override
  Widget build(BuildContext context) {
    if (layout != null) {
      return layout!.bodyBuilder!(
          context,
          _ChatsBuilder(
            userId: userId,
            chatBuilder: layout!.chatBuilder,
          ));
    }
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child:
                Text('Chat', style: Theme.of(context).textTheme.headlineMedium),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: _ChatsBuilder(userId: userId),
          ),
        ],
      ),
    );
  }
}

class _ChatsBuilder extends StatelessWidget {
  const _ChatsBuilder({
    required this.userId,
    this.chatBuilder,
  });

  final String userId;
  final Widget Function(BuildContext context, Chat chat)? chatBuilder;

  @override
  Widget build(BuildContext context) {
    return PaginatedResultBuilder<ChatsBloc, ChatsState, Chat>(
      selector: (state) => state.chats,
      onEmpty: EmptyResultBuilder(
        title: 'No chats'.tr,
        description: 'You don\'t have any chats yet'.tr,
      ),
      onFetch: (context, isRefresh) {
        if (!isRefresh) {
          context.read<ChatsBloc>().add(ChatsLoadMore());
        }
      },
      builder: (context, chats, index) {
        return ChatCard(chats[index], builder: chatBuilder);
      },
    );
  }
}

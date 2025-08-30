import 'package:chatify/src/core/addons.dart';
import 'package:chatify/src/core/addons_registry.dart';
import 'package:chatify/src/domain/models/chat.dart';
import 'package:chatify/src/view/chat/bloc/bloc.dart';
import 'package:chatify/src/view/chat/view/input/input.dart';
import 'package:chatify/src/view/chat/view/messages.dart';
import 'package:chatify/src/view/chat/view/status.dart';
import 'package:chatify/src/view/chats/view/chats.dart';
import 'package:chatify/src/view/common/icon_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MessagesPage extends StatelessWidget {
  const MessagesPage({
    super.key,
    required this.chat,
    this.layout,
  });

  final Chat chat;
  final ChatLayout? layout;

  static showWithNavigator({
    required BuildContext context,
    required Chat chat,
  }) {
    Navigator.of(context).pushNamed(
      '/chat',
      arguments: {'chat': chat},
    );
  }

  @override
  Widget build(BuildContext context) {
    return _Wrapper(
      chat: chat,
      children: ChatAddonsRegistry.instance.chatAddons
          .map((a) => a.wrapChat)
          .toList(),
      child: BlocProvider(
        create: (context) => MessagesBloc(chat: chat),
        child: Builder(builder: (context) {
          final body = Column(
            children: [
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    CustomIconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: Icons.arrow_back,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        chat.receiver.name,
                        style: Theme.of(context).textTheme.headlineMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ..._buildHeaders(context),
              const Expanded(child: ChatMessages()),
              const ChatStatusWidget(),
              ChatAddonsRegistry.instance.chatAddons.fold<Widget>(
                const ChatInputBox(),
                (w, a) => a.wrapInputBox(context, chat, w),
              ),
            ],
          );
          if (layout != null && layout!.bodyBuilder != null) {
            return layout!.bodyBuilder!(context, body, chat);
          }
          return body;
        }),
      ),
    );
  }

  List<Widget> _buildHeaders(BuildContext context) {
    final list = ChatAddonsRegistry.instance.chatAddons
        .expand((a) => a.buildHeaders(context, chat))
        .where((h) => h.isVisible(context))
        .toList();
    int layerOrder(Layer l) => switch (l) {
          Layer.modal => 0,
          Layer.elevated => 1,
          Layer.normal => 2,
        };
    list.sort((a, b) {
      final l = layerOrder(a.layer).compareTo(layerOrder(b.layer));
      if (l != 0) return l;
      final p = a.priority.compareTo(b.priority);
      if (p != 0) return p;
      return a.id.compareTo(b.id);
    });
    return list
        .map(
            (h) => KeyedSubtree(key: ValueKey(h.id), child: h.builder(context)))
        .toList();
  }
}

class _Wrapper extends StatelessWidget {
  const _Wrapper({
    required this.child,
    required this.children,
    required this.chat,
  });

  final Widget child;
  final List<Widget Function(BuildContext c, Chat chat, Widget child)> children;
  final Chat chat;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) {
      return child;
    }
    Widget result = child;
    for (final child in children) {
      result = child(context, chat, result);
    }
    return result;
  }
}

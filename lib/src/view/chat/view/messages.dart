import 'dart:async';
import 'package:flutter/material.dart';
import 'package:diffutil_dart/diffutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:universal_html/html.dart' hide Animation;
import 'package:chatify/src/domain/models/messages/message.dart';
import 'package:chatify/src/view/chat/bloc/bloc.dart';
import 'package:chatify/src/view/chat/view/message/message.dart';
import 'package:chatify/src/view/chat/view/message/selection/listener.dart';
import 'package:chatify/src/view/chat/view/message/widgets/chat_date.dart';
import 'package:chatify/src/view/common/paginated_builder.dart';

class ChatMessages extends StatefulWidget {
  const ChatMessages({super.key});

  @override
  State<ChatMessages> createState() => _ChatMessagesState();
}

class _ChatMessagesState extends State<ChatMessages> {
  final scrollController = ScrollController();

  StreamSubscription<MouseEvent>? _contextMenuSubscription;

  @override
  void initState() {
    _contextMenuSubscription =
        document.onContextMenu.listen((event) => event.preventDefault());
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 100) {
        context.read<MessagesBloc>().add(MessagesLoadMore());
      }
    });
    context.read<MessagesBloc>().add(MessagesLoadMore());
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    _contextMenuSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MessagesSelectionListener(
      child: BlocBuilder<MessagesBloc, MessagesState>(
        buildWhen: (previous, current) =>
            previous.pendingMessages != current.pendingMessages ||
            previous.failedMessages != current.failedMessages ||
            previous.messages != current.messages,
        builder: (context, data) {
          final receivedMessages = data.messages;
          final pendingMessages = data.pendingMessages;
          final failedMessages = data.failedMessages;
          if (receivedMessages.isInitialLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (receivedMessages.hasError) {
            return ErrorResultBuilder(
              error: receivedMessages.error ?? 'Something went wrong',
            );
          }
          final otherMessages = [
            ...failedMessages,
            ...pendingMessages,
          ];
          otherMessages.sort((a, b) => a.sentAt.compareTo(b.sentAt));
          final messages = [
            ...otherMessages,
            ...receivedMessages.items,
          ];
          if (messages.isEmpty) {
            return EmptyResultBuilder(
              title: 'No messages'.tr,
              description: 'Start a conversation'.tr,
            );
          }
          return CustomScrollView(
            reverse: true,
            shrinkWrap: true,
            controller: scrollController,
            slivers: [
              SliverPadding(
                padding: const EdgeInsetsGeometry.only(bottom: 4, top: 120),
                sliver: _AnimatedMessagesList(
                  messages: messages,
                  scrollController: scrollController,
                  builder: (index, msg) {
                    final message = msg ?? messages[index];
                    final nextMessage =
                        index == 0 ? null : messages.elementAtOrNull(index - 1);
                    final previousMessage = messages.elementAtOrNull(index + 1);
                    final date = message.sentAt;
                    final prevDate = previousMessage?.sentAt;
                    final showTime = prevDate == null ||
                        date.day != prevDate.day ||
                        date.month != prevDate.month ||
                        date.year != prevDate.year;
                    return Column(
                      key: ValueKey(message.content.id),
                      crossAxisAlignment: message.isMine
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        if (showTime) NewDataMessage(date: message.sentAt),
                        MessageWidget(
                          index: index,
                          message: message,
                          isLast: nextMessage?.isMine != message.isMine,
                          isFirst: previousMessage?.isMine != message.isMine,
                          isPending: pendingMessages.contains(message),
                          isFailed: failedMessages.contains(message),
                        ),
                      ],
                    );
                  },
                ),
              )
            ],
          );
        },
      ),
    );
  }
}

class _AnimatedMessagesList<T> extends StatefulWidget {
  const _AnimatedMessagesList({
    required this.messages,
    required this.scrollController,
    required this.builder,
  });

  final List<Message> messages;
  final ScrollController scrollController;
  final Widget Function(int index, Message? message) builder;

  @override
  State<_AnimatedMessagesList> createState() => _AnimatedMessagesListState();
}

class _AnimatedMessagesListState extends State<_AnimatedMessagesList> {
  final _listKey = GlobalKey<SliverAnimatedListState>();

  final date = DateTime.now();

  @override
  void initState() {
    super.initState();
    _calculateDiffs(widget.messages);
  }

  @override
  void didUpdateWidget(covariant _AnimatedMessagesList oldWidget) {
    super.didUpdateWidget(oldWidget);

    _calculateDiffs(oldWidget.messages);
  }

  void _calculateDiffs(List<Message> oldList) async {
    final diffResult = calculateListDiff<Message>(
      oldList,
      widget.messages,
      equalityChecker: (item1, item2) {
        return item1.content.id == item2.content.id;
      },
    );

    for (final update in diffResult.getUpdates(batch: false)) {
      update.when(
        insert: (pos, count) {
          _listKey.currentState
              ?.insertItem(pos, duration: const Duration(milliseconds: 600));
        },
        remove: (pos, count) {
          final item = oldList[pos];
          _listKey.currentState?.removeItem(
            pos,
            (_, animation) => _removedMessageBuilder(item, pos, animation),
            duration: const Duration(milliseconds: 600),
          );
        },
        change: (pos, payload) {},
        move: (from, to) {},
      );
    }

    _scrollToBottomIfNeeded(oldList);
  }

  void _scrollToBottomIfNeeded(List<Message> oldList) {
    try {
      final oldMessage = oldList[0];
      final message = widget.messages[0];
      if (oldMessage.content.id != message.content.id) {
        if (message.isMine) {
          Future.delayed(const Duration(milliseconds: 100), () {
            if (widget.scrollController.hasClients) {
              widget.scrollController.animateTo(
                0,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInQuad,
              );
            }
          });
        }
      }
    } catch (_) {}
  }

  Widget _newMessageBuilder(int i, Animation<double> animation) {
    try {
      final msg = widget.messages.elementAt(i);
      if (msg.sentAt.isBefore(date)) {
        return widget.builder(i, null);
      }
      final a = animation.drive(CurveTween(curve: Curves.easeOutQuad));
      return SlideTransition(
        key: ValueKey(msg.content.id),
        position: Tween<Offset>(
          begin: Offset(0.2 * (msg.isMine ? 1 : -1), 0),
          end: const Offset(0, 0),
        ).animate(a),
        child: SizeTransition(
          axisAlignment: -1,
          sizeFactor: a,
          child: widget.builder(i, null),
        ),
      );
    } catch (e) {
      return const SizedBox();
    }
  }

  Widget _removedMessageBuilder(
    Message item,
    int i,
    Animation<double> animation,
  ) {
    return SizeTransition(
      axisAlignment: -1,
      sizeFactor: animation.drive(CurveTween(curve: Curves.easeInQuad)),
      child: FadeTransition(
        opacity: animation.drive(CurveTween(curve: Curves.easeInQuad)),
        child: widget.builder(i, item),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SliverAnimatedList(
      findChildIndexCallback: (Key key) {
        if (key is ValueKey<Object>) {
          final newIndex = widget.messages.indexWhere(
            (v) => v.content.id == key.value,
          );
          if (newIndex != -1) {
            return newIndex;
          }
        }
        return null;
      },
      initialItemCount: widget.messages.length,
      key: _listKey,
      itemBuilder: (_, index, animation) {
        return _newMessageBuilder(index, animation);
      },
    );
  }
}

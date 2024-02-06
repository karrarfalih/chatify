import 'package:chatify/src/core/chatify.dart';
import 'package:chatify/src/localization/get_string.dart';
import 'package:chatify/src/models/models.dart';
import 'package:chatify/src/ui/chat_view/controllers/chat_controller.dart';
import 'package:chatify/src/ui/common/circular_loading.dart';
import 'package:chatify/src/ui/common/media_query.dart';
import 'package:chatify/src/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:chatify/src/ui/chat_view/body/date.dart';
import 'package:chatify/src/ui/chat_view/message/message_card.dart';
import 'package:flutter/rendering.dart';
import 'package:diffutil_dart/diffutil.dart';
import 'package:get/get.dart';

class ChatMessages extends StatefulWidget {
  const ChatMessages({
    super.key,
    required this.chat,
    required this.users,
    required this.controller,
    required this.messages,
    required this.scrollController,
  });

  final Chat chat;
  final List<ChatifyUser> users;
  final ChatController controller;
  final List<Message> messages;
  final ScrollController scrollController;

  @override
  State<ChatMessages> createState() => _ChatMessagesState();
}

class _ChatMessagesState extends State<ChatMessages>
    with WidgetsBindingObserver {
  bool canSeeMessages = true;

  final _listKey = GlobalKey<SliverAnimatedListState>();
  late List<Message> _oldData = List.from(widget.messages);

  @override
  void initState() {
    Chatify.currentOpenedChat = widget.chat.id;
    super.initState();
    didUpdateWidget(widget);
  }

  @override
  void didUpdateWidget(covariant ChatMessages oldWidget) {
    super.didUpdateWidget(oldWidget);

    _calculateDiffs(oldWidget.messages);
  }

  @override
  void dispose() {
    Chatify.currentOpenedChat = null;
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      Chatify.currentOpenedChat = widget.chat.id;
      Chatify.datasource.markAllMessagesAsSeen(widget.chat.id);
    } else {
      Chatify.currentOpenedChat = null;
      canSeeMessages = false;
    }
  }

  void _calculateDiffs(List<Message> oldList) async {
    final diffResult = calculateListDiff<Message>(
      oldList,
      widget.messages,
      equalityChecker: (item1, item2) {
        return item1.id == item2.id;
      },
    );

    for (final update in diffResult.getUpdates(batch: false)) {
      update.when(
        insert: (pos, count) {
          _listKey.currentState?.insertItem(pos);
        },
        remove: (pos, count) {
          final item = oldList[pos];
          _listKey.currentState?.removeItem(
            pos,
            (_, animation) => _removedMessageBuilder(item, pos, animation),
          );
        },
        change: (pos, payload) {},
        move: (from, to) {},
      );
    }

    _scrollToBottomIfNeeded(oldList);

    _oldData = List.from(widget.messages);
  }

  void _scrollToBottomIfNeeded(List<Message> oldList) {
    try {
      // Take index 1 because there is always a spacer on index 0.
      final oldMessage = oldList[0];
      final message = widget.messages[0];

      // Compare items to fire only on newly added messages.
      if (oldMessage.id != message.id) {
        // Run only for sent message.
        if (message.sender == Chatify.currentUserId) {
          // Delay to give some time for Flutter to calculate new
          // size after new message was added.
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
    } catch (e) {
      // Do nothing if there are no items.
    }
  }

  Widget _newMessageBuilder(int i, Animation<double> animation) {
    try {
      Message msg = widget.messages.elementAt(i);
      if (canSeeMessages) Chatify.datasource.markAsSeen(msg);
      return SizeTransition(
        key: ValueKey(msg.id),
        axisAlignment: -1,
        sizeFactor: msg.isMine
            ? AlwaysStoppedAnimation(1.0)
            : animation.drive(CurveTween(curve: Curves.easeOutQuad)),
        child: SelectableMessage(
          key: ValueKey('selectable message $i ${msg.id}'),
          index: i,
          message: msg,
          child: _MessageBuilder(
            chat: widget.chat,
            controller: widget.controller,
            messages: widget.messages,
            index: i,
          ),
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
      key: ValueKey(item),
      axisAlignment: -1,
      sizeFactor: animation.drive(CurveTween(curve: Curves.easeInQuad)),
      child: FadeTransition(
        opacity: item.isMine
            ? AlwaysStoppedAnimation(1.0)
            : animation.drive(CurveTween(curve: Curves.easeInQuad)),
        child: _MessageBuilder(
          chat: widget.chat,
          controller: widget.controller,
          messages: _oldData,
          index: i,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.only(
        bottom: 5,
        top: 200,
      ),
      sliver: SliverAnimatedList(
        findChildIndexCallback: (Key key) {
          if (key is ValueKey<Object>) {
            final newIndex = widget.messages.indexWhere(
              (v) => v.id == key.value,
            );
            if (newIndex != -1) {
              return newIndex;
            }
          }
          return null;
        },
        initialItemCount: widget.messages.length + 1,
        key: _listKey,
        itemBuilder: (_, index, animation) {
          if (index == 0) {
            return Obx(() {
              if (widget.controller.messagesController.isLoaded.value &&
                  widget.controller.messagesController.messages.isEmpty) {
                return Container(
                  height: mediaQuery(context).size.height,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 50.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            localization(context).sayHi,
                            style: TextStyle(
                              color: Chatify.theme.chatForegroundColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
              if (!widget.controller.messagesController.isLoaded.value)
                return Container(
                  height: mediaQuery(context).size.height,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 50.0),
                      child: Center(child: LoadingWidget()),
                    ),
                  ),
                );
              return _newMessageBuilder(index, animation);
            });
          }
          if (index == widget.messages.length)
            return Obx(
              () => Visibility(
                visible: widget.controller.messagesController.isNextPageLoading
                        .value ||
                    !widget.controller.messagesController.isLoaded.value,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Center(child: LoadingWidget()),
                ),
              ),
            );
          return _newMessageBuilder(index, animation);
        },
      ),
    );
  }
}

class _MessageBuilder extends StatelessWidget {
  const _MessageBuilder({
    required this.chat,
    required this.controller,
    required this.messages,
    required this.index,
  });

  final Chat chat;
  final ChatController controller;
  final List<Message> messages;
  final int index;

  @override
  Widget build(BuildContext context) {
    if (index >= messages.length) return const SizedBox();
    final msg = messages[index];
    final nextMsg = index == 0 ? null : messages[index - 1];
    final prevMsg = index == messages.length - 1 ? null : messages[index + 1];
    final date = msg.sendAt ?? DateTime.now();
    final prevDate = prevMsg?.sendAt;
    final showTime = prevDate == null || !date.isSameDay(prevDate);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (showTime)
          Center(
            key: ValueKey(msg.sendAt),
            child: ChatDateWidget(date: date),
          ),
        MessageCard(
          key: ValueKey(msg.id),
          chat: chat,
          message: msg,
          users: controller.users,
          controller: controller,
          isSending: msg.isPending,
          linkedWithBottom: (nextMsg != null &&
              nextMsg.sender == msg.sender &&
              nextMsg.sendAt?.day == msg.sendAt?.day),
          linkedWithTop:
              !showTime && prevMsg != null && prevMsg.sender == msg.sender,
        ),
      ],
    );
  }
}

class SelectableMessage extends SingleChildRenderObjectWidget {
  final int index;
  final Message message;

  SelectableMessage({
    required Widget child,
    required this.index,
    required this.message,
    Key? key,
  }) : super(child: child, key: key);

  @override
  SelectedMessage createRenderObject(BuildContext context) {
    return SelectedMessage(index, message);
  }

  @override
  void updateRenderObject(BuildContext context, SelectedMessage renderObject) {
    renderObject..index = index;
  }
}

class SelectedMessage extends RenderProxyBox {
  int index;
  Message message;

  SelectedMessage(this.index, this.message);
}

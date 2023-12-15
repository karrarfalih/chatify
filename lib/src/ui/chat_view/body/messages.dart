import 'package:chatify/src/core/chatify.dart';
import 'package:chatify/src/models/models.dart';
import 'package:chatify/src/ui/chat_view/controllers/chat_controller.dart';
import 'package:chatify/src/ui/chat_view/input_status.dart';
import 'package:chatify/src/ui/common/paginate_firestore/paginate_firestore.dart';
import 'package:flutter/material.dart';
import 'package:chatify/src/ui/chat_view/body/date.dart';
import 'package:chatify/src/ui/chat_view/message/message_card.dart';
import 'package:flutter/rendering.dart';

class ChatMessages extends StatefulWidget {
  const ChatMessages({
    super.key,
    required this.chat,
    required this.users,
    required this.controller,
  });

  final Chat chat;
  final List<ChatifyUser> users;
  final ChatController controller;

  @override
  State<ChatMessages> createState() => _ChatMessagesState();
}

class _ChatMessagesState extends State<ChatMessages> {
  Map<String, Message> get initialSelecetdMessages =>
      widget.controller.initialSelecetdMessages;

  set initialSelecetdMessages(Map<String, Message> value) =>
      widget.controller.initialSelecetdMessages = value;

  Map<int, Message> addedMessages = {};
  Offset offset = Offset.zero;
  bool isRemove = false;

  _detectTapedItem(PointerEvent event) {
    if (!widget.controller.isSelecting.value) return;
    final RenderBox box =
        key.currentContext!.findAncestorRenderObjectOfType<RenderBox>()!;
    final result = BoxHitTestResult();
    Offset local = box.globalToLocal(event.position);
    if (box.hitTest(result, position: local)) {
      for (final hit in result.path) {
        final target = hit.target;
        if (target is SelectedMessage) {
          final initialList =
              Map.from(widget.controller.selecetdMessages.value);
          final selectedMessages = widget.controller.selecetdMessages.value;
          bool isScrollUp = offset.dy > local.dy;
          addedMessages.putIfAbsent(target.index, () => target.message);
          addedMessages.removeWhere(
            (key, value) =>
                isScrollUp ? key > target.index : key < target.index,
          );
          if (isRemove) {
            selectedMessages.addAll(initialSelecetdMessages);
            selectedMessages.removeWhere(
              (key, value) => addedMessages.containsValue(value),
            );
          } else {
            selectedMessages.clear();
            selectedMessages.addAll(
              addedMessages.map((key, value) => MapEntry(value.id, value)),
            );
            selectedMessages.addAll(initialSelecetdMessages);
          }
          if (initialList.length != selectedMessages.length) {
            widget.controller.selecetdMessages.refresh();
          }
        }
      }
    }
  }

  _detectStart(PointerEvent event) {
    addedMessages.clear();
    final RenderBox box =
        key.currentContext!.findAncestorRenderObjectOfType<RenderBox>()!;
    offset = box.globalToLocal(event.position);
    final result = BoxHitTestResult();
    if (box.hitTest(result, position: offset)) {
      for (final hit in result.path) {
        final target = hit.target;
        if (target is SelectedMessage) {
          isRemove = initialSelecetdMessages.containsKey(target.message.id);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (x) {
        widget.controller.preventEmoji = true;
        return false;
      },
      child: ValueListenableBuilder<bool>(
        valueListenable: widget.controller.isSelecting,
        builder: (context, isSelecting, child) {
          return Listener(
            onPointerMove: _detectTapedItem,
            onPointerDown: _detectStart,
            child: KrPaginateFirestore(
              key: key,
              physics: isSelecting
                  ? const NeverScrollableScrollPhysics()
                  : const BouncingScrollPhysics(),
              itemBuilder: (context, docs, i) {
                Message msg = docs.elementAt(i).data() as Message;
                if (msg.unSeenBy.contains(Chatify.currentUserId)) {
                  Chatify.datasource.markAsSeen(msg.id);
                }
                Message? prevMsg;
                Message? nextMsg;
                if (docs.length != i + 1) {
                  prevMsg = docs.elementAt(i + 1).data() as Message;
                }
                if (i != 0) {
                  nextMsg = docs.elementAt(i - 1).data() as Message;
                }
                DateTime? date = msg.sendAt;
                DateTime? prevDate = prevMsg?.sendAt;
                bool showTime = false;
                if (date != null) {
                  DateTime d = DateTime(date.year, date.month, date.day);
                  DateTime prevD = prevDate == null
                      ? DateTime(19000)
                      : DateTime(
                          prevDate.year,
                          prevDate.month,
                          prevDate.day,
                        );
                  showTime = d.toString() != prevD.toString();
                }
                widget.controller.pending.removeById(msg.id);
                return SelectableMessage(
                  key: ValueKey('selectable message $i ${msg.id}'),
                  index: i,
                  message: msg,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (i == docs.length - 1)
                        SizedBox(
                          key: ValueKey('chat padding bottom'),
                          height: MediaQuery.of(context).padding.top + 70,
                        ),
                      if (showTime)
                        Center(
                          key: ValueKey(msg.sendAt),
                          child: ChatDateWidget(
                            date: date ?? DateTime.now(),
                          ),
                        ),
                      if (i != 0)
                        MessageCard(
                          key: ValueKey(msg.id),
                          chat: widget.chat,
                          message: msg,
                          users: widget.users,
                          controller: widget.controller,
                          linkedWithBottom: (nextMsg != null &&
                              nextMsg.sender == msg.sender &&
                              nextMsg.sendAt?.day == msg.sendAt?.day),
                          linkedWithTop: !showTime &&
                              prevMsg != null &&
                              prevMsg.sender == msg.sender,
                        )
                      else
                        ValueListenableBuilder<List<Message>>(
                          valueListenable: widget.controller.pending.messages,
                          builder: (context, value, cild) => MessageCard(
                            key: ValueKey(msg.id),
                            chat: widget.chat,
                            message: msg,
                            users: widget.users,
                            controller: widget.controller,
                            linkedWithBottom: (nextMsg?.sender == msg.sender &&
                                    nextMsg?.sendAt?.day == msg.sendAt?.day) ||
                                (msg.isMine && value.isNotEmpty),
                            linkedWithTop: !showTime &&
                                prevMsg != null &&
                                prevMsg.sender == msg.sender,
                          ),
                        ),
                      if (i == 0)
                        PendingMessages(
                          key: ValueKey('pending messages'),
                          controller: widget.controller,
                          chat: widget.chat,
                          firstMessage: msg,
                          user: widget.users.firstWhere(
                            (e) => e.id == msg.sender,
                          ),
                        ),
                    ],
                  ),
                );
              },
              query: Chatify.datasource.messagesQuery(widget.chat),
              onEmpty: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Say Hi',
                      style: TextStyle(
                        color: Chatify.theme.chatForegroundColor,
                      ),
                    ),
                  ],
                ),
              ),
              header: SliverToBoxAdapter(
                child: Column(
                  children: [
                    UsersInputStatus(
                      chatId: widget.chat.id,
                      users: widget.users,
                    ),
                    SizedBox(
                      height: 5,
                    ),
                  ],
                ),
              ),
              itemBuilderType: PaginateBuilderType.listView,
              initialLoader: ListView(
                children: [],
              ),
              reverse: true,
              isLive: true,
            ),
          );
        },
      ),
    );
  }
}

class PendingMessages extends StatelessWidget {
  const PendingMessages({
    super.key,
    required this.controller,
    required this.chat,
    required this.user,
    required this.firstMessage,
  });

  final ChatController controller;
  final Chat chat;
  final ChatifyUser user;
  final Message firstMessage;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Message>>(
      valueListenable: controller.pending.messages,
      builder: (context, value, cild) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...value.map(
                (e) => MessageCard(
                  key: ValueKey(e.id),
                  chat: chat,
                  message: e,
                  users: [user],
                  controller: controller,
                  linkedWithBottom: value.indexOf(e) != value.length - 1,
                  linkedWithTop: firstMessage.isMine,
                  isSending: true,
                ),
              ),
            ],
          ),
        );
      },
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

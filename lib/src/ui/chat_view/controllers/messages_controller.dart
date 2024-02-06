import 'dart:async';

import 'package:chatify/chatify.dart';
import 'package:chatify/src/ui/chat_view/controllers/pending_messages.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class MessagesController {
  final Chat chat;
  final PendingMessagesHandler pending;

  MessagesController(this.chat, this.pending) {
    loadMessages();
  }

  final remoteMessages = RxList<Message>([]);

  List<Message> get messages {
    return [
      ...pending.messages.value,
      ...remoteMessages,
    ];
  }

  final isNextPageLoading = false.obs;
  final isLoaded = false.obs;

  StreamSubscription? _subscription;

  int _lastMessageCount = 0;
  final int _messageCount = 20;
  bool reachedEnd = false;

  late final query = Chatify.datasource.messagesQuery(chat);

  loadMessages() async {
    _subscription?.cancel();
    final stream = query.limit(_messageCount).snapshots();
    _subscription = stream.listen(addMessages);
    await stream.first;
    isLoaded.value = true;
  }

  loadNextPage() async {
    if (isNextPageLoading.value ||
        !isLoaded.value ||
        remoteMessages.isEmpty ||
        reachedEnd) return;
    isNextPageLoading.value = true;
    _subscription?.cancel();
    final oldLength = remoteMessages.length;
    final stream = query.limit(_messageCount + _lastMessageCount).snapshots();
    _subscription = stream.listen(addMessages);
    await stream.first;
    if (oldLength == remoteMessages.length) {
      reachedEnd = true;
    }
    isNextPageLoading.value = false;
  }

  void addMessages(QuerySnapshot<Message> e) {
    final newMessages = e.docs.map((e) => e.data()).toList();
    pending.removeList(newMessages);
    remoteMessages.value = newMessages;
    _lastMessageCount = e.docs.length;
    reachedEnd = false;
  }

  dispose() {
    remoteMessages.close();
    _subscription?.cancel();
    isNextPageLoading.close();
    isLoaded.close();
  }
}

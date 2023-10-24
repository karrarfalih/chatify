import 'dart:convert';

import 'package:chatify/src/models/models.dart';
import 'package:chatify/src/utils/cache.dart';
import 'package:chatify/src/utils/value_notifiers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PendingMessagesHandler {
  PendingMessagesHandler({
    required Chat chat,
  }) : _chat = chat {
    messages = Rx<List<Message>>(
      _PendingMessagesCache[_chat.id] ?? _loadFromCache(),
    );
  }

  final Chat _chat;

  late final Rx<List<Message>> messages;

  static final _PendingMessagesCache = <String, List<Message>>{};

  add(Message message) {
    messages
      ..value.add(message)
      ..refresh();
    _updateCache();
  }

  remove(Message message) {
    messages
      ..value.remove(message)
      ..refresh();
    _updateCache();
  }

  removeById(String id) {
    messages
      ..value.removeWhere((element) => element.id == id)
      ..refresh();
    _updateCache();
  }

  _updateCache() {
    Cache.instance.setString(
      'pendingMessages',
      jsonEncode(
        {
          _chat.id: messages.value.whereType<TextMessage>().map((e) {
            final json = e.toJson
              ..removeWhere((key, value) => value is Timestamp || value is FieldValue);
            return json;
          }).toList(),
        },
      ),
    );
  }

  List<Message> _loadFromCache() {
    final cache = Cache.instance.getString('pendingMessages');
    if (cache == null) return [];
    final json = jsonDecode(cache);
    if (json[_chat.id] == null) return [];
    final msgs = json[_chat.id] as List;
    return msgs.map((e) => TextMessage.fromJson(e)).toList();
  }

  dispose() {
    if (messages.value.isNotEmpty) {
      _PendingMessagesCache[_chat.id] = messages.value;
    } else {
      _PendingMessagesCache.remove(_chat.id);
    }
    messages.dispose();
  }
}

import 'dart:convert';

import 'package:chatify/src/models/models.dart';
import 'package:chatify/src/utils/cache.dart';
import 'package:chatify/src/utils/log.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class PendingMessagesHandler {
  PendingMessagesHandler({
    required Chat chat,
  }) : _chat = chat {
    messages = Rx<List<Message>>(_loadFromCache());
  }

  final Chat _chat;

  late final Rx<List<Message>> messages;

  static final _memoryCache = <String, List<Message>>{};

  add(Message message) {
    try {
      messages.value = [...messages.value, message];
    } catch (e) {
      ChatifyLog.d(e.toString(), isError: true);
    } finally {
      _updateCache();
    }
  }

  remove(Message message) {
    try {
      if (messages.value.any((e) => e.id == message.id)) {
        messages
          ..value.removeWhere((e) => e.id == message.id)
          ..refresh();
      }
      _updateCache();
    } catch (e) {
      ChatifyLog.d(e.toString(), isError: true);
    }
  }

  removeList(List<Message> ids) {
    try {
      ids.forEach((element) {
        if (messages.value.any((e) => e.id == element.id)) {
          messages
            ..value.removeWhere((e) => e.id == element.id)
            ..refresh();
        }
      });
      _updateCache();
    } catch (e) {
      ChatifyLog.d(e.toString(), isError: true);
    }
  }

  removeById(String id) {
    try {
      if (messages.value.any((e) => e.id == id)) {
        messages
          ..value.removeWhere((e) => e.id == id)
          ..refresh();
      }
      _updateCache();
    } catch (e) {
      ChatifyLog.d(e.toString(), isError: true);
    }
  }

  _updateCache() {
    Cache.instance.setString(
      'pendingMessages',
      jsonEncode(
        {
          _chat.id: messages.value.whereType<TextMessage>().map((e) {
            final json = e.toJson
              ..removeWhere(
                (key, value) => value is Timestamp || value is FieldValue,
              );
            return json;
          }).toList(),
        },
      ),
    );
    _memoryCache[_chat.id] = messages.value;
  }

  List<Message> _loadFromCache() {
    if (_memoryCache[_chat.id] != null)
      // ignore: unnecessary_cast
      return _memoryCache[_chat.id]! as List<Message>;
    final cache = Cache.instance.getString('pendingMessages');
    if (cache == null) return [];
    final json = jsonDecode(cache);
    if (json[_chat.id] == null) return [];
    final msgs = json[_chat.id] as List;
    return msgs.map((e) => TextMessage.fromJson(e, true)).toList().cast<Message>();
  }

  dispose() {
    if (messages.value.isNotEmpty) {
      _memoryCache[_chat.id] = messages.value;
    } else {
      _memoryCache.remove(_chat.id);
    }
    messages.close();
  }
}

import 'dart:convert';

import 'package:chatify/assets/loading.dart';
import 'package:chatify/models/controller.dart';
import 'package:chatify/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:chatify/ui/chat_view/chatting_room.dart';
import 'package:chatify/models/message.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

class ChatModel {
  String id;
  final List<String> members;
  String? imageUrl;
  String? chatName;
  DateTime? updatedAt;
  List<String> unSeenBy;

  factory ChatModel(
      {String? id,
      DateTime? updatedAt,
      required List<String> members,
      List<String>? unSeenBy,
      String? imageUrl,
      String? chatName}) {
    id = id ?? const Uuid().v4();

    final chat = _cache.putIfAbsent(
        id,
        () => ChatModel._(
            id: id!,
            members: members,
            chatName: chatName,
            imageUrl: imageUrl,
            unSeenBy: unSeenBy,
            updatedAt: updatedAt));
    chat.updatedAt = updatedAt;
    chat.unSeenBy = unSeenBy ?? [];
    chat.getLastMessage;
    return chat;
  }

  ChatModel._(
      {required this.id,
      this.updatedAt,
      required this.members,
      List<String>? unSeenBy,
      this.imageUrl,
      this.chatName})
      : unSeenBy = unSeenBy ?? [];

  static final Map<String, ChatModel> _cache = {};

  RxList<String> images = <String>[].obs;
  RxList<String> audios = <String>[].obs;
  Rx<MessageModel?> editedMessage = (null as MessageModel?).obs;
  Rx<MessageModel?> replyMessage = (null as MessageModel?).obs;
  MessageModel? lastMessage;
  ChatUser get sender => ChatUser.current!;

  static String currentId = '';

  Map<String, dynamic> get toJson => {
        'id': id,
        'members': members.toSet().toList(),
        'updatedAt': FieldValue.serverTimestamp(),
        'imageUrl': imageUrl,
        'chatName': chatName,
        'unSeenBy': unSeenBy.toSet().toList()
      };

  static ChatModel fromJson(Map data) {
    return ChatModel(
        imageUrl: data['imageUrl'],
        chatName: data['chatName'],
        updatedAt: data['updatedAt']?.toDate(),
        members: List<String>.from(data['members']),
        unSeenBy: List.from(data['unSeenBy'] ?? []),
        id: data['id']);
  }

  static final Map<String, ChatModel> cache = {};

  Query<MessageModel> get messages {
    return FirebaseFirestore.instance
        .collection("messages")
        .where("roomId", isEqualTo: id)
        .orderBy("sendAt", descending: true)
        .withConverter<MessageModel>(
          fromFirestore: (snapshot, _) =>
              MessageModel.fromJson(snapshot.data()!, snapshot.id),
          toFirestore: (model, _) => model.toJson,
        );
  }

  Query<MessageModel> get unSeenMessages {
    return FirebaseFirestore.instance
        .collection("messages")
        .where("roomId", isEqualTo: id)
        .where("unSeenBy", arrayContains: ChatUser.current?.id)
        .orderBy('sendAt', descending: true)
        .withConverter<MessageModel>(
          fromFirestore: (snapshot, _) =>
              MessageModel.fromJson(snapshot.data()!, snapshot.id),
          toFirestore: (model, _) => model.toJson,
        );
  }

  Stream<int> get unSeenMessagesCount =>
      unSeenMessages.snapshots().map((e) => e.size).map((e) {
        if (e == 0) {
          markAsSeen();
        }
        return e;
      });

  Future<MessageModel?> get getLastMessage async {
    if (lastMessage != null) return lastMessage!;
    var data = await messages.limit(1).get();
    if (data.docs.isNotEmpty) lastMessage = data.docs.first.data();
    return lastMessage;
  }

  static Query<ChatModel> getRooms() {
    var data = _instance
        .where('members', arrayContains: ChatUser.current!.id)
        .orderBy('updatedAt', descending: true);
    return data;
  }

  static Stream<int> getUnread() {
    return ChatUser.current == null
        ? Stream.value(0)
        : _instance
            .where("unSeenBy", arrayContains: ChatUser.current!.id)
            .snapshots()
            .map((event) => event.size);
  }

  static Future<List<ChatModel>> getUnreads() async {
    var data = await _instance
        .where("unSeenBy", arrayContains: ChatUser.current!.id)
        .get();
    return data.docs.map((e) => e.data()).toList();
  }

  Future<ChatUser?> getReceiverAccount() async {
    if (members.length == 2) {
      return await ChatUser.getById(
          members.where((e) => e != ChatUser.current?.id).first);
    }
    return null;
  }

  static final CollectionReference<ChatModel> _instance = FirebaseFirestore
      .instance
      .collection('chat-rooms')
      .withConverter<ChatModel>(
        fromFirestore: (snapshot, _) => fromJson(snapshot.data()!),
        toFirestore: (model, _) => model.toJson,
      );

  save() async {
    await _instance.doc(id).set(this, SetOptions(merge: true));
  }

  delete() async {
    await showLoading(toDo: () async => await _instance.doc(id).delete());
  }

  sendMessage(
      {required String message,
      String type = 'text',
      int? duration,
      MessageModel? reply,
      dynamic data}) async {
    var msg = MessageModel(
      type: type,
      roomId: id,
      messageAttachment: type == 'text' ? null : message,
      rawMessage: type == 'text' ? message : '',
      sender: ChatUser.current!.id,
      duration: duration,
      reply: reply?.message,
      replyId: reply?.replyId,
      replyUid: reply?.sender,
      data: data,
      seenBy: [ChatUser.current!.id],
      unSeenBy: members.where((e) => e != ChatUser.current?.id).toList(),
    );
    msg.save();
    unSeenBy = members.where((e) => e != ChatUser.current?.id).toList();
    save();
    for (var e in unSeenBy) {
      ChatUser.getById(e).then((user) {
        if (user != null && user.clientNotificationId != null) {
          sendNotification(
              user.clientNotificationId!, msg.notifiactionMessage, id, msg.id);
        }
      });
    }
  }

  markAsSeen() {
    if (unSeenBy.contains(ChatUser.current?.id)) {
      FirebaseFirestore.instance.collection('chat-rooms').doc(id).update({
        'unSeenBy': FieldValue.arrayRemove([ChatUser.current!.id])
      });
    }
  }

  static sendTo(ChatUser user, String msg, [String type = 'text']) async {
    ChatModel model = await createModel(user);
    await model.sendMessage(
      type: type,
      message: msg,
    );
  }

  static sendNotification(String? clientNotificationId, String message,
      String roomId, String id) async {
    try {
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'key=${options.notificationKey}'
        },
        body: json.encode({
          'to': clientNotificationId,
          "mutable_content": true,
          "notification": {
            "title": ChatUser.current!.name,
            "body": message,
          },
          "data": {
            "content": {
              "notificationId": roomId.hashCode,
              "channelKey": 'chat',
              "uid": ChatUser.current!.id,
              "id1": roomId,
            },
            'roomId': roomId,
          }
        }),
      );
    } catch (e) {}
  }

  static createModel(ChatUser user) async {
    if (ChatUser.current == null ||
        ChatUser.current?.id == 'id' ||
        ChatUser.current?.id == user.id) {
      throw Exception('Invalid user');
    }
    QuerySnapshot<ChatModel> chats = await _instance.where('members', whereIn: [
      [user.id, ChatUser.current!.id],
      [ChatUser.current!.id, user.id]
    ]).get();
    ChatModel model;
    if (chats.size != 0) {
      model = chats.docs.first.data();
    } else {
      model = ChatModel(members: [user.id, ChatUser.current!.id]);
    }
    return model;
  }

  static startChat(ChatUser user) async {
    ChatModel model = await createModel(user);
    model.open(user, false);
  }

  open(ChatUser user, [bool makeAsRead = true]) async {
    currentId = id;
    await Get.to(ChatView(
      chat: this,
      user: user,
    ));
  }
}

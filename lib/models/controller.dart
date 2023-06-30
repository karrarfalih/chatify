import 'package:chatify/models/chats.dart';
import 'package:chatify/models/connection.dart';
import 'package:chatify/models/custom_messages.dart';
import 'package:chatify/models/user.dart';
import 'package:chatify/ui/scaffold.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

ChatifyOptions? _options;

ChatifyOptions get options {
  if (_options == null) {
    throw Exception('You should call ChatifyController.init method first');
  }
  return _options!;
}

set options(ChatifyOptions options) {
  _options = options;
}

abstract class ChatifyController {
  static bool isInititialized = false;
  // this method should be called before using any other method
  static init(ChatifyOptions ChatifyOptions) {
    options = ChatifyOptions;
    isInititialized = true;
    options.userCollections.limit(1).get().then((e) {
      if (e.docs.isNotEmpty &&
          e.docs.first.data().keys.contains('searchTerms')) {
        try {
          List.from(e.docs.first.data()['searchTerms']);
          options.userData.searchTerms = 'searchTerms';
        } catch (e) {}
      }
    });
  }

  static setCurrentUser(ChatUser user) {
    ChatUser.current = user;
  }

  static Future<void> addScore(
      {required int value, required ChatUser user}) async {
    if (!options.useConnections) {
      throw Exception('set useConnections to true in the init method.');
    }
    if (value < 0 || value > 10) {
      throw Exception('The number should between 1 and 10');
    }
    var con = await UserConnection.getConnection(user);
    int days = DateTime.now().difference(DateTime(2023, 2, 16)).inDays.abs();
    int score = (value * days * 0.1).round();
    await FirebaseFirestore.instance.collection('connections').doc(con.id).set(
        {...con.toJson, 'score': FieldValue.increment(score)},
        SetOptions(merge: true));
  }

  // this method will navigtae to the chat screen
  static showRecentChats(ChatUser currentUser) {
    return Get.to(ChatScreen(currentUser: currentUser));
  }

  // this method will start conversation with the user and add the user to the recent chats
  static startChat(ChatUser user) async {
    await ChatModel.startChat(user);
  }

  // this method will send message to a user
  static sendTo(ChatUser user, String message, [String type = 'text']) async {
    await ChatModel.sendTo(user, message, type);
  }

  // return stream of the unread messages count
  static Stream<int> unReadMessagesCount() {
    return ChatModel.getUnread();
  }
}

class ChatifyOptions {
  final CollectionReference<Map<String, dynamic>> userCollections;

  // to send notifications using the firebase messaging (need to use the firebase messaging package in your app)
  final String? notificationKey;
  // as the chat package depends on the firestore, this model is required to mapping the user data from your firestore in case you have a different model
  final UserData userData;
  // if you want to use the connections feature, you need to set this to true
  final bool useConnections;
  // the chat background image
  final String? chatBackground;
  // the weight of the each message that will be used to calculate the score of the connection between the users
  final int messageConnentionWeight;
  // if you have custom message such as (video) you can add it here
  final List<MessageWidget> customeMessages;
  // when the user click on the user image
  final Function(ChatUser user)? onUserClick;
  // if you want to show the new message button to start chatting with any user
  // if false, you should start the chat manually using the startChat method
  final bool newMessage;

  final String usersCollectionName;

  final ChatUser? Function()? currentUser;

  CollectionReference<ChatUser> get userReference =>
      userCollections.withConverter<ChatUser>(
          fromFirestore: (x, _) => ChatUser(
              id: x.data()![userData.id],
              name: x.data()![userData.name],
              data: x.data()!,
              clientNotificationId: x.data()![userData.clientNotificationId],
              profileImage: x.data()![userData.profileImage],
              uid: x.data()![userData.uid]),
          toFirestore: (x, _) => {});

  ChatifyOptions(
      {this.chatBackground,
      this.onUserClick,
      CollectionReference<Map<String, dynamic>>? userCollections,
      required this.userData,
      required this.usersCollectionName,
      this.currentUser,
      this.useConnections = true,
      this.notificationKey,
      this.newMessage = true,
      this.customeMessages = const [],
      this.messageConnentionWeight = 1})
      : userCollections = userCollections ??
            FirebaseFirestore.instance.collection(usersCollectionName);
}

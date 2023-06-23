// import 'dart:convert';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:get/get.dart';
// import 'package:uuid/uuid.dart';
// import 'package:http/http.dart' as http;

// enum NotificationType { follow, reel, match, reservation }

// class NotificationHandler {
//   final String id;
//   final String user;
//   final String receiver;
//   final String? clientNotificationId;
//   bool isSeen;
//   final String message;
//   final NotificationType type;
//   final dynamic data;
//   DateTime? createdAt;
  

//   NotificationHandler({
//     String? id,
//     String? user,
//     required this.receiver,
//     required this.message,
//     bool? isSeen,
//     required this.type,
//     this.data,
//     this.clientNotificationId,
//     this.createdAt,
//   })  : id = id ?? const Uuid().v4(),
//         user = user ?? Account.currentId!,
//         isSeen = isSeen ?? false;

//   static NotificationHandler fromJson(Map<String, dynamic> e) =>
//       NotificationHandler(
//           receiver: e['receiver'],
//           clientNotificationId: e['clientNotificationId'],
//           id: e['id'],
//           user: e['user'],
//           message: e['message'],
//           isSeen: e['isSeen'],
//           createdAt: e['createdAt']?.toDate(),
//           type: NotificationType.values.elementAt(e['type']),
//           data: e['data']);

//   Map<String, dynamic> get toJson => {
//         'receiver': receiver,
//         'clientNotificationId': clientNotificationId,
//         'id': id,
//         'user': user,
//         'message': message,
//         'isSeen': isSeen,
//         'createdAt': createdAt == null
//             ? FieldValue.serverTimestamp()
//             : Timestamp.fromDate(createdAt!),
//         'data': data,
//         'type': type.index
//       };

//   static final CollectionReference<NotificationHandler> ref = FirebaseFirestore
//       .instance
//       .collection(Collections.notifications)
//       .withConverter<NotificationHandler>(
//           fromFirestore: (x, _) => NotificationHandler.fromJson(x.data()!),
//           toFirestore: (x, _) => x.toJson);
//   static Query<NotificationHandler> get refAll => ref
//       .where('receiver', isEqualTo: Account.currentId ?? 'null')
//       .orderBy('createdAt', descending: true);
//   static Query<NotificationHandler> get refNew => ref
//       .where('isSeen', isEqualTo: false)
//       .where('receiver', isEqualTo: Account.currentId ?? 'null')
//       .orderBy('createdAt', descending: true);

//   static Stream<int> get count => refNew.snapshots().map((event) => event.size);

//   bool get isFollow => type == NotificationType.follow;
//   bool get isReel => type == NotificationType.reel;
//   bool get isReelComment =>
//       type == NotificationType.reel && message.contains('commented:');
//   bool get isMatch => type == NotificationType.match;

//   static Stream<bool> get hasNotifications => ref
//       .where('receiver', isEqualTo: Account.currentId?? 'null')
//       .limit(1)
//       .snapshots()
//       .map((event) => event.size > 0);

//   static follow(String receiver) async {
//     var res = await ref
//         .where('user', isEqualTo: Account.currentId)
//         .where('receiver', isEqualTo: receiver)
//         .where('targetId', isNull: true)
//         .get();
//     String msg = 'started following you.';
//     if (res.size > 0) {
//       NotificationHandler notification = res.docs.first.data();
//       notification.createdAt = null;
//       await notification.save();
//     } else {
//       await NotificationHandler(
//               receiver: receiver,
//               message: msg,
//               clientNotificationId: Account.current.value?.clientNotificationId,
//               type: NotificationType.follow)
//           .save();
//     }
//     Account? account = await Account.getByUid(receiver);
//     if (account?.clientNotificationId != null)
//       sendNotification(account!.clientNotificationId!, msg);
//   }

//   static unfollow(String receiver) async {
//     var res = await ref
//         .where('user', isEqualTo: Account.currentId)
//         .where('receiver', isEqualTo: receiver)
//         .get();
//     if (res.size > 0) await ref.doc(res.docs.first.id).delete();
//   }

//   static comment(String receiver, String comment, String reelId) async {
//     String msg = 'commented: $comment';
//     await NotificationHandler(
//             receiver: receiver,
//             message: msg,
//             clientNotificationId: Account.current.value?.clientNotificationId,
//             data: reelId,
//             type: NotificationType.reel)
//         .save();
//     Account? account = await Account.getByUid(receiver);
//     if (account?.clientNotificationId != null)
//       sendNotification(account!.clientNotificationId!, msg);
//   }

//   static like(String receiver, String reelId) async {
//     var res = await ref
//         .where('user', isEqualTo: Account.currentId)
//         .where('receiver', isEqualTo: receiver)
//         .where('targetId', isEqualTo: reelId)
//         .where('message', isEqualTo: 'liked your reel.')
//         .get();
//     String msg = 'liked your reel.';
//     if (res.size > 0) {
//       NotificationHandler notification = res.docs.first.data();
//       notification.createdAt = null;
//       await notification.save();
//     } else {
//       await NotificationHandler(
//               receiver: receiver,
//               message: msg,
//               clientNotificationId: Account.current.value?.clientNotificationId,
//               data: reelId,
//               type: NotificationType.reel)
//           .save();
//     }
//     Account? account = await Account.getByUid(receiver);
//     if (account?.clientNotificationId != null)
//       sendNotification(account!.clientNotificationId!, msg);
//   }

//   static dislike(String receiver, String reelId) async {
//     var res = await ref
//         .where('user', isEqualTo: Account.currentId)
//         .where('receiver', isEqualTo: receiver)
//         .where('targetId', isEqualTo: reelId)
//         .where('message', isEqualTo: 'liked your reel.')
//         .get();
//     if (res.size > 0) await ref.doc(res.docs.first.id).delete();
//   }

//   static sendNotification(String? clientNotificationId, String message,
//       [Map? data, Account? user]) async {
//     try {
//       await http.post(
//         Uri.parse('https://fcm.googleapis.com/fcm/send'),
//         headers: <String, String>{
//           'Content-Type': 'application/json',
//           'Authorization':
//               'key=AAAAikl6JW8:APA91bEO6feweX8klgZupj8Lh7aMUEy7PXOfsZDAeEH1sHxbOiqinBqcwjQyLLAtGkAM9-rXRIUkzvvuzbP6uYj0NAjnJZdfk8MlLY5_9vKPHOkTCfbW0exwYQByKHnIlvmf35TEdzu4'
//         },
//         body: json.encode({
//           'to': clientNotificationId,
//           "notification": {
//             "title": user?.name ??
//                 (Account.isAdmin ? 'فريق لاعوب' : Account.current.value!.name),
//             "body": (ar[message] ?? message)
//                 .replaceFirst('commented:', '${'commented'.tr}:')
//                 .sentenceCase,
//             "titleLocKey": 'myKey',
//             "meta": {"type": "small", "info": "Search"}
//           },
//           "data": {
//             "uid": user?.id ?? Account.currentId,
//             if (data != null) ...data
//           }
//         }),
//       );
//     } catch (e) {}
//   }

//   static markAsSeen() async {
//     var res = await refNew.get();
//     for (var element in res.docs) {
//       NotificationHandler not = element.data();
//       not.isSeen = true;
//       not.save();
//     }
//   }

//   save([bool push = false, Account? user]) async {
//     if (push) sendNotification(clientNotificationId, message, null, user);
//     await ref.doc(id).set(this, SetOptions(merge: true));
//   }
// }

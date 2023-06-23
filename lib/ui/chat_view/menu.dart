// import 'dart:math';
// import 'package:chatify/assets/confirm.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_keyboard_size/flutter_keyboard_size.dart';
// import 'package:get/get.dart';
// import 'package:chatify/models/chats.dart';
// import 'package:chatify/models/message.dart';
// import 'package:chatify/assets/circular_button.dart';
// import 'package:chatify/ui/chat_view/chatting_room.dart';

// class MessageMenu extends StatelessWidget {
//   const MessageMenu({
//     Key? key,
//     required this.message,
//     required this.offset,
//     required this.chat,
//   }) : super(key: key);
//   final Offset offset;
//   final MessageModel message;
//   final ChatModel chat;

//   @override
//   Widget build(
//     BuildContext context,
//   ) {
//     return KeyboardSizeProvider(
//       smallSize: 500.0,
//       child: Consumer<ScreenHeight>(builder: (context, _res, child) {
//         return Stack(
//           alignment: Alignment.center,
//           children: [
//             SizedBox(
//               width: 0,
//               height: 0,
//               child: Material(
//                 color: Colors.transparent,
//                 child: TextField(
//                   autofocus: isKeyboardOpen,
//                 ),
//               ),
//             ),
//             Positioned(
//               // right: message.isMine ? 20 : null,
//               // left: message.isMine ? null : 20,
//               top: min(
//                   offset.dy - 60,
//                   MediaQuery.of(context).size.height -
//                       350 -
//                       _res.keyboardHeight),
//               child: Column(
//                 children: [
//                   if (!message.isMine)
//                     Material(
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(16)),
//                       elevation: 4,
//                       child: Container(
//                         decoration: BoxDecoration(
//                             color: Theme.of(context).scaffoldBackgroundColor,
//                             shape: BoxShape.rectangle,
//                             borderRadius:
//                                 const BorderRadius.all(Radius.circular(12))),
//                         child: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: ['❤', '😍', '😂', '😢', '👍'].map((e) {
//                             double size = 1;
//                             return Container(
//                               margin: EdgeInsets.symmetric(
//                                   vertical: message.emoji == e ? 6 : 0),
//                               decoration: BoxDecoration(
//                                   color: message.emoji == e
//                                       ? Theme.of(context)
//                                           .backgroundColor
//                                           .withOpacity(0.05)
//                                       : Colors.transparent,
//                                   shape: BoxShape.circle),
//                               child: AnimatedScale(
//                                 duration: const Duration(milliseconds: 150),
//                                 scale: size,
//                                 child: CircularButton(
//                                     highlightColor: Colors.transparent,
//                                     icon: Text(
//                                       e,
//                                       style: TextStyle(fontSize: 28),
//                                     ),
//                                     onPressed: () {
//                                       if (message.emoji == e) {
//                                         message
//                                           ..emoji = null
//                                           ..save();
//                                       } else {
//                                         message
//                                           ..emoji = e
//                                           ..save();
//                                       }
//                                       Get.back();
//                                     }),
//                               ),
//                             );
//                           }).toList(),
//                         ),
//                       ),
//                     ),
//                   if (!message.isMine)
//                     const SizedBox(
//                       height: 5,
//                     ),
//                   Material(
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(16)),
//                     elevation: 4,
//                     child: Container(
//                       width: 150,
//                       decoration: BoxDecoration(
//                           color: Theme.of(context).scaffoldBackgroundColor,
//                           shape: BoxShape.rectangle,
//                           borderRadius:
//                               const BorderRadius.all(Radius.circular(12))),
//                       child: Column(children: [
//                         Option(
//                             text: 'Edit',
//                             icon: Icons.edit,
//                             onPressed: () {
//                               Get.back();
//                               chat.replyMessage.value = null;
//                               chat.editedMessage.value = message;
//                             }),
//                         Option(
//                             text: 'Delete',
//                             icon: Icons.delete,
//                             onPressed: () async {
//                               Get.back();
//                               if (await showConfirm(
//                                   message: 'Delete selcetd message?',
//                                   textOK: 'Yes',
//                                   textCancel: 'No',
//                                   isKeyboardShown: isKeyboardOpen)) {
//                                 message.delete();
//                               }
//                             }),
//                         Option(
//                             text: 'Reply',
//                             icon: Icons.reply,
//                             onPressed: () {
//                               Get.back();
//                               chat.editedMessage.value = null;
//                               chat.replyMessage.value = message;
//                             }),
//                       ]),
//                     ),
//                   )
//                 ],
//               ),
//             ),
//           ],
//         );
//       }),
//     );
//   }
// }

// class Option extends StatelessWidget {
//   const Option(
//       {super.key,
//       required this.text,
//       required this.onPressed,
//       required this.icon});
//   final String text;
//   final IconData icon;
//   final Function() onPressed;

//   @override
//   Widget build(BuildContext context) {
//     return Directionality(
//       textDirection: TextDirection.ltr,
//       child: TextButton(
//           onPressed: onPressed,
//           style: TextButton.styleFrom(
//               minimumSize: Size(150, 40),
//               padding: EdgeInsets.symmetric(horizontal: 20)),
//           child: Row(
//             children: [
//               Icon(
//                 icon,
//                 color: Colors.black87,
//                 size: 20,
//               ),
//               // ignore: prefer_const_constructors
//               SizedBox(
//                 width: 8,
//               ),
//               Text(
//                 text.tr,
//                 style: TextStyle(fontSize: 12, color: Colors.black87),
//               ),
//             ],
//           )),
//     );
//   }
// }

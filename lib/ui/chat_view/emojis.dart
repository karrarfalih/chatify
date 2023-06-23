// import 'dart:ui';

// import 'package:chat/assets/circular_button.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:chat/models/message.dart';

// class Emojis extends StatelessWidget {
//   const Emojis({
//     Key? key,
//     required this.message,
//     required this.offset,
//   }) : super(key: key);
//   final Offset offset;
//   final MessageModel message;

//   @override
//   Widget build(
//     BuildContext context,
//   ) {
//     return Stack(
//       children: [
//         Positioned(
//           right: message.isMine ? 20 : null,
//           left: message.isMine ? null : 20,
//           top: offset.dy - 60,
//           child: BackdropFilter(
//             filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
//             child: Material(
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(16)),
//               elevation: 4,
//               child: Container(
//                 decoration: BoxDecoration(
//                     color: Theme.of(context).scaffoldBackgroundColor,
//                     shape: BoxShape.rectangle,
//                     borderRadius: const BorderRadius.all(Radius.circular(12))),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: ['❤', '😍', '😂', '😢', '👍'].map((e) {
//                     double size = 1;
//                     return Container(
//                       margin: EdgeInsets.symmetric(
//                           vertical: message.emoji == e ? 6 : 0),
//                       decoration: BoxDecoration(
//                           color: message.emoji == e
//                               ? Theme.of(context)
//                                   .backgroundColor
//                                   .withOpacity(0.05)
//                               : Colors.transparent,
//                           shape: BoxShape.circle),
//                       child: AnimatedScale(
//                         duration: const Duration(milliseconds: 150),
//                         scale: size,
//                         child: CircularButton(
//                             highlightColor: Colors.transparent,
//                             icon: Text(
//                               e,
//                               style: TextStyle(fontSize: 28),
//                             ),
//                             onPressed: () {
//                               if (message.emoji == e) {
//                                 message
//                                   ..emoji = null
//                                   ..save();
//                               } else {
//                                 message
//                                   ..emoji = e
//                                   ..save();
//                               }
//                               Get.back();
//                             }),
//                       ),
//                     );
//                   }).toList(),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

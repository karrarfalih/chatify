// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:chat/ui/chats/new_message.dart';
// import 'package:flutter_svg/flutter_svg.dart';

// class ChatSearch extends StatelessWidget {
//   const ChatSearch({
//     Key? key,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 72,
//       color: Secondary.level2.value,
//       width: Get.width,
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),

//       // height: 56,
//       child: SizedBox(
//         height: 48,
//         child: InkWell(
//           onTap: () {
//             Get.to(const NewMessages());
//           },
//           child: IgnorePointer(
//             child: TextFormField(
//               style: titleStyle,
//               textAlign: TextAlign.start,
//               textAlignVertical: TextAlignVertical.bottom,
//               textInputAction: TextInputAction.search,
//               decoration: InputDecoration(
//                 hintText: 'Search'.tr,
//                 enabled: true,
//                 hintStyle: titleStyle.copyWith(color: Secondary.level5.value),
//                 isDense: true,
//                 filled: true,
//                 fillColor: Secondary.level1.value,
//                 prefixIcon: SizedBox(
//                   child: Padding(
//                     padding: const EdgeInsets.all(12),
//                     child: SvgPicture.asset(
//                       SVG().searchIcon,
//                       color: Secondary.level4.value,
//                     ),
//                   ),
//                 ),
//                 enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(8),
//                   borderSide: BorderSide(
//                     color: Secondary.level3.value,
//                   ),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(8),
//                   borderSide: BorderSide(
//                     color: Secondary.level3.value,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:motion_toast/motion_toast.dart';

// _showToast(String message, [Color? color]) {
//   Fluttertoast.showToast(
//     msg: message.tr,
//     toastLength: Toast.LENGTH_SHORT,
//     gravity: ToastGravity.TOP,
//     timeInSecForIosWeb: 3,
//     backgroundColor: color ?? Colors.red,
//     textColor: Colors.white,
//     fontSize: 16.0,
//   );
// }

showToast(String message) {
  MotionToast.error(
    description: Text(message),
    toastDuration: Duration(seconds: 5),
    constraints: BoxConstraints(maxHeight: 100, minHeight: 50),
    displaySideBar: false,
    animationType: AnimationType.fromTop,
    position: MotionToastPosition.top,
  ).show(Get.context!);
}

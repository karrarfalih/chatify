import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

showToast(String message, [Color? color]) {
  Fluttertoast.showToast(
                            msg: message.tr,
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.CENTER,
                            timeInSecForIosWeb: 3,
                            backgroundColor: color ?? Colors.red,
                            textColor: Colors.white,
                            
                            fontSize: 16.0);
}

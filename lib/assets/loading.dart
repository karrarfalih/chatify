import 'package:chatify/models/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';

showLoading(
    {Future Function()? toDo, bool initState = false, bool back = true}) async {
  if (initState) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _showDialog();
      if (toDo != null) await toDo();
      if (back && toDo != null) Get.back();
    });
  } else {
    _showDialog();
    if (toDo != null) await toDo();
    if (back && toDo != null) Get.back();
  }
}

_showDialog() async {
  await Get.bottomSheet(
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                  margin: const EdgeInsets.all(20),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: const [
                        BoxShadow(
                            color: Colors.black12,
                            blurRadius: 5,
                            spreadRadius: 5)
                      ]),
                  child: SpinKitRing(color: currentTheme.primary)),
            ],
          ),
        ],
      ),
      isDismissible: false,
      persistent: true,
      backgroundColor: Colors.transparent);
}

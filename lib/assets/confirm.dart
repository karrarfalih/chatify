import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<bool> showConfirm({
  String? title,
  String? message,
  String? textCancel,
  String? textOK,
  bool isKeyboardShown = false,
}) async {
  final bool? isConfirm = await Get.dialog<bool?>(ConfirmDialog(
    isKeyboardShown: isKeyboardShown,
    message: message,
    textCancel: textCancel,
    textOK: textOK,
    title: title,
  ));

  return isConfirm ?? false;
}

class ConfirmDialog extends StatelessWidget {
  const ConfirmDialog(
      {Key? key,
      this.title,
      this.message,
      this.isKeyboardShown = false,
      this.textCancel,
      this.textOK})
      : super(key: key);

  final String? title;
  final String? message;
  final String? textCancel;
  final String? textOK;
  final bool isKeyboardShown;

  @override
  Widget build(
    BuildContext context,
  ) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 0,
          height: 0,
          child: Material(
            color: Colors.transparent,
            child: TextField(
              autofocus: isKeyboardShown,
            ),
          ),
        ),
        AlertDialog(
          title: Text(title ?? 'Confirm'.tr),
          content: Text((message ?? 'Are you sure continue?').tr),
          actions: <Widget>[
            TextButton(
              child: Text((textCancel ?? 'Cancel').tr),
              onPressed: () => Navigator.pop(context, false),
            ),
            TextButton(
              child: Text((textOK ?? 'OK').tr),
              onPressed: () => Navigator.pop(context, true),
            ),
          ],
        )
      ],
    );
  }
}

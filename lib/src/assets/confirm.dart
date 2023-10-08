import 'package:flutter/material.dart';

Future<bool> showConfirm({
  required BuildContext context,
  String? title,
  String? message,
  String? textCancel,
  String? textOK,
  bool isKeyboardShown = false,
}) async {
  final bool? isConfirm = await showDialog<bool?>(
    context: context,
    builder: (context) => ConfirmDialog(
    isKeyboardShown: isKeyboardShown,
    message: message,
    textCancel: textCancel,
    textOK: textOK,
    title: title,
  ),);

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
          title: Text(title ?? 'Confirm'),
          content: Text((message ?? 'Are you sure continue?')),
          actions: <Widget>[
            TextButton(
              child: Text((textCancel ?? 'Cancel')),
              onPressed: () => Navigator.pop(context, false),
            ),
            TextButton(
              child: Text((textOK ?? 'OK')),
              onPressed: () => Navigator.pop(context, true),
            ),
          ],
        )
      ],
    );
  }
}

import 'package:chatify/chatify.dart';
import 'package:chatify/src/localization/get_string.dart';
import 'package:flutter/material.dart';

Future<bool?> showConfirmDialog({
  required BuildContext context,
  String? title,
  String? message,
  String? textCancel,
  String? textOK,
  bool isKeyboardShown = false,
  Color okColor = Colors.red,
  bool showDeleteForAll = false,
}) async {
  return await showDialog<bool?>(
    context: context,
    builder: (context) => ConfirmDialog(
      isKeyboardShown: isKeyboardShown,
      message: message,
      textCancel: textCancel,
      textOK: textOK,
      title: title,
      okColor: okColor,
      showDeleteForAll: showDeleteForAll,
    ),
  );
}

class ConfirmDialog extends StatelessWidget {
  const ConfirmDialog({
    Key? key,
    this.title,
    this.message,
    this.isKeyboardShown = false,
    this.textCancel,
    this.textOK,
    required this.okColor,
    required this.showDeleteForAll,
  }) : super(key: key);

  final String? title;
  final String? message;
  final String? textCancel;
  final String? textOK;
  final bool isKeyboardShown;
  final Color okColor;
  final bool showDeleteForAll;

  @override
  Widget build(
    BuildContext context,
  ) {
    bool deleteForAll = false;
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
          title: Text(title ?? localization(context).confirm, style: TextStyle(fontSize: 18)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          titlePadding:
              EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 8),
          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Text(
                  (message ?? 'Are you sure continue?'),
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
                ),
              ),
              StatefulBuilder(
                builder: (context, setState) {
                  return TextButton(
                    onPressed: () {
                      setState(() {
                        deleteForAll = !deleteForAll;
                      });
                    },
                    style: TextButton.styleFrom(
                      minimumSize: Size.zero,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          deleteForAll
                              ? Icons.check_box
                              : Icons.check_box_outline_blank,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          localization(context).deleteForAll,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          buttonPadding: EdgeInsets.zero,
          actionsPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          actions: <Widget>[
            TextButton(
              child: Text(
                (textCancel ?? localization(context).cancel),
                style: TextStyle(
                  color: Chatify.theme.chatForegroundColor.withOpacity(0.6),
                ),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: Text((textOK ?? localization(context).ok), style: TextStyle(color: okColor)),
              onPressed: () =>
                  Navigator.pop(context, deleteForAll || !showDeleteForAll),
            ),
          ],
        )
      ],
    );
  }
}

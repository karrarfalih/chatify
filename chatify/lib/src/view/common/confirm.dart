import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<bool?> showChatConfirmDialog({
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
    builder: (context) => ChatConfirmDialog(
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

class ChatConfirmDialog extends StatelessWidget {
  const ChatConfirmDialog({
    super.key,
    this.title,
    this.message,
    this.isKeyboardShown = false,
    this.textCancel,
    this.textOK,
    required this.okColor,
    required this.showDeleteForAll,
  });

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
          title: Text(
            title ?? 'Confirm'.tr,
            style: TextStyle(fontSize: 18),
          ),
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
                  (message ?? 'Are you sure to continue?'.tr),
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
                ),
              ),
              const SizedBox(height: 16),
              if (showDeleteForAll)
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
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            deleteForAll
                                ? Icons.check_box
                                : Icons.check_box_outline_blank,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Delete for all'.tr,
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
          actionsPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          actions: <Widget>[
            TextButton(
              child: Text(
                (textCancel ?? 'Cancel'.tr),
                style: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6)),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: Text(
                (textOK ?? 'OK'.tr),
                style: TextStyle(color: okColor),
              ),
              onPressed: () => Navigator.pop(context, deleteForAll),
            ),
          ],
        ),
      ],
    );
  }
}

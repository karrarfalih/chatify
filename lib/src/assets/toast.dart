import 'package:chatify/src/utils/context_provider.dart';
import 'package:flutter/material.dart';

showToast(String message, [Color? color]) {
  final scaffold = ScaffoldMessenger.of(ContextProvider.context!);
    scaffold.showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
        backgroundColor: color,
      ),
    );
}

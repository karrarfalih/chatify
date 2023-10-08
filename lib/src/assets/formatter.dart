import 'package:flutter/services.dart';

class MaxLineInputFormatter extends TextInputFormatter {
  final int maxLines;

  MaxLineInputFormatter(this.maxLines);

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    // Count the number of lines in the new value
    final newLineCount = RegExp('\n').allMatches(newValue.text).length;

    // Only allow the new value if it doesn't exceed the maximum number of lines
    if (newLineCount <= maxLines) {
      return newValue;
    } else {
      // Return the old value if the new value exceeds the maximum number of lines
      return oldValue;
    }
  }
}

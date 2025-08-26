import 'package:flutter/material.dart';

extension ArabicText on String {
  bool get isContainArabic {
    if (isEmpty) return false;

    final arabicRanges = [
      RegExp(r'[\u0600-\u06FF]'),
      RegExp(r'[\u0750-\u077F]'),
      RegExp(r'[\u08A0-\u08FF]'),
      RegExp(r'[\uFB50-\uFDFF]'),
      RegExp(r'[\uFE70-\uFEFF]'),
    ];

    for (final range in arabicRanges) {
      if (range.hasMatch(this)) {
        return true;
      }
    }

    return false;
  }

  TextDirection get directionByLanguage =>
      isContainArabic ? TextDirection.rtl : TextDirection.ltr;
}

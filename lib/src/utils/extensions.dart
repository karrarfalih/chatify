import 'dart:math' as math;
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
String mathFunc(Match match) => '${match[1]},';

String convertMoney(int data) =>
    data.toString().replaceAllMapped(reg, mathFunc);

extension StringToCurrency on String {
  String get toCurrency => replaceAllMapped(reg, mathFunc);
}

extension StringSplit on String {
  List<String> get urls {
    RegExp exp = RegExp(r'(?:(?:https?|ftp):\/\/)?[\w/\-?=%.]+\.[\w/\-?=%.]+');
    Iterable<RegExpMatch> matches = exp.allMatches(this);

    var texts = split(exp);
    var links = matches.map((e) => substring(e.start, e.end));
    for (int i = 0; i < links.length; i++) {
      texts.insert(i + i + 1, links.elementAt(i));
    }
    return texts;
  }
}

// extension IntToCurrency on num?{
//   String get toCurrency => toString().toCurrency;
// }
extension NullableIntToCurrency on num? {
  String get toCurrency => this == null ? '0' : toString().toCurrency;
}

extension MaxMinIterable on Iterable<int> {
  int get max => reduce(math.max);

  int get min => reduce(math.min);
}

extension StringCasingExtension on String {
  String toCapitalized() =>
      isNotEmpty ? '${this[0].toUpperCase()}${substring(1)}' : '';
  String toTitleCase() => replaceAll(r'$', ' ')
      .replaceAll(RegExp(' +'), ' ')
      .split(" ")
      .map((str) => str.toCapitalized())
      .join(" ");
}

extension Generator on String {
  List<String> get generateSearchTerms {
    List<String> terms = [];
    for (int i = 0; i < length; i++) {
      for (int j = 0; j < length - i; j++) {
        terms.add(substring(j, i + j + 1));
      }
    }
    return terms;
  }
}

extension Phone on String {
  String get phoneUniversal {
    if (length < 6) return this;
    String x = replaceAll(' ', '');
    if (x.substring(0, 2) == '00') return x;
    if (x.substring(0, 1) == '0') x = x.substring(1);
    if (x.substring(0, 3) == '964') return '+$x';
    if (x.substring(0, 1) == '+') return x;
    return '+964$x';
  }

  String get phoneLocally {
    if (length < 6) return this;
    String x = replaceAll(' ', '');
    if (x.substring(0, 3) == '964') x = x.substring(3);
    if (x.substring(0, 1) == '+') x = x.substring(1);
    if (x.substring(0, 1) != '0') x = '0$x';
    return x;
  }
}

extension Url on String? {
  bool get isURL => hasMatch(
        this,
        r"^((((H|h)(T|t)|(F|f))(T|t)(P|p)((S|s)?))\://)?(www.|[a-zA-Z0-9].)[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,6}(\:[0-9]{1,5})*(/($|[a-zA-Z0-9\.\,\;\?\'\\\+&amp;%\$#\=~_\-]+))*$",
      );
}

bool hasMatch(String? value, String pattern) {
  return (value == null) ? false : RegExp(pattern).hasMatch(value);
}

extension DateTimeFormat on DateTime {
  String fullDate(BuildContext context) =>
      format(context, 'MMM d, yyyy - HH:mm a');
  String get ago {
    int min = DateTime.now().difference(this).inMinutes;
    int count = 0;
    String text = '';
    if (min == 0) {
      return 'just now';
    }
    if (min < 60) {
      count = max(min, 0);
      text = 'm';
    } else if (min < 60 * 24) {
      count = min ~/ 60;
      text = 'h';
    } else if (min < 60 * 24 * 7) {
      count = min ~/ (60 * 24);
      text = ' days';
    } else {
      count = min ~/ (60 * 24 * 7);
      text = ' weeks';
    }
    text = text;
    return '$count$text ago';
  }

  String format(BuildContext context, String format) {
    initializeDateFormatting();
    return DateFormat(
      format,
      Localizations.maybeLocaleOf(context)?.languageCode,
    ).format(this);
  }

  DateTime get withoutTime => DateTime(year, month, day);
  DateTime get onlyMonth => DateTime(year, month);
  Timestamp get stamp => Timestamp.fromDate(this);
}

extension Range on double {
  double withRange(double minNumber, double maxNumber) =>
      min(max(this, minNumber), maxNumber);
}

extension DurationInt on int {
  String get toDurationString {
    int s = this % 60;
    int m = this ~/ 60;
    return '$m:${s < 10 ? '0$s' : s}';
  }
}

extension UrlFormatter on String {
  String get urlFormat {
    if (this.isEmpty) return '';
    if (this.startsWith('http')) return this;
    return 'https://$this';
  }
}

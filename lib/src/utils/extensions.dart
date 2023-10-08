import 'dart:math' as math;

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
  bool get isURL => hasMatch(this,
      r"^((((H|h)(T|t)|(F|f))(T|t)(P|p)((S|s)?))\://)?(www.|[a-zA-Z0-9].)[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,6}(\:[0-9]{1,5})*(/($|[a-zA-Z0-9\.\,\;\?\'\\\+&amp;%\$#\=~_\-]+))*$");
}

bool hasMatch(String? value, String pattern) {
  return (value == null) ? false : RegExp(pattern).hasMatch(value);
}
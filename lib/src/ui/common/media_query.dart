import 'package:flutter/material.dart';

MediaQueryData? _mediaQuery;

MediaQueryData mediaQuery(BuildContext context) {
  _mediaQuery ??= MediaQuery.of(context);
  return _mediaQuery!;
}

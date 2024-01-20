import 'package:chatify/src/localization/generated/chatify_localizations.dart';
import 'package:chatify/src/localization/generated/chatify_localizations_en.dart';
import 'package:flutter/material.dart';

ChatifyLocalizations localization(BuildContext context) {
  return ChatifyLocalizations.of(context) ?? ChatifyLocalizationsEn();
}

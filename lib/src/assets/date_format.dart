import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

extension DateTimeFormat on DateTime{
  String fullDate(BuildContext context) => format(context, 'MMM d, yyyy - HH:mm a');

  String format(BuildContext context, String format){
    initializeDateFormatting();
    return DateFormat(format, Localizations.maybeLocaleOf(context)?.languageCode).format(this);
  }

  DateTime get withoutTime => DateTime(year, month, day);
  DateTime get onlyMonth => DateTime(year, month);
  Timestamp get stamp => Timestamp.fromDate(this);
}


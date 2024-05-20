import 'package:flutter/material.dart';

class MyDate {
  static String getFormattedTime(BuildContext context, String time) {
    final date = DateTime.fromMillisecondsSinceEpoch(int.parse(time));
    return TimeOfDay.fromDateTime(date).format(context);
  }
}

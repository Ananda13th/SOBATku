import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:intl/intl.dart';

class DayConverter {
  static String convertToDay(int day) {
    if(day == 1)
      return "Senin";
    if(day == 2)
      return "Selasa";
    if(day == 3)
      return "Rabu";
    if(day == 4)
      return "Kamis";
    if(day == 5)
      return "Jumat";
    if(day == 6)
      return "Sabtu";
    return "";
  }

  static int convertToNumber(String day) {
    if(day == "Monday")
      return 1;
    if(day == "Tuesday")
      return 2;
    if(day == "Wednesday")
      return 3;
    if(day == "Thursday")
      return 4;
    if(day == "Friday")
      return 5;
    if(day == "Saturday")
      return 6;
    return 0;
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
// import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:public_rooster/data/app_data.dart';
import 'package:public_rooster/model/app_models.dart';

class AppHelper {
  AppHelper._();
  static final AppHelper instance = AppHelper._();

  FsSpreadsheet findSpreadsheetByCurrentDate(List<FsSpreadsheet> spreadSheets) {
    DateTime now = DateTime.now();
    FsSpreadsheet? result = spreadSheets
        .firstWhereOrNull((e) => e.year == now.year && e.month == now.month);

    return result ?? FsSpreadsheet.empty();
  }

  FsSpreadsheet findSpreadsheetByDate(
      List<FsSpreadsheet> spreadSheets, DateTime date) {
    FsSpreadsheet? result = spreadSheets
        .firstWhereOrNull((e) => e.year == date.year && e.month == date.month);

    return result ?? FsSpreadsheet.empty();
  }

  ///-----------------
  String monthAsString(DateTime date) {
    String dayMonth = DateFormat.MMMM('nl_NL').format(date);
    return dayMonth;
  }

  ///-----------------
  String dayAsString(DateTime date) {
    String dag = DateFormat.EEEE('nl_NL').format(date).substring(0, 2);
    dag += ' ${date.day}';
    return dag;
  }

  ///-----------------
  DateTime getDateFromSpreadsheet(FsSpreadsheet fsSpreadsheet) {
    return DateTime(fsSpreadsheet.year, fsSpreadsheet.month, 1);
  }

  ///-----------------
  DateTime getNextMonth(DateTime dateTime) {
    int y = dateTime.year;
    int m = dateTime.month;
    if (y == 12) {
      return DateTime(y + 1, 1, 1);
    } else {
      return DateTime(y, m + 1, 1);
    }
  }

  ///-----------------
  DateTime getPrevMonth(DateTime dateTime) {
    int y = dateTime.year;
    int m = dateTime.month;
    if (y == 1) {
      return DateTime(y - 1, 12, 1);
    } else {
      return DateTime(y, m - 1, 1);
    }
  }

  ///----------------------------------------//------------------
  List<DateTime> getDaysInBetween(DateTime startDate) {
    DateTime endDate = DateTime(startDate.year, startDate.month + 1, 0);
    List<DateTime> days = [];
    for (int i = 0; i <= endDate.difference(startDate).inDays; i++) {
      days.add(startDate.add(Duration(days: i)));
    }
    return days;
  }

  ///----------------------------------------
  DateTime? parseDateTime(Object? value) {
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    } else if (value is DateTime) {
      return value;
    } else if (value is Timestamp) {
      return (value).toDate();
    } else if (value == null) {
      return null;
    } else {
      return DateTime.now();
    }
  }

  ///-----------------------------------
  bool isDateExcluded(DateTime date) {
    ExcludeDay? excludeDay = AppData.instance.excludeDays
        .firstWhereOrNull((e) => e.dateTime == date);
    return excludeDay != null ? true : false;
  }

  ///-----------------
  // void getDeviceType(BuildContext context) async {
  // final deviceInfoPlugin = DeviceInfoPlugin();
  // final deviceInfo = await deviceInfoPlugin.deviceInfo;
  // final allInfo = deviceInfo.data;
  // log(allInfo.toString());
  // }

  ///--------------------
  TargetPlatform getPlatform() {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return TargetPlatform.android;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return TargetPlatform.iOS;
    } else {
      return TargetPlatform.windows;
    }
  }

  ///--------------------
  bool isWindows() {
    TargetPlatform platform = getPlatform();
    return platform == TargetPlatform.windows;
  }

  ///--------------------
  void setupLocale(BuildContext context) async {
    await initializeDateFormatting('nl_NL', null);
  }
}

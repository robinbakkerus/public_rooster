import 'dart:developer';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/date_symbol_data_local.dart';
// import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:public_rooster/model/app_models.dart';
// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';

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
    String dag = DateFormat.EEEE('nl_NL').format(date).substring(0, 3);
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

  ///-----------------
  void getDeviceType(BuildContext context) async {
    final deviceInfoPlugin = DeviceInfoPlugin();
    final deviceInfo = await deviceInfoPlugin.deviceInfo;
    final allInfo = deviceInfo.data;
    log(allInfo.toString());
  }

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

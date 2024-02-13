import 'dart:developer';

import 'package:public_rooster/data/app_data.dart';
import 'package:public_rooster/event/app_events.dart';
import 'package:public_rooster/model/app_models.dart';
import 'package:public_rooster/service/dbs.dart';
import 'package:public_rooster/util/spreadsheet_generator.dart';

class AppController {
  AppController._();

  static AppController instance = AppController._();

  ///----------------------------
  void setActiveDate(DateTime date) {
    AppData.instance.setActiveDate(date);
  }

  ///-------------------------
  Future<void> retrieveAllSpreadsheetData() async {
    List<FsSpreadsheet> result = await Dbs.instance.retrieveAllSpreadsheets();
    await _getTrainerGroups();

    AppData.instance.activeTrainingGroups =
        SpreadsheetGenerator.instance.generateActiveTrainingGroups();

    AppData.instance.activeSpreadsheets = result;

    AppEvents.fireSpreadsheetReady();
  }

  // get TrainingGroups
  void generateTrainerGroups() {
    AppData.instance.activeTrainingGroups =
        SpreadsheetGenerator.instance.generateActiveTrainingGroups();
  }

  //------------ get TrainingGroups -----------------------
  Future<void> _getTrainerGroups() async {
    AppData.instance.trainingGroups = await Dbs.instance.getTrainingGroups();
    log(AppData.instance.trainingGroups.toString());
    AppData.instance.activeTrainingGroups =
        SpreadsheetGenerator.instance.generateActiveTrainingGroups();
  }

  //------------ get ExcludeDays -----------------------
  Future<void> getExcludeDays() async {
    List<ExcludeDay> excludeDays = await Dbs.instance.getExcludeDays();
    AppData.instance.excludeDays = excludeDays;
  }
}

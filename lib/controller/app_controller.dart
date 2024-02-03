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
  Future<void> retrieveSpreadsheet() async {
    List<FsSpreadsheet> result = await Dbs.instance.retrieveAllSpreadsheets();

    AppData.instance.activeTrainingGroups =
        SpreadsheetGenerator.instance.generateActiveTrainingGroups();

    AppData.instance.activeSpreadsheets = result;
    AppEvents.fireSpreadsheetReady();
  }

  //------------ get TrainingGroups -----------------------
  Future<void> getTrainerGroups() async {
    AppData.instance.trainingGroups = await Dbs.instance.getTrainingGroups();
    AppData.instance.activeTrainingGroups =
        SpreadsheetGenerator.instance.generateActiveTrainingGroups();
  }
}

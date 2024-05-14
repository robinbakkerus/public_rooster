import 'package:public_rooster/data/app_data.dart';
import 'package:public_rooster/event/app_events.dart';
import 'package:public_rooster/model/app_models.dart';
import 'package:public_rooster/service/dbs.dart';
import 'package:public_rooster/util/app_constants.dart';
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
    await getTrainerGroups();

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
  Future<void> getTrainerGroups() async {
    AppData.instance.trainingGroups = await Dbs.instance.getTrainingGroups();

    //fill excludePeriods
    for (TrainingGroup trainingGroup in AppData.instance.trainingGroups) {
      if (trainingGroup.name.toLowerCase() == Groep.zomer.name.toLowerCase()) {
        trainingGroup.setStartDate(AppData.instance.getSummerPeriod().fromDate);
        trainingGroup.setEndDate(AppData.instance.getSummerPeriod().toDate);
      } else {
        trainingGroup.setStartDate(DateTime(2024, 1, 1));
        trainingGroup.setEndDate(DateTime(2099, 1, 1));
        trainingGroup.setSummerPeriod(AppData.instance.getSummerPeriod());
      }

      if (trainingGroup.name.toLowerCase() == Groep.zamo.name.toLowerCase()) {
        trainingGroup.setSummerPeriod(SpecialPeriod.empty());
      }

      if (trainingGroup.name.toLowerCase() == Groep.sg.name.toLowerCase()) {
        SpecialPeriod startgroup = AppData.instance.specialDays.startersGroup;
        trainingGroup.setStartDate(startgroup.fromDate);
        trainingGroup.setEndDate(startgroup.toDate);
      }
    }

    AppData.instance.activeTrainingGroups =
        SpreadsheetGenerator.instance.generateActiveTrainingGroups();
  }

  Future<void> getSpecialDays() async {
    SpecialDays specialDays = await Dbs.instance.getSpecialsDays();
    AppData.instance.specialDays = specialDays;
  }

  Future<void> saveSpecialDays(SpecialDays specialDays) async {
    await Dbs.instance.saveSpecialDays(specialDays);
    AppData.instance.specialDays = specialDays;
  }
}

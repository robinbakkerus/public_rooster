import 'package:flutter/foundation.dart';
import 'package:public_rooster/data/app_data.dart';
import 'package:public_rooster/model/app_models.dart';
import 'package:public_rooster/util/app_mixin.dart';

class SpreadsheetGenerator with AppMixin {
  SpreadsheetGenerator._();

  static SpreadsheetGenerator instance = SpreadsheetGenerator._();

  //-------------
  List<ActiveTrainingGroup> generateActiveTrainingGroups() {
    List<ActiveTrainingGroup> result = [];

    ActiveTrainingGroup activeTrainingGroup = ActiveTrainingGroup(
        startDate: AppData.instance.getActiveDates().first, groupNames: []);

    for (DateTime date in AppData.instance.getActiveDates()) {
      List<String> names = getGroupNames(date);
      if (listEquals(names, activeTrainingGroup.groupNames)) {
        activeTrainingGroup.endDate = date;
      } else {
        activeTrainingGroup =
            ActiveTrainingGroup(startDate: date, groupNames: names);
        activeTrainingGroup.endDate = date;
        result.add(activeTrainingGroup);
      }
    }

    return result;
  }

  /// returns a list of group names for the given date
  List<String> getGroupNames(DateTime date) {
    List<String> result = [];
    for (TrainingGroup trainingGroup in AppData.instance.trainingGroups) {
      if (trainingGroup.getStartDate().isBefore(date) &&
          trainingGroup.getEndDate().isAfter(date) &&
          !_isExcludedForPeriod(trainingGroup, date)) {
        result.add(trainingGroup.name);
      }
    }
    return result;
  }

  //---- private --

  bool _isExcludedForPeriod(TrainingGroup trainingGroup, DateTime date) {
    if (trainingGroup.getSummerPeriod().isEmpty()) {
      return false;
    }

    if (date.isAfter(trainingGroup.getSummerPeriod().fromDate) &&
        date.isBefore(trainingGroup.getSummerPeriod().toDate)) {
      return true;
    }

    return false;
  }
}

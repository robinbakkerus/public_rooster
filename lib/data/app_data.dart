import 'package:public_rooster/model/app_models.dart';
import 'package:public_rooster/util/app_helper.dart';

class AppData {
  AppData._() {
    _initialize();
  }

  static final instance = AppData._();

  void _initialize() {}

  RunMode runMode = RunMode.acc;

  List<TrainingGroup> trainingGroups = [];
  List<ActiveTrainingGroup> activeTrainingGroups = [];
  DateTime _activeDate = DateTime(2024, 1, 1);
  List<DateTime> _activeDates = [];
  List<FsSpreadsheet> activeSpreadsheets = [];

  // --------------------
  void setActiveDate(DateTime date) {
    DateTime useDate = DateTime(date.year, date.month, 1);
    _activeDate = useDate;
    List<DateTime> allDates = AppHelper.instance.getDaysInBetween(useDate);
    _activeDates = allDates
        .where((e) =>
            e.weekday == DateTime.tuesday ||
            e.weekday == DateTime.thursday ||
            e.weekday == DateTime.saturday)
        .toList();
  }

  DateTime getActiveDate() {
    return _activeDate;
  }

  List<DateTime> getActiveDates() {
    return _activeDates;
  }
}

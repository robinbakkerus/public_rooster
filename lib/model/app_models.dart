import 'dart:convert';

// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:public_rooster/util/app_helper.dart';

class FsSpreadsheet {
  int year = 2024;
  int month = 1;
  List<FsSpreadsheetRow> rows = [];
  bool isFinal = false;
  FsSpreadsheet({
    required this.year,
    required this.month,
    required this.rows,
    required this.isFinal,
  });

  String getID() {
    return '${year}_$month';
  }

  bool isEmpty() => rows.isEmpty;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'year': year,
      'month': month,
      'rows': rows.map((x) => x.toMap()).toList(),
      'isFinal': isFinal,
    };
  }

  factory FsSpreadsheet.empty() {
    return FsSpreadsheet(year: 2024, month: 1, rows: [], isFinal: true);
  }

  factory FsSpreadsheet.fromMap(Map<String, dynamic> map) {
    return FsSpreadsheet(
      year: map['year'] as int,
      month: map['month'] as int,
      rows: List<FsSpreadsheetRow>.from(
        (map['rows'] as List<dynamic>).map<FsSpreadsheetRow>(
          (x) => FsSpreadsheetRow.fromMap(x as Map<String, dynamic>),
        ),
      ),
      isFinal: map['isFinal'] as bool,
    );
  }

  @override
  String toString() => 'FsSpreadsheet(year: $year, month: $month, rows: $rows)';

  @override
  bool operator ==(covariant FsSpreadsheet other) {
    if (identical(this, other)) return true;

    return other.year == year && other.month == month;
  }

  @override
  int get hashCode => year.hashCode ^ month.hashCode ^ rows.hashCode;
}

//------------------------------------------------
class FsSpreadsheetRow {
  DateTime date = DateTime.now();
  String trainingText = '';
  bool isExtraRow = false;
  List<String> rowCells = [];
  FsSpreadsheetRow({
    required this.date,
    required this.trainingText,
    required this.isExtraRow,
    required this.rowCells,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'date': date.millisecondsSinceEpoch,
      'trainingText': trainingText,
      'isExtraRow': isExtraRow,
      'rowCells': rowCells,
    };
  }

  factory FsSpreadsheetRow.fromMap(Map<String, dynamic> map) {
    return FsSpreadsheetRow(
        date: DateTime.fromMillisecondsSinceEpoch(map['date']),
        trainingText: map['trainingText'] as String,
        isExtraRow: map['isExtraRow'] as bool,
        rowCells: List<String>.from(
          (map['rowCells'] as List<dynamic>),
        ));
  }

  @override
  String toString() =>
      'FsSpreadsheetRow(trainingText: $trainingText, isExtraRow: $isExtraRow, rowCells: $rowCells)';

  @override
  bool operator ==(covariant FsSpreadsheetRow other) {
    if (identical(this, other)) return true;

    return other.trainingText == trainingText && other.isExtraRow == isExtraRow;
  }

  @override
  int get hashCode => trainingText.hashCode ^ isExtraRow.hashCode;
}

///----------------------------------
class TrainingGroup {
  final String name;
  final String description;
  final TrainingGroupType type;
  List<int> trainingDays = []; // take into account weekdays
  String defaultTrainingText;
  //-- these are set by AppController
  SpecialPeriod? _summerPeriod;
  DateTime? _startDate;
  DateTime? _endDate;

  TrainingGroup({
    required this.name,
    required this.description,
    required this.type,
    required this.trainingDays,
    required this.defaultTrainingText,
  });

  DateTime getStartDate() {
    return _startDate ?? DateTime(2024, 1, 1);
  }

  void setStartDate(DateTime date) {
    _startDate = date;
  }

  DateTime getEndDate() {
    return _endDate ?? DateTime(2099, 1, 1);
  }

  void setEndDate(DateTime date) {
    _endDate = date;
  }

  SpecialPeriod getSummerPeriod() {
    return _summerPeriod ??
        SpecialPeriod(fromDate: DateTime.now(), toDate: DateTime.now());
  }

  void setSummerPeriod(SpecialPeriod summerPeriod) {
    _summerPeriod = summerPeriod;
  }

  TrainingGroup copyWith({
    String? name,
    String? description,
    TrainingGroupType? type,
    List<int>? trainingDays,
    String? defaultTrainingText,
  }) {
    return TrainingGroup(
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      trainingDays: trainingDays ?? this.trainingDays,
      defaultTrainingText: defaultTrainingText ?? this.defaultTrainingText,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'type': type.toMap(),
      'trainingDays': trainingDays,
      'defaultTrainingText': defaultTrainingText,
    };
  }

  factory TrainingGroup.fromMap(Map<String, dynamic> map) {
    return TrainingGroup(
      name: map['name'],
      description: map['description'],
      type: TrainingGroupType.fromMap(map['type']),
      trainingDays: List<int>.from(map['trainingDays']),
      defaultTrainingText: map['defaultTrainingText'],
    );
  }
  String toJson() => json.encode(toMap());
  factory TrainingGroup.fromJson(String source) =>
      TrainingGroup.fromMap(json.decode(source));

  @override
  String toString() {
    return 'TrainingGroup(name: $name, description: $description, startDate: $getStartDate(), endDate: $getEndDate(), type: $type, trainingDays: $trainingDays,  defaultTrainingText: $defaultTrainingText)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TrainingGroup &&
        other.name == name &&
        other.description == description &&
        other.type == type &&
        listEquals(other.trainingDays, trainingDays) &&
        other.defaultTrainingText == defaultTrainingText;
  }

  @override
  int get hashCode {
    return name.hashCode ^
        description.hashCode ^
        type.hashCode ^
        trainingDays.hashCode ^
        defaultTrainingText.hashCode;
  }
}

///----- SpecialDays object ---------
///-----------------------------
class SpecialPeriod {
  final DateTime fromDate;
  final DateTime toDate;
  SpecialPeriod({
    required this.fromDate,
    required this.toDate,
  });

  bool isValid() {
    return fromDate != toDate;
  }

  SpecialPeriod clone() {
    return SpecialPeriod(
      fromDate: fromDate,
      toDate: toDate,
    );
  }

  SpecialPeriod copyWith({
    DateTime? fromDate,
    DateTime? toDate,
  }) {
    return SpecialPeriod(
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fromDate': fromDate.millisecondsSinceEpoch,
      'toDate': toDate.millisecondsSinceEpoch,
    };
  }

  factory SpecialPeriod.fromMap(Map<String, dynamic> map) {
    return SpecialPeriod(
      fromDate: AppHelper.instance.parseDateTime(map['fromDate'])!,
      toDate: AppHelper.instance.parseDateTime(map['toDate'])!,
    );
  }

  factory SpecialPeriod.empty() {
    return SpecialPeriod(
        fromDate: DateTime(2024, 1, 1), toDate: DateTime(2024, 1, 1));
  }

  bool isEmpty() {
    return fromDate == toDate;
  }

  @override
  String toString() => 'SummerPeriod(fromDate: $fromDate, toDate: $toDate)';
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SpecialPeriod &&
        other.fromDate == fromDate &&
        other.toDate == toDate;
  }

  @override
  int get hashCode => fromDate.hashCode ^ toDate.hashCode;
}

///--------------------------------
class SpecialDay {
  final DateTime dateTime;
  final String description;

  SpecialDay({
    required this.dateTime,
    required this.description,
  });
  SpecialDay copyWith({
    DateTime? dateTime,
    String? description,
  }) {
    return SpecialDay(
      dateTime: dateTime ?? this.dateTime,
      description: description ?? this.description,
    );
  }

  SpecialDay clone() {
    return SpecialDay(
      dateTime: dateTime,
      description: description,
    );
  }

  factory SpecialDay.empty() {
    return SpecialDay(dateTime: DateTime(2000, 1, 1), description: '');
  }

  bool isValid() {
    return dateTime.year > 2023 && description.isNotEmpty;
  }

  Map<String, dynamic> toMap() {
    return {
      'dateTime': dateTime.millisecondsSinceEpoch,
      'description': description,
    };
  }

  factory SpecialDay.fromMap(Map<String, dynamic> map) {
    return SpecialDay(
      dateTime: AppHelper.instance.parseDateTime(map['dateTime'])!,
      description: map['description'],
    );
  }
  String toJson() => json.encode(toMap());
  factory SpecialDay.fromJson(String source) =>
      SpecialDay.fromMap(json.decode(source));
  @override
  String toString() => 'ExcludeDay(data: $dateTime, description: $description)';
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SpecialDay &&
        other.dateTime == dateTime &&
        other.description == description;
  }

  @override
  int get hashCode => dateTime.hashCode ^ description.hashCode;
}

//-----------------------------------------------------
class SpecialDays {
  final List<SpecialDay> excludeDays;
  final SpecialPeriod summerPeriod;
  final SpecialPeriod startersGroup;

  SpecialDays({
    required this.excludeDays,
    required this.summerPeriod,
    required this.startersGroup,
  });

  bool isValid() {
    SpecialDay? invalidSpecialDay =
        excludeDays.firstWhereOrNull((e) => !e.isValid());
    return summerPeriod.isValid() && invalidSpecialDay == null;
  }

  SpecialDays clone() {
    return SpecialDays(
      excludeDays: List.from(excludeDays),
      summerPeriod: summerPeriod.clone(),
      startersGroup: startersGroup.clone(),
    );
  }

  SpecialDays copyWith({
    List<SpecialDay>? excludeDays,
    SpecialPeriod? summerPeriod,
    SpecialPeriod? startersGroup,
  }) {
    return SpecialDays(
      excludeDays: excludeDays ?? this.excludeDays,
      summerPeriod: summerPeriod ?? this.summerPeriod,
      startersGroup: startersGroup ?? this.startersGroup,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'excludeDays': excludeDays.map((x) => x.toMap()).toList(),
      'summerPeriod': summerPeriod.toMap(),
      'startersGroup': startersGroup.toMap(),
    };
  }

  factory SpecialDays.fromMap(Map<String, dynamic> map) {
    return SpecialDays(
      excludeDays: List<SpecialDay>.from(
          map['excludeDays']?.map((x) => SpecialDay.fromMap(x))),
      summerPeriod: SpecialPeriod.fromMap(map['summerPeriod']),
      startersGroup: SpecialPeriod.fromMap(map['startersGroup']),
    );
  }
  String toJson() => json.encode(toMap());
  factory SpecialDays.fromJson(String source) =>
      SpecialDays.fromMap(json.decode(source));
  @override
  String toString() =>
      'SpecialDays(excludeDays: $excludeDays, summerPeriod: $summerPeriod, startersGroup: $startersGroup)';
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SpecialDays &&
        listEquals(other.excludeDays, excludeDays) &&
        other.summerPeriod == summerPeriod &&
        other.startersGroup == startersGroup;
  }

  @override
  int get hashCode =>
      excludeDays.hashCode ^ summerPeriod.hashCode ^ startersGroup.hashCode;
}

///--------------------------------
class ActiveTrainingGroup {
  final List<String> groupNames;
  final DateTime startDate;
  DateTime? endDate;
  ActiveTrainingGroup({
    required this.groupNames,
    required this.startDate,
  });
}

enum DeviceType {
  mobile,
  table,
  pc;
}

enum RunMode {
  prod,
  acc,
  dev;
}

enum TrainingGroupType {
  regular,
  special;

  String toMap() {
    return name;
  }

  factory TrainingGroupType.fromMap(String type) {
    switch (type) {
      case 'regular':
        return TrainingGroupType.regular;
      case 'special':
        return TrainingGroupType.special;
      default:
        return TrainingGroupType.regular;
    }
  }
}

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
  final DateTime startDate;
  final DateTime endDate;
  final TrainingGroupType type;
  List<int> trainingDays = []; // take into account weekdays
  List<ExcludePeriod> excludePeriods = [];
  String defaultTrainingText;

  TrainingGroup({
    required this.name,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.type,
    required this.trainingDays,
    required this.excludePeriods,
    required this.defaultTrainingText,
  });

  TrainingGroup copyWith({
    String? name,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    TrainingGroupType? type,
    List<int>? trainingDays,
    List<ExcludePeriod>? excludePeriods,
    List<ExcludeDay>? excludeDays,
    String? defaultTrainingText,
  }) {
    return TrainingGroup(
      name: name ?? this.name,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      type: type ?? this.type,
      trainingDays: trainingDays ?? this.trainingDays,
      excludePeriods: excludePeriods ?? this.excludePeriods,
      defaultTrainingText: defaultTrainingText ?? this.defaultTrainingText,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'startDate': startDate.millisecondsSinceEpoch,
      'endDate': endDate.millisecondsSinceEpoch,
      'type': type.toMap(),
      'trainingDays': trainingDays,
      'excludePeriods': excludePeriods.map((x) => x.toMap()).toList(),
      'defaultTrainingText': defaultTrainingText,
    };
  }

  factory TrainingGroup.fromMap(Map<String, dynamic> map) {
    return TrainingGroup(
      name: map['name'],
      description: map['description'],
      startDate: AppHelper.instance.parseDateTime(map['startDate'])!,
      endDate: AppHelper.instance.parseDateTime(map['endDate'])!,
      type: TrainingGroupType.fromMap(map['type']),
      trainingDays: List<int>.from(map['trainingDays']),
      excludePeriods: List<ExcludePeriod>.from(
          map['excludePeriods']?.map((x) => ExcludePeriod.fromMap(x))),
      defaultTrainingText: map['defaultTrainingText'],
    );
  }
  @override
  String toString() {
    return 'TrainingGroup(name: $name, description: $description, startDate: $startDate, endDate: $endDate, type: $type, trainingDays: $trainingDays, excludePeriods: $excludePeriods, defaultTrainingText: $defaultTrainingText)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TrainingGroup &&
        other.name == name &&
        other.description == description &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        other.type == type &&
        listEquals(other.trainingDays, trainingDays) &&
        listEquals(other.excludePeriods, excludePeriods) &&
        other.defaultTrainingText == defaultTrainingText;
  }

  @override
  int get hashCode {
    return name.hashCode ^
        description.hashCode ^
        startDate.hashCode ^
        endDate.hashCode ^
        type.hashCode ^
        trainingDays.hashCode ^
        excludePeriods.hashCode ^
        defaultTrainingText.hashCode;
  }
}

///-----------------------------
class ExcludePeriod {
  final DateTime fromDate;
  final DateTime toDate;
  ExcludePeriod({
    required this.fromDate,
    required this.toDate,
  });
  ExcludePeriod copyWith({
    DateTime? fromDate,
    DateTime? toDate,
  }) {
    return ExcludePeriod(
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

  factory ExcludePeriod.fromMap(Map<String, dynamic> map) {
    return ExcludePeriod(
      fromDate: DateTime.fromMillisecondsSinceEpoch(map['fromDate']),
      toDate: DateTime.fromMillisecondsSinceEpoch(map['toDate']),
    );
  }

  @override
  String toString() => 'ExcludePeriod(fromDate: $fromDate, toDate: $toDate)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ExcludePeriod &&
        other.fromDate == fromDate &&
        other.toDate == toDate;
  }

  @override
  int get hashCode => fromDate.hashCode ^ toDate.hashCode;
}

///---------------------------
class ExcludeDay {
  final DateTime dateTime;
  final String description;

  ExcludeDay({
    required this.dateTime,
    required this.description,
  });
  ExcludeDay copyWith({
    DateTime? dateTime,
    String? description,
  }) {
    return ExcludeDay(
      dateTime: dateTime ?? this.dateTime,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'dateTime': dateTime.millisecondsSinceEpoch,
      'description': description,
    };
  }

  factory ExcludeDay.fromMap(Map<String, dynamic> map) {
    return ExcludeDay(
      dateTime: DateTime.fromMillisecondsSinceEpoch(map['dateTime']),
      description: map['description'],
    );
  }

  @override
  String toString() => 'ExcludeDay(data: $dateTime, description: $description)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ExcludeDay &&
        other.dateTime == dateTime &&
        other.description == description;
  }

  @override
  int get hashCode => dateTime.hashCode ^ description.hashCode;
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

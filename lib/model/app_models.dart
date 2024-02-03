import 'package:flutter/foundation.dart';

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
///-------------------------------

class TrainingGroup {
  final String name;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  List<DateTime> excludeDays = [];
  List<int> tiaDays = []; // take into account weekdays

  TrainingGroup({
    required this.name,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.excludeDays,
    required this.tiaDays,
  });
  TrainingGroup copyWith({
    String? name,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    List<DateTime>? excludeDays,
    List<int>? tiaDays,
  }) {
    return TrainingGroup(
      name: name ?? this.name,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      excludeDays: excludeDays ?? this.excludeDays,
      tiaDays: tiaDays ?? this.tiaDays,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'startDate': startDate.millisecondsSinceEpoch,
      'endDate': endDate.millisecondsSinceEpoch,
      'excludeDays': excludeDays.map((x) => x.millisecondsSinceEpoch).toList(),
      'tiaDays': tiaDays,
    };
  }

  factory TrainingGroup.fromMap(Map<String, dynamic> map) {
    return TrainingGroup(
      name: map['name'],
      description: map['description'],
      startDate: DateTime.fromMillisecondsSinceEpoch(map['startDate']),
      endDate: DateTime.fromMillisecondsSinceEpoch(map['endDate']),
      excludeDays: List<DateTime>.from(map['excludeDays']
          .map((x) => DateTime.fromMillisecondsSinceEpoch(x))),
      tiaDays: List<int>.from(map['tiaDays']),
    );
  }

  @override
  String toString() {
    return 'TrainingGroup(name: $name, description: $description, startDate: $startDate, endDate: $endDate, excludeDays: $excludeDays, tiaDays: $tiaDays)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TrainingGroup &&
        other.name == name &&
        other.description == description &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        listEquals(other.excludeDays, excludeDays) &&
        listEquals(other.tiaDays, tiaDays);
  }

  @override
  int get hashCode {
    return name.hashCode ^
        description.hashCode ^
        startDate.hashCode ^
        endDate.hashCode ^
        excludeDays.hashCode ^
        tiaDays.hashCode;
  }
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

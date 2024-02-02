// ignore_for_file: public_member_api_docs, sort_constructors_first

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

enum Groep {
  pr,
  r1,
  r2,
  r3,
  zamo;
}

enum DeviceType {
  mobile,
  table,
  pc;
}

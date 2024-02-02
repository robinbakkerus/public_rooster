import 'package:flutter/material.dart';
import 'package:public_rooster/event/app_events.dart';
import 'package:public_rooster/model/app_models.dart';
import 'package:public_rooster/repo/firestore_helper.dart';
import 'package:public_rooster/util/app_helper.dart';
import 'package:public_rooster/util/app_mixin.dart';

class ViewSchemaPage extends StatefulWidget {
  const ViewSchemaPage({super.key});

  @override
  State<ViewSchemaPage> createState() => _ViewSchemaPageState();
}

//-------------
class _ViewSchemaPageState extends State<ViewSchemaPage> with AppMixin {
  List<FsSpreadsheet> _spreadSheets = [];
  FsSpreadsheet _activeSpreadsheet = FsSpreadsheet.empty();
  String _barTitle = '???';
  bool _nextMonthEnabled = false;
  bool _prevMonthEnabled = false;

  @override
  void initState() {
    _getSpreadsheets();
    AppEvents.onSpreadsheetReadyEvent(_onReady);
    super.initState();
  }

  void _onReady(SpreadsheetReadyEvent event) {
    if (mounted) {
      setState(() {
        _setStateActions(DateTime.now());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    AppHelper.instance.getDeviceType(context);

    return Scaffold(
      appBar: _showTabBar() ? _appBar() : null,
      body: Padding(
        padding: const EdgeInsets.only(left: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGrid(),
            const SizedBox(height: 10),
            const Text(
                'Klik op training veld, als tekst niet helemaal zichtbaar is!'),
            const Text(
              'lonu-trainingschemas v1.1',
              style: TextStyle(fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid() {
    double colSpace = AppHelper.instance.isWindows() ? 15 : 6;
    return SafeArea(
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Scrollbar(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              horizontalMargin: 10,
              headingRowColor:
                  MaterialStateColor.resolveWith((states) => c.lightblue),
              columnSpacing: colSpace,
              dataRowMinHeight: 15,
              dataRowMaxHeight: 35,
              columns: _buildHeader(),
              rows: _buildRows(),
            ),
          ),
        ),
      ),
    );
  }

  List<DataColumn> _buildHeader() {
    List<DataColumn> result = [];

    result.add(const DataColumn(
        label: Text('Dag', style: TextStyle(fontStyle: FontStyle.italic))));
    result.add(const DataColumn(
        label:
            Text('Training', style: TextStyle(fontStyle: FontStyle.italic))));

    for (Groep groep in Groep.values) {
      result.add(DataColumn(
          label: Text(groep.name.toUpperCase(),
              style: const TextStyle(fontStyle: FontStyle.italic))));
    }
    return result;
  }

  List<DataRow> _buildRows() {
    List<DataRow> result = [];

    _activeSpreadsheet.rows.sort((a, b) => a.date.compareTo(b.date));

    for (FsSpreadsheetRow fsRow in _activeSpreadsheet.rows) {
      MaterialStateColor col =
          MaterialStateColor.resolveWith((states) => Colors.white);
      if (fsRow.isExtraRow) {
        col = MaterialStateColor.resolveWith((states) => Colors.white);
      } else if (fsRow.date.weekday == DateTime.tuesday) {
        col = MaterialStateColor.resolveWith((states) => c.lightGeen);
      } else if (fsRow.date.weekday == DateTime.thursday) {
        col = MaterialStateColor.resolveWith((states) => c.lightOrange);
      } else if (fsRow.date.weekday == DateTime.saturday) {
        col = MaterialStateColor.resolveWith((states) => c.lightBrown);
      }

      DataRow dataRow = DataRow(cells: _buildDataCells(fsRow), color: col);
      result.add(dataRow);
    }

    return result;
  }

  List<DataCell> _buildDataCells(FsSpreadsheetRow fsRow) {
    List<DataCell> result = [];

    result.add(_buildCell(AppHelper.instance.dayAsString(fsRow.date)));

    result.add(_buildTrainingCell(fsRow.trainingText));

    if (!fsRow.isExtraRow) {
      for (int i = 0; i < Groep.values.length; i++) {
        result.add(_buildCell(fsRow.rowCells[i]));
      }
    } else {
      for (int i = 0; i < Groep.values.length; i++) {
        result.add(_buildCell(''));
      }
    }

    return result;
  }

  DataCell _buildCell(String text) {
    return DataCell(Text(text));
  }

  DataCell _buildTrainingCell(String text) {
    double w = AppHelper.instance.isWindows() ? 200 : 100;
    return DataCell(Container(
        decoration:
            BoxDecoration(border: Border.all(width: 0.1, color: Colors.grey)),
        width: w,
        child: InkWell(
          onTap: () => _buildTrainerDialog(context, text),
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
          ),
        )));
  }

  void _getSpreadsheets() async {
    _spreadSheets = await FirestoreHelper.instance.retrieveSpreadsheets();
    AppEvents.fireSpreadsheetReady();
  }

  String _buildBarTitle() {
    DateTime date =
        AppHelper.instance.getDateFromSpreadsheet(_activeSpreadsheet);
    String prefix =
        AppHelper.instance.isWindows() ? 'Trainingschema: ' : 'Schema: ';
    return '$prefix${AppHelper.instance.monthAsString(date)}  ${date.year}';
  }

  bool _showTabBar() {
    return !_activeSpreadsheet.isEmpty();
  }

  PreferredSizeWidget? _appBar() {
    return AppBar(
      title: Text(_barTitle),
      actions: [
        _actionPrevMonth(),
        _actionNextMonth(),
      ],
    );
  }

  Widget _actionPrevMonth() {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      tooltip: 'Ga naar de vorige maand',
      onPressed: _prevMonthEnabled ? _gotoPrevMonth : null,
    );
  }

  Widget _actionNextMonth() {
    return IconButton(
      icon: const Icon(Icons.arrow_forward),
      tooltip: 'Ga naar de volgende maand',
      onPressed: _nextMonthEnabled ? _gotoNextMonth : null,
    );
  }

  // onPressed actions --
  void _gotoPrevMonth() {
    DateTime prevMonth = AppHelper.instance.getPrevMonth(
        AppHelper.instance.getDateFromSpreadsheet(_activeSpreadsheet));
    _gotoMonth(prevMonth);
  }

  void _gotoNextMonth() {
    DateTime nextMonth = AppHelper.instance.getNextMonth(
        AppHelper.instance.getDateFromSpreadsheet(_activeSpreadsheet));
    _gotoMonth(nextMonth);
  }

  void _gotoMonth(DateTime dateTime) {
    FsSpreadsheet fsSpreadsheet =
        (AppHelper.instance.findSpreadsheetByDate(_spreadSheets, dateTime));
    if (!fsSpreadsheet.isEmpty()) {
      setState(() {
        _setStateActions(dateTime);
      });
    }
  }

  void _setStateActions(DateTime dateTime) {
    _activeSpreadsheet =
        AppHelper.instance.findSpreadsheetByDate(_spreadSheets, dateTime);
    _barTitle = _buildBarTitle();

    DateTime nextMonth = AppHelper.instance.getNextMonth(dateTime);
    FsSpreadsheet nextSpreadsheet =
        (AppHelper.instance.findSpreadsheetByDate(_spreadSheets, nextMonth));
    _nextMonthEnabled = !nextSpreadsheet.isEmpty();

    DateTime prevMonth = AppHelper.instance.getPrevMonth(dateTime);
    FsSpreadsheet prevSpreadsheet =
        (AppHelper.instance.findSpreadsheetByDate(_spreadSheets, prevMonth));
    _prevMonthEnabled = !prevSpreadsheet.isEmpty();
  }

  Future<void> _buildTrainerDialog(BuildContext context, String text) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(text),
          ),
        );
      },
    );
  }
}

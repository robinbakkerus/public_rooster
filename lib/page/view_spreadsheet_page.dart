import 'package:flutter/material.dart';
import 'package:public_rooster/controller/app_controller.dart';
import 'package:public_rooster/data/app_data.dart';
import 'package:public_rooster/event/app_events.dart';
import 'package:public_rooster/model/app_models.dart';
import 'package:public_rooster/util/app_helper.dart';
import 'package:public_rooster/util/app_mixin.dart';
import 'package:public_rooster/util/spreadsheet_generator.dart';

const version = 'lonu-trainingschemas V2';

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
  Widget _dataGrid = Container();

  @override
  void initState() {
    AppController.instance.setActiveDate(DateTime.now());
    _getAllSpreadData();
    AppEvents.onSpreadsheetReadyEvent(_onReady);
    super.initState();
  }

  void _onReady(SpreadsheetReadyEvent event) {
    if (mounted) {
      setState(() {
        _spreadSheets = AppData.instance.activeSpreadsheets;
        _activeSpreadsheet =
            AppHelper.instance.findSpreadsheetByCurrentDate(_spreadSheets);
        _setStateActions(DateTime.now());
        _dataGrid = _buildGrid();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    AppHelper.instance.getDeviceType(context);

    return Scaffold(
      appBar: _showTabBar() ? _appBar() : null,
      body: _buildBody(),
    );
  }

  //---------------------------------
  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: SafeArea(
        child: _dataGrid,
      ),
    );
  }

  //--------------------------------------------------------
  Widget _buildGrid() {
    return ListView.builder(
      itemCount: AppData.instance.activeTrainingGroups.length + 1,
      itemBuilder: (context, index) => _buildListViewItem(context, index),
    );
  }

  //--------------------------------
  Widget _buildListViewItem(BuildContext context, int index) {
    if (index < AppData.instance.activeTrainingGroups.length) {
      return _buildDataTable(context, index);
    } else {
      return const Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10),
          Text('Klik op training veld, als tekst niet helemaal zichtbaar is!'),
          Text(
            version,
            style: TextStyle(fontSize: 10),
          ),
        ],
      );
    }
  }

  //--------------------------------
  Widget _buildDataTable(BuildContext context, int index) {
    double colSpace = AppHelper.instance.isWindows() ? 25 : 10;
    DateTime date = AppData.instance.activeTrainingGroups[index].startDate;
    return DataTable(
      headingRowHeight: 30,
      horizontalMargin: 10,
      headingRowColor: MaterialStateColor.resolveWith((states) => c.lightblue),
      columnSpacing: colSpace,
      dataRowMinHeight: 15,
      dataRowMaxHeight: 30,
      columns: _buildHeader(date),
      rows: _buildRows(index),
    );
  }

  //-------------------------
  List<DataColumn> _buildHeader(DateTime date) {
    List<DataColumn> result = [];

    result.add(const DataColumn(
        label: Text('Dag', style: TextStyle(fontStyle: FontStyle.italic))));
    result.add(const DataColumn(
        label:
            Text('Training', style: TextStyle(fontStyle: FontStyle.italic))));

    for (String groupName
        in SpreadsheetGenerator.instance.getGroupNames(date)) {
      result.add(DataColumn(
          label: Text(groupName.toUpperCase(),
              style: const TextStyle(fontStyle: FontStyle.italic))));
    }

    return result;
  }

  //-------------------------
  List<DataRow> _buildRows(int index) {
    List<DataRow> result = [];

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

    List<String> groupNames =
        SpreadsheetGenerator.instance.getGroupNames(fsRow.date);

    if (!fsRow.isExtraRow) {
      for (int i = 0; i < groupNames.length; i++) {
        result.add(_buildCell(fsRow.rowCells[i]));
      }
    } else {
      for (int i = 0; i < groupNames.length; i++) {
        result.add(const DataCell(Text('')));
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

  void _getAllSpreadData() async {
    await AppController.instance.retrieveAllSpreadsheetData();
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
    _dataGrid = _buildGrid();

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

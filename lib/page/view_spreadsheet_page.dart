import 'package:flutter/material.dart';
import 'package:public_rooster/controller/app_controller.dart';
import 'package:public_rooster/data/app_data.dart';
import 'package:public_rooster/data/app_version.dart' as version;
import 'package:public_rooster/event/app_events.dart';
import 'package:public_rooster/model/app_models.dart';
import 'package:public_rooster/util/app_helper.dart';
import 'package:public_rooster/util/app_mixin.dart';
import 'package:public_rooster/util/spreadsheet_generator.dart';

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
  int _activeHeaderLength = 0;

  @override
  void initState() {
    AppController.instance.setActiveDate(DateTime.now());
    _getMetaData();

    AppEvents.onSpreadsheetReadyEvent(_onReady);
    super.initState();
  }

  void _getMetaData() async {
    await AppController.instance.getSpecialDays();
    await AppController.instance.retrieveAllSpreadsheetData();
  }

  void _onReady(SpreadsheetReadyEvent event) {
    if (mounted) {
      setState(() {
        _spreadSheets = AppData.instance.activeSpreadsheets;
        _activeSpreadsheet =
            AppHelper.instance.findSpreadsheetByCurrentDate(_spreadSheets);
        _setStateActions(DateTime.now());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _dataGrid = _buildGrid(context);
    // AppHelper.instance.getDeviceType(context);

    return Scaffold(
      appBar: _showTabBar() ? _appBar() : null,
      body: _buildBody(),
    );
  }

  //---------------------------------
  Widget _buildBody() {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
          scrollDirection: Axis.horizontal, child: _dataGrid),
    );
  }

  Widget _buildGrid(BuildContext context) {
    List<Widget> rows = [];

    for (int i = 0; i < AppData.instance.activeTrainingGroups.length; i++) {
      rows.add(_buildDataTable(context, i));
    }
    rows.add(_buildBottomColumn());

    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 2, 2, 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: rows,
      ),
    );
  }
  //--------------------------------

  Container _buildBottomColumn() {
    Color color =
        AppData.instance.runMode == RunMode.acc ? Colors.yellow : Colors.white;
    return Container(
      color: color,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          const Text(
              'Klik op training veld, als tekst niet helemaal zichtbaar is!'),
          Text(
            'public-lonutrainingschemas ${version.appVersion}',
            style: const TextStyle(fontSize: 10),
          ),
        ],
      ),
    );
  }

  //--------------------------------
  Widget _buildDataTable(BuildContext context, int index) {
    double colSpace = AppHelper.instance.isWindows() ? 25 : 10;
    DateTime date = AppData.instance.activeTrainingGroups[index].startDate;
    return DataTable(
      headingRowHeight: 30,
      horizontalMargin: 10,
      headingRowColor: WidgetStateColor.resolveWith((states) => c.lonuBlauw),
      columnSpacing: colSpace,
      dataRowMinHeight: 15,
      dataRowMaxHeight: 30,
      columns: _buildHeader(date),
      rows: _buildDataRows(index),
    );
  }

  //-------------------------
  List<DataColumn> _buildHeader(DateTime date) {
    List<DataColumn> result = [];

    List<String> groupNames = SpreadsheetGenerator.instance.getGroupNames(date);
    String trainingText = groupNames.length > 2 ? 'Training' : 'Zomer training';

    result.add(const DataColumn(
        label: Text('Dag', style: TextStyle(fontStyle: FontStyle.italic))));
    result.add(DataColumn(
        label: Text(trainingText,
            style: const TextStyle(fontStyle: FontStyle.italic))));

    for (String groupName
        in SpreadsheetGenerator.instance.getGroupNames(date)) {
      result.add(DataColumn(
          label: Text(_formatHeader(groupName),
              style: const TextStyle(fontStyle: FontStyle.italic))));
    }

    _activeHeaderLength = result.length;
    return result;
  }

  //------------------------------
  String _formatHeader(String header) {
    if (header.length < 3) {
      return header.toUpperCase();
    } else if (header.toLowerCase() == 'zamo') {
      return 'ZaMo';
    } else if (header.toLowerCase() == 'zomer') {
      return 'Gecombineerd';
    } else {
      return header;
    }
  }

  //-------------------------
  List<DataRow> _buildDataRows(int index) {
    List<DataRow> result = [];

    DateTime startDate = AppData.instance.activeTrainingGroups[index].startDate;
    DateTime endDate = AppData.instance.activeTrainingGroups[index].endDate!;

    for (FsSpreadsheetRow fsRow in _activeSpreadsheet.rows) {
      if (fsRow.date.isAfter(endDate) || fsRow.date.isBefore(startDate)) {
        continue;
      }

      WidgetStateColor col = _getRowColor(fsRow);
      DataRow dataRow = DataRow(cells: _buildDataCells(fsRow), color: col);
      result.add(dataRow);
    }

    return result;
  }

  WidgetStateColor _getRowColor(FsSpreadsheetRow fsRow) {
    WidgetStateColor col =
        WidgetStateColor.resolveWith((states) => Colors.white);
    if (fsRow.isExtraRow) {
      col = WidgetStateColor.resolveWith((states) => c.lonuExtraDag);
    } else if (fsRow.date.weekday == DateTime.saturday) {
      col = WidgetStateColor.resolveWith((states) => c.lonuZaterDag);
    } else if (AppHelper.instance.isDateExcluded(fsRow.date)) {
      col = WidgetStateColor.resolveWith((states) => c.lonuExtraDag);
    } else if (fsRow.date.weekday == DateTime.tuesday) {
      col = WidgetStateColor.resolveWith((states) => c.lonuDinsDag);
    } else if (fsRow.date.weekday == DateTime.thursday) {
      col = WidgetStateColor.resolveWith((states) => c.lonuDonderDag);
    }
    return col;
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

    if (result.length != _activeHeaderLength) {
      lp('todo $_activeHeaderLength');
    }
    return result;
  }

  DataCell _buildCell(String text) {
    return DataCell(Text(text));
  }

  DataCell _buildTrainingCell(String text) {
    double w = AppHelper.instance.isWindows() ? 400 : 150;
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

  String _buildBarTitle() {
    DateTime date =
        AppHelper.instance.getDateFromSpreadsheet(_activeSpreadsheet);
    String prefix = 'Schema ';
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
    AppController.instance.setActiveDate(dateTime);
    FsSpreadsheet fsSpreadsheet =
        (AppHelper.instance.findSpreadsheetByDate(_spreadSheets, dateTime));
    if (!fsSpreadsheet.isEmpty()) {
      setState(() {
        AppController.instance.generateTrainerGroups();
        _setStateActions(dateTime);
      });
    }
  }

  void _setStateActions(DateTime dateTime) {
    _activeSpreadsheet =
        AppHelper.instance.findSpreadsheetByDate(_spreadSheets, dateTime);
    AppController.instance.generateTrainerGroups();
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

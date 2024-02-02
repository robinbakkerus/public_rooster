// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:event_bus/event_bus.dart';

/*
 * All Events are maintainded here.
 */

class SpreadsheetReadyEvent {}

/*
	Static class that contains all onXxx and fireXxx methods.
*/
class AppEvents {
  static final EventBus _sEventBus = EventBus();

  // Only needed if clients want all EventBus functionality.
  static EventBus ebus() => _sEventBus;

  /*
  * The methods below are just convenience shortcuts to make it easier for the client to use.
  */

  static void fireSpreadsheetReady() =>
      _sEventBus.fire(SpreadsheetReadyEvent());

  ///----- static onXxx methods --------

  static void onSpreadsheetReadyEvent(OnSpreadsheetReadyEventFunc func) =>
      _sEventBus.on<SpreadsheetReadyEvent>().listen((event) => func(event));
}

/// ----- typedef's -----------

typedef OnSpreadsheetReadyEventFunc = void Function(
    SpreadsheetReadyEvent event);

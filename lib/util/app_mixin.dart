import 'dart:developer';

import 'package:public_rooster/util/app_constants.dart';

mixin AppMixin {
  final AppConstants c = AppConstants();

  lp(String message) {
    log(message);
  }
}

import 'package:public_rooster/model/app_models.dart';
import 'package:public_rooster/repo/firestore_helper.dart';

abstract class Dbs {
  static Dbs instance = FirestoreHelper.instance;

  Future<List<FsSpreadsheet>> retrieveAllSpreadsheets();
  Future<bool> sendEmail(
      {required String to, required String subject, required String html});
  Future<List<TrainingGroup>> getTrainingGroups();
  Future<List<ExcludeDay>> getExcludeDays();
}

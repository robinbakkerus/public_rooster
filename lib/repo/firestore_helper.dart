import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:public_rooster/model/app_models.dart';

class FirestoreHelper {
  FirestoreHelper._();
  static final FirestoreHelper instance = FirestoreHelper._();

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  /// retrieve all spreadsheet
  Future<List<FsSpreadsheet>> retrieveSpreadsheets() async {
    CollectionReference colref = firestore.collection('spreadsheet');

    List<FsSpreadsheet> result = [];
    await colref.get().then((querySnapshot) {
      for (var doc in querySnapshot.docs) {
        var map = doc.data() as Map<String, dynamic>;
        FsSpreadsheet fsSpreadsheet = FsSpreadsheet.fromMap(map);
        result.add(fsSpreadsheet);
      }
    });

    return result;
  }
}
